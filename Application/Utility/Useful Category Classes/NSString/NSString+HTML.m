//
//  NSString+HTML.m
//  MWFeedParser
//
//  Copyright (c) 2010 Michael Waterfall
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the
//     purpose of any concept relating to diary/journal keeping.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSString+HTML.h"

@implementation NSString (HTML)

#pragma mark -
#pragma mark Class Methods

#pragma mark -
#pragma mark Instance Methods

- (NSString *)stringByRemovingNewLinesAndWhitespace {
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
	                                                  [NSString stringWithFormat:@" \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	while (![scanner isAtEnd]) {
		temp = nil;
		[scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
		if (temp) [result appendString:temp];
		if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
			if (result.length > 0 && ![scanner isAtEnd])             // Dont append space to beginning or end of result
				[result appendString:@" "];
		}
	}
	return [NSString stringWithString:result];
}

- (NSString *)stringByURLDecode {
	NSMutableString *tempStr = [NSMutableString stringWithString:self];
	[tempStr replaceOccurrencesOfString:@"+" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];

	return [[NSString stringWithFormat:@"%@", tempStr] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL *)urlByURLDecode {
	NSMutableString *tempStr = [NSMutableString stringWithString:self];
	[tempStr replaceOccurrencesOfString:@"+" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
	return [NSURL URLWithString:[[NSString stringWithFormat:@"%@", tempStr] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *)stringByURLEncode {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8));
}

@end
