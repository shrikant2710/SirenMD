//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#ifndef ViewController_Macros_h
#define ViewController_Macros_h

#define RETURN_IF_THIS_VIEW_IS_NOT_A_TOPVIEW_CONTROLLER if (self.navigationController) if (!(self.navigationController.topViewController == self)) return;
#define SHOW_ACTIVITY_INDICATOR [[AppCommonFunctions sharedInstance] showActivityIndicator];
#define HIDE_ACTIVITY_INDICATOR [[AppCommonFunctions sharedInstance] stopActivityIndicator];

#define SHOW_STATUS_BAR               [CommonFunctions showStausBar:YES];
#define HIDE_STATUS_BAR               [CommonFunctions showStausBar:NO];

#define SHOW_NAVIGATION_BAR           [self.navigationController setNavigationBarHidden:NO animated:NO]; self.navigationController.navigationBar.translucent = true;

#define HIDE_NAVIGATION_BAR           [self.navigationController setNavigationBarHidden:YES animated:NO];

#define VC_OBJ(x) [[x alloc] init]
#define VC_OBJ_WITH_NIB(x) [[x alloc] initWithNibName : (NSString *)CFSTR(#x) bundle : nil]
#define RESIGN_KEYBOARD [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

#define IOS_STANDARD_COLOR_BLUE                        [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:1]
#define CLEAR_NOTIFICATION_BADGE                       [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

#define FONT_BOLD                  @"OpenSans-Bold"
#define FONT_SEMI_BOLD             @"OpenSans-Semibold"
#define FONT_REGULAR               @"OpenSans-Light"

#define APPDELEGATE                                     ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define HIDE_NETWORK_ACTIVITY_INDICATOR                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#define SHOW_NETWORK_ACTIVITY_INDICATOR                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

#define SCREEN_FRAME_RECT                               [[UIScreen mainScreen] bounds]
#define DEVICE_WIDTH                                    [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT                                   [UIScreen mainScreen].bounds.size.height
#define VIEW_WIDTH                                      [[self view]frame].size.width
#define VIEW_HEIGHT                                     [[self view]frame].size.height

#define DATE_FORMAT_USED @"yyyy'-'MM'-'dd' 'HH':'mm':'ss"

#define NAVIGATION_BAR_HEIGHT 44

#endif
