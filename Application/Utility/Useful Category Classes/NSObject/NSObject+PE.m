//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//


#import "NSObject+PE.h"


@implementation NSObject (PE)

- (BOOL)isNull:(NSObject *)object {
	if (!object) return YES;
	else if (object == [NSNull null]) return YES;
	else if ([object isKindOfClass:[NSString class]]) {
		return ([((NSString *)object)isEqualToString : @""]
		        || [((NSString *)object)isEqualToString : @"null"]
		        || [((NSString *)object)isEqualToString : @"<null>"]
		        || [((NSString *)object)isEqualToString : @"(null)"]
                );
	}
	return NO;
}

- (BOOL)isNotNull:(NSObject *)object {
	return ![self isNull:object];
}


@end
