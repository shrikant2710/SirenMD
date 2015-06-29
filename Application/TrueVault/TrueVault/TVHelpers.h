//
//  TVHelpers.h
//  TrueVault
//
//  Created by Edward Marks on 9/4/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

static inline NSDateFormatter *dateFormatterForCommunicatingWithTrueVault() {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return dateFormatter;
}
