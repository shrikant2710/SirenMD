//
//  TVQuery.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVConstants.h"

/**
 TVComparisonOperator is an enumerator for distinguishing between "AND" and "OR" comparison operators.
 */
typedef NS_ENUM(NSInteger, TVComparisonOperator) {
    /** AND Operator */
    TVComparisonOperatorAnd,
    /** OR Operator */
    TVComparisonOperatorOr
};

/** TVQuery is how you search for objected stored with TrueVault.
 
 The basic query is obtained from your TVObject subclass. You can then configure it with various other parameters.
 
 Example:

    TVQuery *pillQuery = [Pill queryWithFilters:@[[TVFilter filterWhereKey:@"color" isEqualTo:@"blue"]]];
    pillQuery.sorts = @[[TVSort sortAscendingWithKey:@"name"]];
    [pillQuery findObjectsWithCompletionHandler:^(NSArray *results, NSError *error) {
        if (error)
            NSLog(@"Query Error: %@", error);
        else
            NSLog(@"Found the following results: %@", results);
    }];

 */

@interface TVQuery : NSObject

/**
 The class name of the object being queried.
 */
@property (nonatomic, readonly) NSString *trueVaultClassName;

/**
 The array of filters being used to restrict the results of a query.
 @see TVFilter
 */
@property (nonatomic, readonly) NSArray *filters;

/**
 The array of sorts being used to order the query results. The sorts are used in order.
 @see TVSort
 */
@property (nonatomic, strong) NSArray *sorts;

/**
 The page of results to be returned.
 
 Default value is 1.
 */
@property (nonatomic) NSInteger page;

/**
 The number of results to be returned.
 Default is 20.
 Maximum accepted value is 100.
 */
@property (nonatomic) NSInteger perPage;

/**
 The default comparison operator to use with the filters.
 
 The default is AND, which will restrict the results to those that match all of the given filters.
 */
@property (nonatomic) TVComparisonOperator defaultComparisonOperator;

/**
 Finds results to the query asynchronously and executes the given completion handler when complete.
 @param completion The completion handler. error is nil if the query was successful.
 */
- (void)findObjectsWithCompletionHandler:(TVQueryCompletionBlock)completion;

@end
