//
//  TVObject.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/19/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVConstants.h"
#import "TVIndexed.h"

/** To save objects to TrueVault, they must be a subclass of TVObject.
 
Simply declare properties as you would on any other NSObject subclass, and those that are of type NSString, NSNumber or NSDate will be saved upon calling the saveWithCompletionHandler: method.

	@property (nonatomic, strong) NSString *name;
 
By default properties are not indexed and thus cannot be part of a TVQuery search. Simply modify your property to conform to <TVIndexed> for it to be indexed and thus searchable.

	@property (nonatomic, strong) NSString <<TVIndexed>> *name;
 
 */

@class TVQuery, TVFilter;
@interface TVObject : NSObject

/**
 The identifier of the object.
 */
@property (nonatomic, readonly) NSString *objectID;

/**
 The class name of the object.
 
 Override in your TVObject subclass if you want to manually specify the class name.
 Note that overriding this method is totally optional – by default the name of the class will be used as the class name.
 */
+ (NSString *)trueVaultClassName;

/**
 Initializes a TVObject with a given ObjectID. To fill in the rest of the data on the object, execute a fetch on the object.
 @param objectID the ObjectID of the given object.
 */
- (instancetype)initWithObjectID:(NSString *)objectID;

/**
 Saves the object asynchronously and executes the given completion handler when complete.
 @param completion The completion handler. error is nil if the save was successful.
 */
- (void)saveWithCompletionHandler:(TVCompletionBlock)completion;

/**
 Fetches the object asynchronously and executes the given completion handler when complete.
 @param completion The completion handler. error is nil if the save was successful.
 */
- (void)fetchWithCompletionHandler:(TVCompletionBlock)completion;

/**
 Deletes the object asynchronously and executes the given completion handler when complete.
 @param completion The completion handler. error is nil if the save was successful.
 */
- (void)deleteWithCompletionHandler:(TVCompletionBlock)completion;

/**
 Provides a way to query for objects of the given TVClass.
 @param filters An array of filters that correspond with the query.
 @return A query for the given TVObject with the given filters.
 @see TVQuery
 @see TVFilter
 */
+ (TVQuery *)queryWithFilters:(NSArray *)filters;

@end