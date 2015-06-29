//
//  TVPendingRequest.h
//  TrueVault
//
//  Created by Edward Marks on 9/3/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVObject.h"
#import "TVFile.h"

@interface TVPendingRequest : NSObject <NSCoding>

+ (TVPendingRequest *)pendingObjectRequestWithIdentifier:(NSString *)identifier selectorString:(NSString *)selectorString object:(TVObject *)object completionHandler:(TVCompletionBlock)completionHandler;
+ (TVPendingRequest *)pendingFileRequestWithIdentifier:(NSString *)identifier selectorString:(NSString *)selectorString file:(TVFile *)fileDictionaryRepresentation completionHandler:(TVCompletionBlock)completionHandler;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *selectorString;

// Only one of these will be set because a pending request can be for either an Object or a File.
@property (nonatomic, readonly) TVObject *object;
@property (nonatomic, readonly) TVFile *file;

@property (nonatomic, readonly) TVCompletionBlock completionHandler;

@property (nonatomic) BOOL waitingForRetry;

@end
