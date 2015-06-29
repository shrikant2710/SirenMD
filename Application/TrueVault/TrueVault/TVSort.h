//
//  TVQuerySort.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

/** TVSort is the class you use to sort the results returned by a TVQuery.
 
    [TVSort sortAscendingWithKey:@"name"];
 
 */

@interface TVSort : NSObject

/*!
 An object used to sort TVQuery results in ascending order by the given key.
 @param key The key to sort by.
 @see TVQuery
 */
+ (TVSort *)sortAscendingWithKey:(NSString *)key;

/*!
 An object used to sort TVQuery results in descending order by the given key.
 @param key The key to sort by.
 @see TVQuery
 */
+ (TVSort *)sortDescendingWithKey:(NSString *)key;

@end
