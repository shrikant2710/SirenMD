//
//  NSCommonMethod.h
//  Five Lines
//
//  Created by Nakul Sharma on 5/8/15.
//  Copyright (c) 2015 5lines. All rights reserved.
//

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define CONTINUE_IF_MAIN_THREAD if ([NSThread isMainThread] == NO) { NSAssert(FALSE, @"Not called from main thread"); }
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NSCommonMethod : NSObject
@property (nonatomic, strong) AppDelegate *appDelegate;



+ (NSCommonMethod *)sharedInstance;

+ (UIImage *)drawText:(NSMutableString *)text inImage:(UIImage *)image atPoint:(CGPoint)point withColor:(UIColor *)color;
+ (BOOL)validateTextField:(UITextField *)tField;
+ (BOOL)validatePasswordTextField:(UITextField *)tField;
+(BOOL)didWhiteSpacesInTextField:(UITextField *)tField;
+ (BOOL)validateEmailWithString:(NSString *)email;


+ (UIView *)makeViewRounded:(UIView *)view withCornerRadius:(float)cornerRadius withBorderColor:(UIColor *)borderColor withBorderWidth:(float)borderWidth;
+ (void)setPlaceHolderOfTextField:(UITextField *)textField placeHolder:(NSString *)placeHolderText placeHolderColor:(UIColor *)color;
- (void)setBackgroundOnView:(UIView *)view;
- (void)makeNavigationBarTransparentInViewController:(UIViewController *)vc;
@end
