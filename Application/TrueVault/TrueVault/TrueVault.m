//
//  TrueVault.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TrueVault.h"
#import "TVRequest.h"
#import "TVSchemaHelper.h"
#import "TVHelper.h"
#import "TVFile.h"
#import "TVSchema.h"
#import "TVSchemaField.h"
#import "TVPendingRequest.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>

@interface TrueVault ()

@property (nonatomic, strong) NSString *APIKey;
@property (nonatomic, strong) NSString *vaultID;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *pendingRequestQueue;

@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, strong) NSDictionary *schemas;
@property (nonatomic) BOOL schemaSynchonizationIsWaitingForRetry;

@property (nonatomic, strong) NSString *passString;

@property (nonatomic) BOOL testingMode;

@end

@interface TVObject (TrueVault) <TVSerializable>
@property (nonatomic, strong) NSString *objectID;
@end

@interface TVFile (TrueVault) <TVSerializable>
@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) NSData *data;
@end

@interface TVQuery (TrueVault) <TVSerializable>
@property (nonatomic, strong) NSString *localClassName;
@end

@implementation TrueVault

static TrueVault *sharedVault = nil;

+ (void)setVaultID:(NSString *)vaultID APIKey:(NSString *)APIKey {
	NSAssert(vaultID && [vaultID length] && APIKey && [APIKey length], @"Error: Both vaultID and APIKey are required.");
    
    if (sharedVault.testingMode == NO)
        NSAssert(sharedVault == nil, @"Error: setVaultID:APIKey: should only be called once.");
    
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedVault = [[super alloc] initWithVaultID:vaultID APIKey:APIKey];
        [sharedVault synchronizeSchemas];
        [sharedVault performAllPendingRequests];
		
        [[NSNotificationCenter defaultCenter] addObserver:sharedVault selector:@selector(reachabilityStatusChanged:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedVault selector:@selector(attemptToPerformWaitingRequests) name:UIApplicationWillEnterForegroundNotification object:nil];
        [sharedVault.reachability startNotifier];
    });
}

+ (TrueVault *)sharedVault {
	return sharedVault;
}

- (instancetype)initWithVaultID:(NSString *)vaultID APIKey:(NSString *)APIKey {
    NSAssert(vaultID && [vaultID length] && APIKey && [APIKey length], @"Error: Both vaultID and APIKey are required.");

	if (self = [self init]) {
		self.APIKey = APIKey;
		self.vaultID = vaultID;
		
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        [operationQueue setSuspended:YES];
        self.operationQueue = operationQueue;
		self.pendingRequestQueue = [NSMutableArray array];

        // The password string is generated in code deterministically so that it doesn't need to be saved to disk.
        self.passString = [NSString stringWithFormat:@"%ld%ld%ld%ld", \
                           (unsigned long)[[[NSString stringWithFormat:@"%0.20f", M_PI] substringWithRange:NSMakeRange(2, 10)] hash],
                           (unsigned long)[[[NSString stringWithFormat:@"%0.20f", M_E] substringWithRange:NSMakeRange(2, 10)] hash],
                           (unsigned long)[[[NSString stringWithFormat:@"%0.20f", M_LOG2E] substringWithRange:NSMakeRange(2, 10)] hash],
                           (unsigned long)[[[NSString stringWithFormat:@"%0.20f", M_SQRT2] substringWithRange:NSMakeRange(2, 10)] hash]];
        self.reachability = [Reachability reachabilityWithHostName:@"api.truevault.com"];
	}
	return self;
}


#pragma mark - TVObject

