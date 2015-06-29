//
//  NSCommonMethod.m
//  Five Lines
//
//  Created by user on 5/8/15.
//  Copyright (c) 2015 5lines. All rights reserved.
//
#define  NAVIGATION_BAR_HEIGHT 44
#define SHOW_STATUS_BAR               [CommonFunctions showStausBar:YES];
#define HIDE_STATUS_BAR               [CommonFunctions showStausBar:NO];

#define SHOW_NAVIGATION_BAR           [self.navigationController setNavigationBarHidden:NO animated:NO]; self.navigationController.navigationBar.translucent = true;

#define HIDE_NAVIGATION_BAR           [self.navigationController setNavigationBarHidden:YES animated:NO];

#import "NSCommonMethod.h"
#import "SDiPhoneVersion.h"

@implementation NSCommonMethod
@synthesize appDelegate;
#pragma mark - initializer methods

static NSCommonMethod *singletonInstance = nil;

+ (NSCommonMethod *)sharedInstance {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (singletonInstance == nil) {
            singletonInstance = [[NSCommonMethod alloc]init];
            singletonInstance.appDelegate = APPDELEGATE;
        }
    });
    return singletonInstance;
}

#pragma -set placeholder color
+ (void)setPlaceHolderOfTextField:(UITextField *)textField placeHolder:(NSString *)placeHolderText placeHolderColor:(UIColor *)color {
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText attributes:@{ NSForegroundColorAttributeName: color }];
}

#pragma draw text on image
+ (UIImage *)drawText:(NSMutableString *)text inImage:(UIImage *)image atPoint:(CGPoint)point withColor:(UIColor *)color {
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    NSDictionary *attributes = @{ NSFontAttributeName:font, NSForegroundColorAttributeName:color };
    [text drawInRect:CGRectIntegral(rect) withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma -
#pragma -validation of Text Fields
+ (BOOL)validateTextField:(UITextField *)tField {
    if ([tField.text length] > 0 && ![self didWhiteSpacesInTextField:tField]) {
        return YES;
    }
    return NO;
}

+ (BOOL)didWhiteSpacesInTextField:(UITextField *)tField {
    NSString *text = tField.text;
    NSRange whiteSpaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
        return YES;//white spaces are there
    }
    return NO;
}

+ (BOOL)validatePasswordTextField:(UITextField *)tField {
    if ([tField.text length] > 5 && ![self didWhiteSpacesInTextField:tField]) {
        return YES;
    }
    return NO;
}

+ (UIView *)makeViewRounded:(UIView *)view withCornerRadius:(float)cornerRadius withBorderColor:(UIColor *)borderColor withBorderWidth:(float)borderWidth {
    view.layer.cornerRadius = cornerRadius;
    view.layer.borderColor = borderColor.CGColor;
    view.layer.borderWidth = borderWidth;
    view.layer.masksToBounds = YES;
    return view;
}

#pragma -
#pragma NavigationBar Setup

+ (void)setNavigationTitle:(NSString *)title ForNavigationItem:(UINavigationItem *)navigationItem {
    title = [title uppercaseString];
    float width = 320.0f;
    
    if (navigationItem.leftBarButtonItem.customView && navigationItem.rightBarButtonItem.customView) {
        width = 320 - (navigationItem.leftBarButtonItem.customView.frame.size.width + navigationItem.rightBarButtonItem.customView.frame.size.width + 20);
    }
    else if (navigationItem.leftBarButtonItem.customView && !navigationItem.rightBarButtonItem.customView) {
        width = 320 - (navigationItem.leftBarButtonItem.customView.frame.size.width * 2);
    }
    else if (!navigationItem.leftBarButtonItem.customView && !navigationItem.rightBarButtonItem.customView) {
        width = 320 - (2 * navigationItem.rightBarButtonItem.customView.frame.size.width);
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{ NSFontAttributeName: [UIFont fontWithName:@"System" size:20.0] }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize) {320, 20 }
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize textSize = rect.size;
    textSize.height = ceilf(textSize.height);
    textSize.width  = ceilf(textSize.width);
    
    if (textSize.width < width)
        width = textSize.width;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 44.0f)];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 6.0f, width, 32.0f)];
    
    //[titleLbl setFont:[UIFont fontWithName:FONT_SEMI_BOLD size:17.0]];
    [titleLbl setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [titleLbl setBackgroundColor:[UIColor clearColor]];
    [titleLbl setTextAlignment:NSTextAlignmentCenter];
    [titleLbl setTextColor:[UIColor whiteColor]];
    [titleLbl setShadowColor:[UIColor clearColor]];
    [titleLbl setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [titleLbl setText:title];
    
    [view addSubview:titleLbl];
    
    [navigationItem setTitleView:view];
}

- (void)makeNavigationBarTransparentInViewController:(UIViewController *)vc {
    [vc.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                forBarMetrics:UIBarMetricsDefault];
    vc.navigationController.navigationBar.shadowImage = [UIImage new];
    vc.navigationController.navigationBar.translucent = YES;
    vc.navigationController.view.backgroundColor = [UIColor clearColor];
    vc.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

#pragma -
#pragma - to set the background of View
- (void)setBackgroundOnView:(UIView *)view {
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        NSString *bgImageName = @"bg640*960";
        view.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:bgImageName]];
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone4inch) {
        NSString *bgImageName = @"bg640*1136";
        view.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:bgImageName]];
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        NSString *bgImageName = @"bg750*1334";
        view.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:bgImageName]];
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        NSString *bgImageName = @"bg1242*2208";
        view.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:bgImageName]];
    }
}

#pragma mark - Common method to add navigation bar buttons

#define MINIMUM_BUTTON_WIDTH_FOR_SINGLE_BUTTONS 40
#define MINIMUM_BUTTON_WIDTH_FOR_DOUBLE_BUTTONS 30



+ (BOOL)validateEmailWithString:(NSString *)email {
    if ((email == nil) || (email.length == 0)) {
        return FALSE;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:email]) {
        return FALSE;
    }
    else return TRUE;
}

@end
