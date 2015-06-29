//
//  NSDate+HumanInterval.m
//  Buzzalot
//
//  Created by David E. Wheeler on 2/18/10.
//  Copyright 2010-2011 Lunar/Theory. All rights reserved.
//

#import"NSDate+Customised HumanInterval.h"

#define S   1
#define M   (60 * S)
#define H   (60 * M)
#define D   (24 * H)
#define W   (7 * D)
#define Mth (30 * D)
#define Y   (365 * D)

@implementation NSDate (HumanInterval)

- (NSString *)humanIntervalSinceNow {
	int delta = [self timeIntervalSinceNow];

	if (delta < 0) {
		return [self description];
	}
	else if (delta < 1 * M) {
		return @"0M";
	}
	else if (delta < 2 * M) {
		return @"1M";
	}
	else if (delta <= 45 * M) {
		return [NSString stringWithFormat:@"%uM", delta / M];
	}
	else if (delta <= 90 * M) {
		return @"1H";
	}
	else if (delta < 3 * H) {
		return @"2H";
	}
	else if (delta < 23 * H) {
		return [NSString stringWithFormat:@"%uH", delta / H];
	}
	else if (delta < 36 * H) {
		return @"1D";
	}
	else if (delta < 72 * H) {
		return @"2D";
	}
	else if (delta < 7 * D) {
		return [NSString stringWithFormat:@"%uD", delta / D];
	}
	else if (delta < 11 * D) {
		return @"1W";
	}
	else if (delta < 14 * D) {
		return @"2W";
	}
	else if (delta < 9 * W) {
		return [NSString stringWithFormat:@"%uW", delta / W];
	}
	else if (delta < 19 * Mth) {
		return [NSString stringWithFormat:@"%uMth", delta / Mth];
	}
	else if (delta < 2 * Y) {
		return @"1Y";
	}
	else {
		return [NSString stringWithFormat:@"%uY", delta / Y];
	}
}

- (NSString *)humanIntervalAgo {
	int delta = [self timeIntervalSinceNow];
	delta *= -1;
	if (delta < 0) {
		return [self description];
	}
	else if (delta < 1 * M) {
		return @"0M";
	}
	else if (delta < 2 * M) {
		return @"1M";
	}
	else if (delta <= 45 * M) {
		return [NSString stringWithFormat:@"%uM", delta / M];
	}
	else if (delta <= 90 * M) {
		return @"1H";
	}
	else if (delta < 3 * H) {
		return @"2H";
	}
	else if (delta < 23 * H) {
		return [NSString stringWithFormat:@"%uH", delta / H];
	}
	else if (delta < 36 * H) {
		return @"1D";
	}
	else if (delta < 72 * H) {
		return @"2D";
	}
	else if (delta < 7 * D) {
		return [NSString stringWithFormat:@"%uD", delta / D];
	}
	else if (delta < 11 * D) {
		return @"1W";
	}
	else if (delta < 14 * D) {
		return @"2W";
	}
	else if (delta < 9 * W) {
		return [NSString stringWithFormat:@"%uW", delta / W];
	}
	else if (delta < 19 * Mth) {
		return [NSString stringWithFormat:@"%uMth", delta / Mth];
	}
	else if (delta < 2 * Y) {
		return @"1Y";
	}
	else {
		return [NSString stringWithFormat:@"%uY", delta / Y];
	}
}

@end
