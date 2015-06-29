//
//  TVHelper.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHelper : NSObject

+ (NSData *)dataWithJSONObject:(id)obj;
+ (id)JSONObjectWithData:(NSData *)data error:(NSError **)error;


@end
