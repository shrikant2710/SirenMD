//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#ifndef UIDevice_Macros_h
#define UIDevice_Macros_h

#define CURRENT_DEVICE_VERSION_FLOAT  [[UIDevice currentDevice] systemVersion].floatValue
#define CURRENT_DEVICE_VERSION_STRING [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define IS_CAMERA_AVAILABLE [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]

#define FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE     if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) self.edgesForExtendedLayout = UIRectEdgeNone;

/*
 Message Okay button title for all alerts in the application
 */
#define MESSAGE_OKAY_BUTTON_NAME    @"Ok"
#define MESSAGE_CANCEL_BUTTON_NAME  @"Cancel"

//1>
#define MESSAGE_TITLE___FOR_NETWORK_NOT_REACHABILITY   @"Oops!"
#define MESSAGE_TEXT___FOR_NETWORK_NOT_REACHABILITY    @"No internet connection detected."

//2>
#define MESSAGE_TITLE___FOR_SERVER_NOT_REACHABILITY   @"Oops!"
#define MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY    @"There is a network error. Please try again!"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
