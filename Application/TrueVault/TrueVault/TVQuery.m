//
//  TVQuery.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVQuery.h"
#import "TVFilter.h"
#import "TVSort.h"
#import "TrueVault.h"
#import "TVClassHelper.h"

#import "TVPrivateConstants.h"
#import "TVConstants.h"

@interface TVQuery ()
@property (nonatomic, strong) NSString *trueVaultClassName;
@property (nonatomic, strong) NSString *localClassName;
@property (nonatomic, strong) NSArray *filters;
@end

@interface TVFilter (TVQuery) <TVSerializable>
@property (nonatomic, strong) NSString *key;
@end

@interface TVSort (TVQuery) <TVSerializable>
@end

@interface TrueVault (TVQuery)
+ (TrueVault *)sharedVault;
- (NSString *)schemaIDForTrueVaultClassName:(NSString *)trueVaultClassName;
- (void)performQuery:(TVQuery *)query withCompletionHandler:(TVQueryCompletionBlock)completionHandler;
@end

@implementation TVQuery

- (instancetype)init {
    return [self initWithTrueVaultClassName:nil localClassName:nil filters:nil];
}

- (instancetype)initWithTrueVaultClassName:(NSString *)trueVaultClassName localClassName:(NSString *)localClassName filters:(NSArray *)filters {
    self = [super init];
    if (self) {
        self.trueVaultClassName = trueVaultClassName;
        self.localClassName = localClassName;
        self.filters = filters;
        self.page = 1;
        self.perPage = 20;
    }
    return self;
}

- (void)findObjectsWithCompletionHandler:(TVQueryCompletionBlock)completion {
    [self validateFilters];
    [[TrueVault sharedVault] performQuery:self withCompletionHandler:completion];
}

- (void)validateFilters {
    NSArray *properties = ClassGetProperties(NSClassFromString(self.localClassName));
    for (TVFilter *filter in self.filters) {

        // Check if the filter's key matches a property of the object
        NSInteger propertyMatchingFilter = [properties indexOfObjectPassingTest:^BOOL(NSDictionary *propertyDictionary, NSUInteger idx, BOOL *stop) {
            if ([propertyDictionary[kPropertyDictionaryNameKey] isEqualToString:filter.key]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
     
        if (propertyMatchingFilter == NSNotFound) {
            NSException *invalidFilterException = [NSException exceptionWithName:@"Attempted to perform query with invalid filter" reason:[NSString stringWithFormat:@"Filter for key \"%@\" does not match any property on class \"%@\"", filter.key, self.localClassName] userInfo:nil];
            [invalidFilterException raise];
        }
    }
}

- (NSDictionary *)dictionaryRepresentation {

    NSMutableDictionary *filterDictionary = [NSMutableDictionary dictionary];
    for (TVFilter *filter in self.filters) {
        [filterDictionary addEntriesFromDictionary:[filter dictionaryRepresentation]];
    }
    if ([filterDictionary count] == 0) // TrueVault rejects Queries with no Filters, so we add one in that will get all objects.
        [filterDictionary addEntriesFromDictionary:[[TVFilter filterWhereKey:@"id" isNotEqualTo:@""] dictionaryRepresentation]];
    
    NSMutableDictionary *sortDictionary = [NSMutableDictionary dictionary];
    for (TVSort *sort in self.sorts)
        [sortDictionary addEntriesFromDictionary:[sort dictionaryRepresentation]];
    
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionaryWithDictionary:@{@"filter": filterDictionary,
                                                                                                    @"page": @(self.page),
                                                                                                    @"per_page": @(self.perPage),
                                                                                                    @"filter_type": (self.defaultComparisonOperator == TVComparisonOperatorAnd ? @"and" : @"or"),
                                                                                                    @"full_document": @(YES)}];
    
    NSString *schemaID = [[TrueVault sharedVault] schemaIDForTrueVaultClassName:self.trueVaultClassName];
    if (schemaID)
        dictionaryRepresentation[@"schema_id"] = schemaID;
    
    if ([sortDictionary count] > 0)
        dictionaryRepresentation[@"sort"] = sortDictionary;
    
    return dictionaryRepresentation;
}

@end
