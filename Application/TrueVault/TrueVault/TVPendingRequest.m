//
//  TVPendingRequest.m
//  TrueVault
//
//  Created by Edward Marks on 9/3/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVPendingRequest.h"


#import "TVPrivateConstants.h"
#import "TVConstants.h"

@interface TVPendingRequest ()
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *selectorString;
@property (nonatomic, strong) TVObject *object;
@property (nonatomic, strong) TVFile *file;
@property (nonatomic, strong) TVCompletionBlock completionHandler;
@end

@interface TVObject (TVPendingRequest) <TVSerializable>
@end

@interface TVFile (TVPendingRequest) <TVSerializable>
@end

@implementation TVPendingRequest

+ (TVPendingRequest *)pendingObjectRequestWithIdentifier:(NSString *)identifier selectorString:(NSString *)selectorString object:(TVObject *)object completionHandler:(TVCompletionBlock)completionHandler {
    TVPendingRequest *pendingRequest = [[TVPendingRequest alloc] init];
    pendingRequest.identifier = identifier;
    pendingRequest.selectorString = selectorString;
    pendingRequest.object = object;
    pendingRequest.completionHandler = completionHandler;
    return pendingRequest;
}

+ (TVPendingRequest *)pendingFileRequestWithIdentifier:(NSString *)identifier selectorString:(NSString *)selectorString file:(TVFile *)fileDictionaryRepresentation completionHandler:(TVCompletionBlock)completionHandler {
    TVPendingRequest *pendingRequest = [[TVPendingRequest alloc] init];
    pendingRequest.identifier = identifier;
    pendingRequest.selectorString = selectorString;
    pendingRequest.file = fileDictionaryRepresentation;
    pendingRequest.completionHandler = completionHandler;
    return pendingRequest;
}

- (BOOL)isEqual:(TVPendingRequest *)request {
    return [self.identifier isEqualToString:request.identifier];
}

#pragma mark - NSCoding

static NSString *kPendingRequestCodingKeyIdentifier = @"kPendingRequestCodingKeyIdentifier";
static NSString *kPendingRequestCodingKeySelectorString = @"kPendingRequestCodingKeySelectorString";
static NSString *kPendingRequestCodingKeyObjectClass = @"kPendingRequestCodingKeyObjectClass";
static NSString *kPendingRequestCodingKeyObjectDictionaryRepresentation = @"kPendingRequestCodingKeyObjectDictionaryRepresentation";
static NSString *kPendingRequestCodingKeyFileDictionaryRepresentation = @"kPendingRequestCodingKeyFileDictionaryRepresentation";

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.identifier = [coder decodeObjectForKey:kPendingRequestCodingKeyIdentifier];
        self.selectorString = [coder decodeObjectForKey:kPendingRequestCodingKeySelectorString];

        NSDictionary *objectDictionaryRepresentation = [coder decodeObjectForKey:kPendingRequestCodingKeyObjectDictionaryRepresentation];
        if (objectDictionaryRepresentation) {
            NSString *classString = [coder decodeObjectForKey:kPendingRequestCodingKeyObjectClass];
            Class class = NSClassFromString(classString);
            if (class) {
                id object = [[class alloc] init];
                [object updateWithDictionaryRepresentation:objectDictionaryRepresentation];
                self.object = object;
            }
        }
    
        NSDictionary *fileDictionaryRepresentation = [coder decodeObjectForKey:kPendingRequestCodingKeyFileDictionaryRepresentation];
        if (fileDictionaryRepresentation)
            self.file = [TVFile objectFromDictionaryRepresentation:fileDictionaryRepresentation];
        self.completionHandler = NULL;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:kPendingRequestCodingKeyIdentifier];
    [coder encodeObject:self.selectorString forKey:kPendingRequestCodingKeySelectorString];
    if (self.object) {
        [coder encodeObject:NSStringFromClass([self.object class]) forKey:kPendingRequestCodingKeyObjectClass];
        [coder encodeObject:[self.object dictionaryRepresentation] forKey:kPendingRequestCodingKeyObjectDictionaryRepresentation];
    }
    if (self.file)
        [coder encodeObject:[self.file dictionaryRepresentation] forKey:kPendingRequestCodingKeyFileDictionaryRepresentation];
}

#pragma mark - Helpers

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@, %@: %@", self.identifier, self.selectorString, (self.object ? @"Object" : @"File"), (self.object ? self.object : self.file)];
}

@end
