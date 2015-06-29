////
////  Service.h
////  Fleetzen
////
////  Created by Sarthak Gupta on 18/10/14.
////  Copyright (c) 2014 Sarthak Gupta. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "AFHTTPRequestOperationManager.h"
////#import "Define.h"
//
//@interface Service : AFHTTPRequestOperationManager
//
//+ (Service*)sharedInstance;
//- (void)getAddressLocation :(NSString*)str;
//-(void) getDistanceOfLAtLong:(NSMutableArray *)providerArray;

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface Service : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