- (void)saveObject:(TVObject *)object withCompletionHandler:(TVCompletionBlock)completionHandler {
    TVPendingRequest *pendingRequest = [TVPendingRequest pendingObjectRequestWithIdentifier:[[NSUUID UUID] UUIDString] selectorString:NSStringFromSelector(_cmd) object:object completionHandler:completionHandler];
    [self enqueuePendingRequest:pendingRequest];

    [self.operationQueue addOperationWithBlock:^{
        
        // New Object
        if (object.objectID == nil) {
            TVRequest *postRequest = [TVRequest documentPOSTRequestWithDocument:[object dictionaryRepresentation] schemaID:[self schemaIDForTrueVaultClassName:[[object class] trueVaultClassName]] completionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                if (!error) {
                    object.objectID = responseDictionary[@"document_id"];
                    if (completionHandler)
                        completionHandler(NULL);
                    [self dequeuePendingRequest:pendingRequest];
                } else {
                    if (!shouldRetryPendingRequestLater(error)) {
                        if (completionHandler)
                            completionHandler(error);
                        [self dequeuePendingRequest:pendingRequest];
                    } else {
                        pendingRequest.waitingForRetry = YES;
                    }
                }
            }];
            [postRequest sendRequest];
        }
        
        // Update Object
        else {
            TVRequest *putRequest = [TVRequest documentPUTRequestWithDocument:[object dictionaryRepresentation] documentID:object.objectID schemaID:[self schemaIDForTrueVaultClassName:[[object class] trueVaultClassName]] completionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                if (!error) {
                    if (completionHandler)
                        completionHandler(NULL);
                    [self dequeuePendingRequest:pendingRequest];
                } else {
                    if (!shouldRetryPendingRequestLater(error)) {
                        if (completionHandler)
                            completionHandler(error);
                        [self dequeuePendingRequest:pendingRequest];
                    } else {
                        pendingRequest.waitingForRetry = YES;
                    }
                }
            }];
            [putRequest sendRequest];
        }
        
    }];
}

- (void)fetchObject:(TVObject *)object withCompletionHandler:(TVCompletionBlock)completionHandler {
    [self.operationQueue addOperationWithBlock:^{
        
    	TVRequest *fetchRequest = [TVRequest documentGETRequestWithDocument:[object dictionaryRepresentation] documentID:object.objectID completionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
            if (!error) {
                [object updateWithDictionaryRepresentation:responseDictionary];
                if (completionHandler)
                    completionHandler(NULL);
            } else {
                if (completionHandler)
                    completionHandler(error);
            }
        }];
        [fetchRequest sendRequest];
        
    }];
}

- (void)deleteObject:(TVObject *)object withCompletionHandler:(TVCompletionBlock)completionHandler {
    TVPendingRequest *pendingRequest = [TVPendingRequest pendingObjectRequestWithIdentifier:[[NSUUID UUID] UUIDString] selectorString:NSStringFromSelector(_cmd) object:object completionHandler:completionHandler];
    [self enqueuePendingRequest:pendingRequest];

    [self.operationQueue addOperationWithBlock:^{

        TVRequest *deleteRequest = [TVRequest documentDELETERequestWithDocument:[object dictionaryRepresentation] documentID:object.objectID completionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
            if (!error) {
                object.objectID = nil;
                if (completionHandler)
                    completionHandler(NULL);
                [self dequeuePendingRequest:pendingRequest];
            } else {
                if (!shouldRetryPendingRequestLater(error)) {
                    if (completionHandler)
                        completionHandler(error);
                    [self dequeuePendingRequest:pendingRequest];
                } else {
                    pendingRequest.waitingForRetry = YES;
                }
            }
        }];
        [deleteRequest sendRequest];

    }];
}

#pragma mark - TVQuery

- (void)performQuery:(TVQuery *)query withCompletionHandler:(TVQueryCompletionBlock)completionHandler {
    [self.operationQueue addOperationWithBlock:^{
        
        TVRequest *queryRequest = [TVRequest documentsGETRequestWithSearchOptions:[query dictionaryRepresentation] completionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
            if (!error) {
                NSMutableArray *results = [NSMutableArray array];
                
                NSArray *documentsArray = responseDictionary[@"data"][@"documents"];
                for (NSDictionary *document in documentsArray) {
                    NSDictionary *dictionaryRepresentation = [TVHelper JSONObjectWithData:[[NSData alloc] initWithBase64EncodedString:document[@"document"] options:0] error:NULL];
                    
                    Class objectClass = NSClassFromString(query.localClassName);
                    
                    // Create TVObject from data
                    TVObject *object = [[objectClass alloc] init];
                    object.objectID = document[@"document_id"];
                    if ([object respondsToSelector:@selector(updateWithDictionaryRepresentation:)])
                        [object updateWithDictionaryRepresentation:dictionaryRepresentation];
                    
                    [results addObject:object];
                }
                
                if (completionHandler)
                    completionHandler(results, nil);
            } else {
                if (completionHandler)
                    completionHandler(nil, error);
            }
        }];
        [queryRequest sendRequest];
        
    }];
}

