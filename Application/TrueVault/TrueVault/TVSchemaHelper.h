//
//  TVSchemaHelper.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//
#import <UIKit/UIKit.h>

@class TVSchema;
@interface TVSchemaHelper : NSObject

- (void)synchronizeSchemasWithCompletion:(void (^)(NSDictionary *schemasDictionary, NSError *error))completion;

@end
