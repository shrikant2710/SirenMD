//
//  TVRequest.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVConstants.h"
#import "TVPrivateConstants.h"

typedef NS_ENUM(NSInteger, TVHTTPMethod) {
    TVHTTPMethodGET = 0,
    TVHTTPMethodPUT,
	TVHTTPMethodPOST,
	TVHTTPMethodDELETE,
};

@interface TVRequest : NSMutableURLRequest

- (void)sendRequest;

+ (TVRequest *)documentGETRequestWithDocument:(NSDictionary *)dictionary documentID:(NSString *)documentID completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)allDocumentsGETRequestWithCompletionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)documentsGETRequestWithSearchOptions:(NSDictionary *)document completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)documentPUTRequestWithDocument:(NSDictionary *)dictionary documentID:(NSString *)documentID schemaID:(NSString *)schemaId completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)documentPOSTRequestWithDocument:(NSDictionary *)dictionary schemaID:(NSString *)schemaID completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)documentDELETERequestWithDocument:(NSDictionary *)dictionary documentID:(NSString *)documentID completionHandler:(TVRequestCompletionBlock)completion;

+ (TVRequest *)blobGETRequestWithBlob:(NSDictionary *)dictionary blobID:(NSString *)blobID completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)blobPUTRequestWithBlob:(NSDictionary *)dictionary blobID:(NSString *)blobID fileName:(NSString *)fileName data:(NSData *)fileData completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)blobPOSTRequestWithBlob:(NSDictionary *)dictionary fileName:(NSString *)fileName data:(NSData *)fileData completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)blobDELETERequestWithBlob:(NSDictionary *)dictionary blobID:(NSString *)blobID completionHandler:(TVRequestCompletionBlock)completion;

+ (TVRequest *)schemasGETRequestWithCompletionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)schemaGETRequestWithDocument:(NSDictionary *)dictionary schemaID:(NSString *)schemaID completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)schemaPUTRequestWithSchema:(NSDictionary *)dictionary schemaID:(NSString *)schemaID completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)schemaPOSTRequestWithSchema:(NSDictionary *)dictionary completionHandler:(TVRequestCompletionBlock)completion;
+ (TVRequest *)schemaDELETERequestWithSchema:(NSDictionary *)dictionary schemaID:(NSString *)schemaID completionHandler:(TVRequestCompletionBlock)completion;
@property (nonatomic, readonly) BOOL isFileRequest;
@property (nonatomic, readonly) TVHTTPMethod TVHTTPMethod;
@property (nonatomic, strong) TVRequestCompletionBlock completion;


+ (instancetype)putDocumentwithData:(NSMutableDictionary *)dict endpoint:(NSString *)endpoint withAuthHeader:(NSString *)auth completion:(TVRequestCompletionBlock)completion;


+ (instancetype)postRequesforFormData:(NSMutableDictionary *)dict endpoint:(NSString *)endpoint withAuthHeader:(NSString *)auth completion:(TVRequestCompletionBlock)completion;
+ (instancetype)fetchImageFromBlobID:(NSString *)blobID forAuth:(NSString *)auth completion:(TVRequestCompletionBlock)completion;
+ (instancetype)fetchImageForUserFromBlobID:(NSString *)blobID forAuth:(NSString *)auth completion:(TVRequestCompletionBlock)completion;

@end