#pragma mark - TVFile

- (void)saveFile:(TVFile *)file withCompletionHandler:(TVCompletionBlock)completionHandler {
    TVPendingRequest *pendingRequest = [TVPendingRequest pendingFileRequestWithIdentifier:[[NSUUID UUID] UUIDString] selectorString:NSStringFromSelector(_cmd) file:file completionHandler:completionHandler];
    [self enqueuePendingRequest:pendingRequest];

    [self.operationQueue addOperationWithBlock:^{
    
        // New File
        if (file.objectID == nil) {
            TVRequest *postRequest = [TVRequest blobPOSTRequestWithBlob:[NSDictionary dictionary] fileName:file.name data:file.data completionHandler:^(NSDictionary *responseDictionary, NSData *responseData, NSError *error) {
                if (!error) {
                    file.objectID = responseDictionary[@"blob_id"];
                    if (completionHandler)
                        completionHandler(NULL);
                    [self dequeuePendingRequest:pendingRequest];
                } else {
                    if (!shouldRetryPendingRequestLater(error)) {
                        if (completionHandler)
                            completionHandler(error);
                        [self dequeuePendingRequest:pendingRequest];
                    } else {
                        pendingRequest.waitingForRetry = YES;
                    }
                }
            }];
            [postRequest sendRequest];
        }
        
        // Update File
        else {
            TVRequest *putRequest = [TVRequest blobPUTRequestWithBlob:[NSDictionary dictionary] blobID:file.objectID fileName:file.name data:file.data completionHandler:^(NSDictionary *responseDictionary, NSData *responseData, NSError *error) {
                if (!error) {
                    if (completionHandler)
                        completionHandler(NULL);
                    [self dequeuePendingRequest:pendingRequest];
                } else {
                    if (!shouldRetryPendingRequestLater(error)) {
                        if (completionHandler)
                            completionHandler(error);
                        [self dequeuePendingRequest:pendingRequest];
                    } else {
                        pendingRequest.waitingForRetry = YES;
                    }
                }
            }];
            [putRequest sendRequest];
        }
        
    }];
}

- (void)fetchFile:(TVFile *)file withCompletionHandler:(TVCompletionBlock)completionHandler {
    [self.operationQueue addOperationWithBlock:^{
     
        TVRequest *fetchRequest = [TVRequest blobGETRequestWithBlob:[NSDictionary dictionary] blobID:file.objectID completionHandler:^(NSDictionary *responseDictionary, NSData *responseData, NSError *error) {
            if (!error) {
                file.data = responseData;
				file.name = responseDictionary[@"filename"];
                if (completionHandler)
                    completionHandler(NULL);
            } else {
                if (completionHandler)
                    completionHandler(error);
            }
        }];
        [fetchRequest sendRequest];
        
    }];
}

- (void)deleteFile:(TVFile *)file withCompletionHandler:(TVCompletionBlock)completionHandler {
    TVPendingRequest *pendingRequest = [TVPendingRequest pendingFileRequestWithIdentifier:[[NSUUID UUID] UUIDString] selectorString:NSStringFromSelector(_cmd) file:file completionHandler:completionHandler];

    [self.operationQueue addOperationWithBlock:^{
        
        TVRequest *deleteRequest = [TVRequest blobDELETERequestWithBlob:[NSDictionary dictionary] blobID:file.objectID completionHandler:^(NSDictionary *responseDictionary, NSData *responseData, NSError *error) {
            if (!error) {
                file.objectID = nil;
                if (completionHandler)
                    completionHandler(NULL);
                [self dequeuePendingRequest:pendingRequest];
            } else {
                if (!shouldRetryPendingRequestLater(error)) {
                    if (completionHandler)
                        completionHandler(error);
                    [self dequeuePendingRequest:pendingRequest];
                } else {
                    pendingRequest.waitingForRetry = YES;
                }
            }
        }];
        [deleteRequest sendRequest];
        
    }];
}

