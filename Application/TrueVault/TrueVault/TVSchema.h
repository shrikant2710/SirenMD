//
//  TVSchema.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/22/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVPrivateConstants.h"
#import "TVConstants.h"

@interface TVSchema : NSObject <TVSerializable>

+ (TVSchema *)schemaWithSchemaID:(NSString *)schemaID name:(NSString *)name fields:(NSArray *)fields;

@property (nonatomic, strong) NSString *schemaID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *fields;

- (void)saveWithCompletionHandler:(TVCompletionBlock)completion;
- (void)fetchWithCompletionHandler:(TVCompletionBlock)completion;

@end
