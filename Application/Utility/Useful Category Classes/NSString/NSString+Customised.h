#import <Foundation/Foundation.h>

@interface NSString (Customised)

- (BOOL)isBlank;
- (BOOL)contains:(NSString *)string;
- (NSArray *)splitOnChar:(char)ch;
- (NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
- (NSString *)stringByStrippingWhitespace;
- (NSURL *)percentageEncapsulatedUrl;
- (NSString *)dateAndTimeFromGMTDateStringToLocalDateString;
- (NSString *)dateFromGMTDateStringToLocalDateString;
- (NSString *)timeFromGMTDateStringToLocalDateString;
+ (NSDate *)formatStringToDate:(NSString *)dateString_;

@end