#pragma mark - TVSchema

- (void)getRemoteSchemasWithCompletionHandler:(void (^)(NSArray *schemasList, NSError *error))completionHandler {

    TVRequest *getRemoteSchemasRequest = [TVRequest schemasGETRequestWithCompletionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSMutableArray *schemasList = [NSMutableArray array];
        
        for (NSDictionary *schemaDictionary in responseDictionary[@"schemas"]) {
            TVSchema *schema = [TVSchema objectFromDictionaryRepresentation:schemaDictionary];
            [schemasList addObject:schema];
        }
        
        if (completionHandler)
            completionHandler(schemasList, nil);
    }];
    [getRemoteSchemasRequest sendRequest];
}

- (void)fetchSchema:(TVSchema *)schema withCompletionHandler:(TVCompletionBlock)completionHandler {

    TVRequest *fetchRequest = [TVRequest schemaGETRequestWithDocument:[schema dictionaryRepresentation] schemaID:schema.schemaID completionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            [schema updateWithDictionaryRepresentation:responseDictionary[@"schema"]];
            if (completionHandler)
                completionHandler(nil);
        } else {
            if (completionHandler)
                completionHandler(error);
        }
    }];
    [fetchRequest sendRequest];
}

- (void)saveSchema:(TVSchema *)schema withCompletionHandler:(TVCompletionBlock)completionHandler {
    
    // New Schema
    if (schema.schemaID == nil) {
        TVRequest *postRequest = [TVRequest schemaPOSTRequestWithSchema:[schema dictionaryRepresentation] completionHandler:^(NSDictionary *responseDictionary, NSData *responseData, NSError *error) {
            if (!error) {
                schema.schemaID = responseDictionary[@"schema"][@"id"];
                if (completionHandler)
                    completionHandler(nil);
            } else {
                if (completionHandler)
                    completionHandler(error);
            }
        }];
        [postRequest sendRequest];
    }
    
    // Update Schema
    else {
        TVRequest *putRequest = [TVRequest schemaPUTRequestWithSchema:[schema dictionaryRepresentation] schemaID:schema.schemaID completionHandler:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
            if (!error) {
                if (completionHandler)
                    completionHandler(nil);
            } else {
                if (completionHandler)
                    completionHandler(error);
            }
        }];
        [putRequest sendRequest];
    }
}

#pragma mark - Schemas

// TODO Handle errors
- (void)synchronizeSchemas {
    self.schemaSynchonizationIsWaitingForRetry = NO;
    
    TVSchemaHelper *schemaHelper = [[TVSchemaHelper alloc] init];
    [schemaHelper synchronizeSchemasWithCompletion:^(NSDictionary *schemasDictionary, NSError *error) {
        if (!error) {
            self.schemas = schemasDictionary;
            [self startExecutingObjectAndFileRequests];
        } else {
            if (shouldRetryPendingRequestLater(error))
                self.schemaSynchonizationIsWaitingForRetry = YES;
        }
    }];
}

- (NSString *)schemaIDForTrueVaultClassName:(NSString *)trueVaultClassName {
    TVSchema *schema = self.schemas[trueVaultClassName];
    return schema.schemaID;
}

- (void)startExecutingObjectAndFileRequests {
    [self.operationQueue setSuspended:NO];
}

#pragma mark - Pending Request Queue Methods

- (void)enqueuePendingRequest:(TVPendingRequest *)pendingRequest {
    [self.pendingRequestQueue addObject:pendingRequest];
	[self archivePendingRequestQueue];
}

- (void)dequeuePendingRequest:(TVPendingRequest *)pendingRequest {
    [self.pendingRequestQueue removeObject:pendingRequest];
	[self archivePendingRequestQueue];
}

- (void)performAllPendingRequests {
	for (TVPendingRequest *pendingRequest in [self unarchivePendingRequestQueue])
        [self performPendingRequest:pendingRequest]; // Automatically re-queues the requests.
}

