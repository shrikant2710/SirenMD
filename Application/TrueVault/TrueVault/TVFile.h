//
//  TVFile.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/19/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVConstants.h"

/** TVFile is used to store arbitrary data to TrueVault. 
 */

@interface TVFile : NSObject

/**
 Creates a file with the given name and data.
 
 @param name Name of the file.
 @param data Data of the file.
 */
+ (TVFile *)fileWithName:(NSString *)name data:(NSData *)data;

/**
 The identifier of the file.
 */
@property (nonatomic, readonly) NSString *objectID;

/**
 The name of the file.
 */
@property (nonatomic, strong) NSString *name;

/**
 The data of the file.
 */
@property (nonatomic, strong) NSData *data;

/**
 Initializes a TVFile with a given ObjectID. To fill in the rest of the data on the file, execute a fetch on the file.
 @param objectID the ObjectID of the given file.
 */
- (instancetype)initWithObjectID:(NSString *)objectID;

/**
 Saves the object asynchronously and executes the given completion handler when complete.
 @param completion The completion handler. error is nil if the save was successful.
 */
- (void)saveWithCompletionHandler:(TVCompletionBlock)completion;

/**
 Fetches the object asynchronously and executes the given completion handler when complete.
 
 Access the fetched data from the object's data method.
 @see data
 @param completion The completion handler. error is nil if the fetch was successful.
 */
- (void)fetchDataWithCompletionHandler:(TVCompletionBlock)completion;

/**
 Deletes the object asynchronously and executes the given completion handler when complete.
 @param completion The completion handler. error is nil if the delete was successful.
 */
- (void)deleteWithCompletionHandler:(TVCompletionBlock)completion;

@end
