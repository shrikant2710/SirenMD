#import <Foundation/Foundation.h>

@interface NSString (Common)

- (BOOL)isBlank;
- (BOOL)contains:(NSString *)string;
- (NSArray *)splitOnChar:(char)ch;
- (NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
- (NSString *)stringByStrippingWhitespace;
- (NSString *)firstName;
- (NSString *)lastName;
- (NSString *)encoded;
- (NSString *)decoded;

@end
