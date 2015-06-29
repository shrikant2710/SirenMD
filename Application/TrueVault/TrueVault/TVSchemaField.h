//
//  TVSchemaField.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/22/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVConstants.h"
#import "TVPrivateConstants.h"

@interface TVSchemaField : NSObject <TVSerializable>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) BOOL index;

+ (TVSchemaField *)schemaFieldWithName:(NSString *)name type:(NSString *)type isIndexed:(BOOL)isIndexed;

@end
