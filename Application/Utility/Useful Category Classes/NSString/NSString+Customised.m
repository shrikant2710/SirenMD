#import "NSString+Customised.h"
#import "AKSMethods.h"

@implementation NSString (Customised)
- (BOOL)isBlank {
	if ([[self stringByStrippingWhitespace] isEqualToString:@""])
		return YES;
	return NO;
}

- (BOOL)contains:(NSString *)string {
	NSRange range = [self rangeOfString:string];
	return (range.location != NSNotFound);
}

- (NSString *)stringByStrippingWhitespace {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray *)splitOnChar:(char)ch {
	NSMutableArray *results = [[NSMutableArray alloc] init];
	int start = 0;
	for (int i = 0; i < [self length]; i++) {
		BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
		BOOL isAtEnd = i == [self length] - 1;

		if (isAtSplitChar || isAtEnd) {
			//take the substring &amp; add it to the array
			NSRange range;
			range.location = start;
			range.length = i - start + 1;

			if (isAtSplitChar)
				range.length -= 1;

			[results addObject:[self substringWithRange:range]];
			start = i + 1;
		}

		//handle the case where the last character was the split char.  we need an empty trailing element in the array.
		if (isAtEnd && isAtSplitChar)
			[results addObject:@""];
	}

	return results;
}

- (NSString *)substringFrom:(NSInteger)from to:(NSInteger)to {
	NSString *rightPart = [self substringFromIndex:from];
	return [rightPart substringToIndex:to - from];
}

- (NSURL *)percentageEncapsulatedUrl {
	return [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}

+ (NSDate *)formatStringToDate:(NSString *)dateString_ {
	if (![self isNotNull:dateString_] || dateString_.length == 0)
		return nil;
	NSString *dateString = [dateString_ copy];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSMutableString *RFC3339String = [NSMutableString stringWithString:[dateString uppercaseString]];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	[dateFormatter setDateFormat:DATE_FORMAT_USED];
	return [dateFormatter dateFromString:RFC3339String];
}

- (NSString *)dateAndTimeFromGMTDateStringToLocalDateString {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	[formatter setDateFormat:DATE_FORMAT_USED];
	return [formatter stringFromDate:[NSString formatStringToDate:self]];
}

- (NSString *)dateFromGMTDateStringToLocalDateString {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	[formatter setDateFormat:@"dd MMM"];
	return [formatter stringFromDate:[NSString formatStringToDate:self]];
}

- (NSString *)timeFromGMTDateStringToLocalDateString {
	static BOOL isTimeFormat24Hr = YES;

	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSMutableArray *array = [[NSMutableArray alloc] init];
	[array setArray:[[timeFormatter stringFromDate:[NSDate date]] componentsSeparatedByString:@" "]];
	if ([array count] == 1) {
		isTimeFormat24Hr = YES;
	}
	else {
		isTimeFormat24Hr = NO;
	}

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	if (isTimeFormat24Hr) {
		[formatter setDateFormat:@"HH:mm"];
	}
	else {
		[formatter setDateFormat:@"hh:mm a"];
	}
	return [formatter stringFromDate:[NSString formatStringToDate:self]];
}




@end
