//
//  TVFilter.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TVFilter is the class you use to restrict the results returned by a TVQuery.
 
 [TVFilter filterWhereKey:@"color" isEqualTo:@"blue"];
 
 */

@interface TVFilter : NSObject

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is equal to the provided value.
 
 This works with string, number and date values.
 @param key The key to check for equality.
 @param value The value that must be equalled.
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isEqualTo:(id)value;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is not equal to the provided value.

 This works with string, number and date values.
 @param key The key to check for inequality.
 @param value The value that must be not-equalled.
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isNotEqualTo:(id)value;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is equal to the provided value in a specifically case-sensitive or case-insensitive fashion.
 
 This works with only string values.
 @param key The key to check for case-(in)sensitive-equality.
 @param value The value that must be case-(in)sensitive-equalled.
 @param caseSensitive Whether or not the match is performed in a case-sensitive fashion.
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isEqualTo:(NSString *)value caseSensitive:(BOOL)caseSensitive;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is not equal to the provided value in a specifically case-sensitive or case-insensitive fashion.
 
 This works with only string values.
 @param key The key to check for case-(in)sensitive-inequality.
 @param value The value that must be case-(in)sensitive-not-equalled.
 @param caseSensitive Whether or not the match is performed in a case-sensitive fashion.
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isNotEqualTo:(NSString *)value caseSensitive:(BOOL)caseSensitive;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is equal to the provided value with wildcards in a specifically case-sensitive or case-insensitive fashion.
 
 This works with only string values.
 The two valid wildcards are '*' and '?'.
 These wildcards are only valid at the end of a string.
 @param key The key to check for case-(in)sensitive-wildcard-equality.
 @param value The value that must be case-(in)sensitive-equalled with wildcards.
 @param caseSensitive Whether or not the match is performed in a case-sensitive fashion.
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isWildcardMatchTo:(NSString *)value caseSensitive:(BOOL)caseSensitive;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is contained in the given array.
 
 This works with string, number and date values.
 @param key The key to check for containment.
 @param array The value that must be present in the array.
 @see TVQuery
*/
+ (TVFilter *)filterWhereKey:(NSString *)key isContainedIn:(NSArray *)array;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is not contained in the given array.
 
 This works with string, number and date values.
 @param key The key to check for non-containment.
 @param array The value that must not be present in the array.
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isNotContainedIn:(NSArray *)array;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is greater than the provided value.
 
 This works with number and date values.
 @param key The key to check for greater-than-ality (warning: made up word).
 @param value The value that must be greater-than'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThan:(id)value;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is greater than or equal to the provided value.
 
 This works with number and date values.
 @param key The key to check for greater-than-or-equal-to-ality (warning: made up word).
 @param value The value that must be greater-than-or-equal-to'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThanOrEqualTo:(id)value;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is less than than the provided value.
 
 This works with number and date values.
 @param key The key to check for less-than-ality (warning: made up word).
 @param value The value-that-must-be-less-than'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isLessThan:(id)value;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is less than or equal to the provided value.
 
 This works with number and date values.
 @param key The key to check for less-than-or-equal-to-ality (warning: made up word).
 @param value The value that must be less-than-or-equal-to'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isLessThanOrEqualTo:(id)value;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is greater than the first provided value and less than the second.
 
 This works with number and date values.
 @param key The key to check for greater-than-and-less-than-ality (warning: made up word).
 @param value The value that must be greater-than'ed (warning: made up word).
 @param value2 The value that must be less-than'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThan:(id)value andLessThan:(id)value2;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is greater than the first provided value and less than or equal to the second.
 
 This works with number and date values.
 @param key The key to check for greater-than-and-less-than-or-equal-to-ality (warning: made up word).
 @param value The value that must be greater'ed (warning: made up word).
 @param value2 The value that must be less-than-or-equal-to'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThan:(id)value andLessThanOrEqualTo:(id)value2;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is greater than or equal to the first provided value and less than the second.
 
 This works with number and date values.
 @param key The key to check for greater-than-or-equal-to-and-less-than-ality (warning: made up word).
 @param value The value that must be greater-than-or-equal-to'ed (warning: made up word).
 @param value2 The value that must be less-than'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThanOrEqualTo:(id)value andLessThan:(id)value2;

/*!
 An object used to restrict the results of a TVQuery to only those where a particular key's value is greater than or equal to the first provided value and less than or equal to the second.
 
 This works with number and date values.
 @param key The key to check for greater-than-or-equal-to-and-less-than-or-equal-to-ality (warning: made up word).
 @param value The value that must be greater-than-or-equal-to'ed (warning: made up word).
 @param value2 The value that must be less-than-or-equal-to'ed (warning: made up word).
 @see TVQuery
 */
+ (TVFilter *)filterWhereKey:(NSString *)key isGreaterThanOrEqualTo:(id)value andLessThanOrEqualTo:(id)value2;

@end