- (void)performPendingRequest:(TVPendingRequest *)pendingRequest {
    SEL selector = NSSelectorFromString(pendingRequest.selectorString);
    
    // Object Request
    if (pendingRequest.object) {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, TVObject *, TVCompletionBlock) = (void *)imp;
        func(self, selector, pendingRequest.object, pendingRequest.completionHandler);
    }
    
    // File Request
    else {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, TVFile *, TVCompletionBlock) = (void *)imp;
        func(self, selector, pendingRequest.file, pendingRequest.completionHandler);
    }
}

NSString *pendingRequestQueuePathString() {
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"PendingRequestQueue.dat"];
}

- (void)archivePendingRequestQueue {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.pendingRequestQueue]; // Archive the pendingRequestQueue to data.
	NSData *encryptedData = [self encryptData:data]; // Encrypt.
	
	NSError *error;
	[encryptedData writeToFile:pendingRequestQueuePathString() options:(NSDataWritingAtomic & NSDataWritingFileProtectionComplete) error:&error]; // Save encrypted data to disk. // NSDataWritingFileProtectionComplete: A hint to set the content protection attribute of the file when writing it out. In this case, the file is stored in an encrypted format and may be read from or written to only while the device is unlocked. At all other times, attempts to read and write the file result in failure.
	if (error) {
		//
	}
}

- (NSArray *)unarchivePendingRequestQueue {
	NSData *encryptedData = [NSData dataWithContentsOfFile:pendingRequestQueuePathString()]; // Load encrypted data from disk.
	if (!encryptedData) return [NSArray array];
	NSData *unencryptedData = [self decryptData:encryptedData]; // Decrypt.
    if (!unencryptedData) return [NSArray array];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:unencryptedData]; // Unarchive to an NSArray.
	return array;
}

- (NSData *)encryptData:(NSData *)unencryptedData {
	NSError *error;
	NSData *encryptedData = [RNEncryptor encryptData:unencryptedData withSettings:kRNCryptorAES256Settings password:self.passString error:&error];
	if (error) {
		NSLog(@"Encryption error: %@", error);
	}
	//NSLog(@"encryptedData: %@", encryptedData);
	return encryptedData;
}

- (NSData *)decryptData:(NSData *)encryptedData {
	NSError *error;
	NSData *decryptedData = [RNDecryptor decryptData:encryptedData withSettings:kRNCryptorAES256Settings password:self.passString error:&error];
	if (error) {
		NSLog(@"Decryption error: %@", error);
	}
	//NSLog(@"decryptedData: %@", decryptedData);
	return decryptedData;
}

BOOL shouldRetryPendingRequestLater(NSError *requestError) {
    return ([requestError.domain isEqualToString:NSURLErrorDomain] && (requestError.code == NSURLErrorTimedOut || requestError.code == NSURLErrorNotConnectedToInternet));
}

#pragma mark - Reachability

// Attempt to perform waiting requests no matter what the status is. Reachability is reliable about alerting us of changes but unreliable about knowing whether there is connectivity.
- (void)reachabilityStatusChanged:(NSNotification *)notification {
    if (self.schemas == nil && self.schemaSynchonizationIsWaitingForRetry)
        [self synchronizeSchemas];
    else
        [self attemptToPerformWaitingRequests];
}

- (void)attemptToPerformWaitingRequests {
    // Check if there are waiting requests
    BOOL waitingRequestsExist = NO;
    for (TVPendingRequest *request in self.pendingRequestQueue) {
        if (request.waitingForRetry)
            waitingRequestsExist = YES;
    }
    if (waitingRequestsExist == NO)
        return;
    
    // Perform Waiting Requests
    NSArray *oldRequestQueue = [self.pendingRequestQueue copy];
    self.pendingRequestQueue = [NSMutableArray array];
    
    for (TVPendingRequest *request in oldRequestQueue) {
        if (request.waitingForRetry)
            [self performPendingRequest:request];
        else
            [self.pendingRequestQueue addObject:request];
    }
}

@end
