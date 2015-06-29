//
//  TVHelper.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVHelper.h"

@implementation TVHelper

#pragma mark - JSON Serialization & Deserialization

+ (NSData *)dataWithJSONObject:(id)obj {
	NSError *error = nil;
	NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
	if (error) {
		NSLog(@"JSON error: %@", error);
    }
	return data;
}

+ (id)JSONObjectWithData:(NSData *)data error:(NSError **)error {
	id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
	return obj;
}


@end
