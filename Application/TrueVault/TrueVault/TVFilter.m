//
//  TVFilter.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVFilter.h"
#import "TVHelpers.h"

typedef NS_ENUM(NSInteger, TVFilterType) {
    TVFilterTypeIsEqualTo,
    TVFilterTypeIsNotEqualTo,
    TVFilterTypeIsContainedIn,
    TVFilterTypeIsNotContainedIn,
    TVFilterTypeIsWildcardMatchTo,
    TVFilterTypeIsGreaterThan,
    TVFilterTypeIsGreaterThanOrEqualTo,
    TVFilterTypeIsLessThan,
    TVFilterTypeIsLessThanOrEqualTo,
    TVFilterTypeIsGreaterThanAndLessThan,
    TVFilterTypeIsGreaterThanAndLessThanOrEqualTo,
    TVFilterTypeIsGreaterThanOrEqualToAndLessThan,
    TVFilterTypeIsGreaterThanOrEqualToAndLessThanOrEqualTo,
};

@interface TVFilter ()

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) id value2;
@property (nonatomic) TVFilterType filterType;
@property (nonatomic, strong) NSNumber *caseSensitive;

@end

@implementation TVFilter

+ (TVFilter *)filterWhereKey:(NSString *)key isEqualTo:(id)value {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsEqualTo caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isNotEqualTo:(id)value {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsNotEqualTo caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isEqualTo:(NSString *)value caseSensitive:(BOOL)caseSensitive {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsEqualTo caseSensitive:@(caseSensitive)];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isNotEqualTo:(NSString *)value caseSensitive:(BOOL)caseSensitive {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsNotEqualTo caseSensitive:@(caseSensitive)];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isWildcardMatchTo:(id)value {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsWildcardMatchTo caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isWildcardMatchTo:(NSString *)value caseSensitive:(BOOL)caseSensitive {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsWildcardMatchTo caseSensitive:@(caseSensitive)];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isContainedIn:(NSArray *)array {
    return [[TVFilter alloc] initWithKey:key value:array value2:nil filterType:TVFilterTypeIsContainedIn caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isNotContainedIn:(NSArray *)array {
    return [[TVFilter alloc] initWithKey:key value:array value2:nil filterType:TVFilterTypeIsNotContainedIn caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThan:(id)value {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsGreaterThan caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThanOrEqualTo:(id)value {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsGreaterThanOrEqualTo caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isLessThan:(id)value {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsLessThan caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isLessThanOrEqualTo:(id)value {
    return [[TVFilter alloc] initWithKey:key value:value value2:nil filterType:TVFilterTypeIsLessThanOrEqualTo caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThan:(id)value1 andLessThan:(id)value2 {
	return [[TVFilter alloc] initWithKey:key value:value1 value2:value2 filterType:TVFilterTypeIsGreaterThanAndLessThan caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThan:(id)value1 andLessThanOrEqualTo:(id)value2 {
    return [[TVFilter alloc] initWithKey:key value:value1 value2:value2 filterType:TVFilterTypeIsGreaterThanAndLessThanOrEqualTo caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThanOrEqualTo:(id)value1 andLessThan:(id)value2 {
    return [[TVFilter alloc] initWithKey:key value:value1 value2:value2 filterType:TVFilterTypeIsGreaterThanOrEqualToAndLessThan caseSensitive:nil];
}

+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThanOrEqualTo:(id)value1 andLessThanOrEqualTo:(id)value2 {
    return [[TVFilter alloc] initWithKey:key value:value1 value2:value2 filterType:TVFilterTypeIsGreaterThanOrEqualToAndLessThanOrEqualTo caseSensitive:nil];
}

- (instancetype)initWithKey:(NSString *)key value:(id)value value2:(id)value2 filterType:(TVFilterType)filterType caseSensitive:(NSNumber *)caseSensitive {
    self = [super init];
    if (self) {
        self.key = key;
        self.value = value;
        self.value2 = value2;
        self.filterType = filterType;
        self.caseSensitive = caseSensitive;
    }
    return self;
}

#pragma mark - TVSerializable

NSDateFormatter *dateFormatterForTVFilter = nil;

+ (void)initialize {
    if (dateFormatterForTVFilter == nil)
        dateFormatterForTVFilter = dateFormatterForCommunicatingWithTrueVault();
}

- (NSDictionary *)dictionaryRepresentation {
    id value = self.value;
	id value2 = self.value2;
    
    // Convert dates into strings
    if ([value isKindOfClass:[NSDate class]])
        value = [dateFormatterForTVFilter stringFromDate:value];
	
	if ([value2 isKindOfClass:[NSDate class]])
		value2 = [dateFormatterForTVFilter stringFromDate:value2];
	
	// Convert "in" array values to strings as well.
	if ((self.filterType == TVFilterTypeIsContainedIn || self.filterType == TVFilterTypeIsNotContainedIn)) {
		NSMutableArray *newValue = [NSMutableArray array];
		for (id object in value) {
			if ([object isKindOfClass:[NSDate class]])
				[newValue addObject:[dateFormatterForTVFilter stringFromDate:object]];
			else
				[newValue addObject:object];
		}
		value = newValue;
	}
	
    BOOL isComarisonOperator = (self.filterType >= TVFilterTypeIsGreaterThan);

    // Convert numerical comparators to numerical format
    if (isComarisonOperator) {
        if (self.filterType >= TVFilterTypeIsGreaterThan && self.filterType <= TVFilterTypeIsLessThanOrEqualTo)
            value = @{stringForFilterType(self.filterType): value};
        else
            value = @{stringForFirstPartOfRangeFilterType(self.filterType): value, stringForSecondPartOfRangeFilterType(self.filterType): value2};
    }
    
    NSMutableDictionary *valueDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"type": (isComarisonOperator ? @"range" : stringForFilterType(self.filterType)),
                                                                                           @"value": value}];
    if (self.caseSensitive)
        valueDictionary[@"case_sensitive"] = [NSNumber numberWithBool:[self.caseSensitive boolValue]];
    
    NSDictionary *dictionaryRepresentation = nil;
    if (self.filterType == TVFilterTypeIsEqualTo && self.caseSensitive == nil)
        dictionaryRepresentation = [NSMutableDictionary dictionaryWithDictionary:@{self.key : value}];
    else
        dictionaryRepresentation = @{self.key: valueDictionary};
    
    return dictionaryRepresentation;
}

NSString *stringForFilterType(TVFilterType filterType) {
    switch (filterType) {
        case TVFilterTypeIsEqualTo:
            return @"eq";
        case TVFilterTypeIsNotEqualTo:
            return @"not";
        case TVFilterTypeIsContainedIn:
            return @"in";
        case TVFilterTypeIsNotContainedIn:
            return @"not_in";
        case TVFilterTypeIsGreaterThan:
            return @"gt";
        case TVFilterTypeIsGreaterThanOrEqualTo:
            return @"gte";
        case TVFilterTypeIsLessThan:
            return @"lt";
        case TVFilterTypeIsLessThanOrEqualTo:
            return @"lte";
        case TVFilterTypeIsWildcardMatchTo:
            return @"wildcard";
        default:
            return nil;
    }
}

NSString *stringForFirstPartOfRangeFilterType(TVFilterType filterType) {
    switch (filterType) {
        case TVFilterTypeIsGreaterThanAndLessThan:
        case TVFilterTypeIsGreaterThanAndLessThanOrEqualTo:
            return stringForFilterType(TVFilterTypeIsGreaterThan);
        case TVFilterTypeIsGreaterThanOrEqualToAndLessThan:
        case TVFilterTypeIsGreaterThanOrEqualToAndLessThanOrEqualTo:
            return stringForFilterType(TVFilterTypeIsGreaterThanOrEqualTo);
        default:
            return nil;
    }
}

NSString *stringForSecondPartOfRangeFilterType(TVFilterType filterType) {
    switch (filterType) {
        case TVFilterTypeIsGreaterThanAndLessThan:
		case TVFilterTypeIsGreaterThanOrEqualToAndLessThan:
            return stringForFilterType(TVFilterTypeIsLessThan);
        case TVFilterTypeIsGreaterThanAndLessThanOrEqualTo:
        case TVFilterTypeIsGreaterThanOrEqualToAndLessThanOrEqualTo:
            return stringForFilterType(TVFilterTypeIsLessThanOrEqualTo);
        default:
            return nil;
    }
}

@end
