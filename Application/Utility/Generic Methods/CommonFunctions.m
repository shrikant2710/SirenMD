//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import "CommonFunctions.h"
#import "AppDelegate.h"
#import "TSMessage.h"

@implementation CommonFunctions


+ (NSString *)documentsDirectory {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    return [paths objectAtIndex:0];
}

+ (void)openEmail:(NSString *)address {
    NSString *url = [NSString stringWithFormat:@"mailto://%@", address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openPhone:(NSString *)number {
    NSString *url = [NSString stringWithFormat:@"tel://%@", number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openSms:(NSString *)number {
    NSString *url = [NSString stringWithFormat:@"sms://%@", number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openBrowser:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (void)openMap:(NSString *)address {
    NSString *addressText = [address stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", addressText];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (BOOL)isRetinaDisplay {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)setNavigationTitle:(NSString *)title ForNavigationItem:(UINavigationItem *)navigationItem {
    [CommonFunctions setNavigationTitle:title subTitle:nil ForNavigationItem:navigationItem];
}

+ (void)setNavigationTitle:(NSString *)title subTitle:(NSString *)subTitle ForNavigationItem:(UINavigationItem *)navigationItem {
    //title = [title uppercaseString];
    //float width = 320.0f;
    float width = [UIScreen mainScreen].bounds.size.width;
    //float myWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (navigationItem.leftBarButtonItem.customView && navigationItem.rightBarButtonItem.customView) {
        width = width - (navigationItem.leftBarButtonItem.customView.frame.size.width + navigationItem.rightBarButtonItem.customView.frame.size.width + 20);
    }
    else if (navigationItem.leftBarButtonItem.customView && !navigationItem.rightBarButtonItem.customView) {
        width = width - (navigationItem.leftBarButtonItem.customView.frame.size.width * 2);
    }
    else if (!navigationItem.leftBarButtonItem.customView && !navigationItem.rightBarButtonItem.customView) {
        width = width - (2 * navigationItem.rightBarButtonItem.customView.frame.size.width);
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{ NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0] }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize) {320, 20 }
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize textSize = rect.size;
    textSize.height = ceilf(textSize.height);
    textSize.width  = ceilf(textSize.width);
    
    if (textSize.width < width)
        width = textSize.width;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 44.0f)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 6.0f, width, 32.0f)];
    [label setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setShadowColor:[UIColor clearColor]];
    [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [label setText:title];
    [view addSubview:label];
    
    if (subTitle) {
        [label setFrame:CGRectMake(0.0f, 2.0f, width, 20.0f)];
    }
    
    if (subTitle) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 24.0f, width, 20.0f)];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [label setShadowColor:[UIColor clearColor]];
        [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [label setText:subTitle];
        [view addSubview:label];
    }
    
    [navigationItem setTitleView:view];
}


#pragma mark - common method for setting navigation bar background image

+ (void)setNavigationBarBackgroundWithImageName:(NSString *)imageName fromViewController:(UIViewController *)viewController {
    if ([self isNotNull:imageName] && [viewController.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:imageName]
                                                                forBarMetrics:UIBarMetricsDefault];
    }
}

+ (void)setNavigationBarBackgroundWithImage:(UIImage *)image fromViewController:(UIViewController *)viewController {
    if ([self isNotNull:image] && [viewController.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [viewController.navigationController.navigationBar setBackgroundImage:image
                                                                forBarMetrics:UIBarMetricsDefault];
        [viewController.navigationController.navigationBar setTranslucent:YES];
        [viewController.navigationController.navigationBar setOpaque:NO];
    }
}

#pragma mark - common method for setting navigation bar  title image view

+ (void)setNavigationBarTitleImage:(NSString *)imageName WithViewController:(UIViewController *)caller {
    UIImage *imageToUse =    [UIImage imageNamed:imageName];
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imageToUse.size.width, imageToUse.size.height)];
    [titleView setImage:imageToUse];
    [caller.navigationItem setTitleView:titleView];
    
    SEL selector = NSSelectorFromString(@"navigationBarTappedAtCenter");

    [AKSMethods addSingleTapGestureRecogniserTo:titleView forSelector:selector ofObject:ACF];
}

#pragma mark - Common method to add navigation bar buttons

#define MINIMUM_BUTTON_WIDTH_FOR_SINGLE_BUTTONS 40
#define MINIMUM_BUTTON_WIDTH_FOR_DOUBLE_BUTTONS 30

+ (void)processSingleNavigationButtons:(UIButton *)button {
    if ([self isNotNull:button] && (button.frame.size.width < MINIMUM_BUTTON_WIDTH_FOR_SINGLE_BUTTONS)) {
        float x = button.frame.origin.x;
        float y = button.frame.origin.y;
        float w = MINIMUM_BUTTON_WIDTH_FOR_SINGLE_BUTTONS;
        float h = button.frame.size.height;
        [button setFrame:CGRectMake(x, y, w, h)];
    }
}

+ (void)processDoubleNavigationButtons:(UIButton *)button {
    if ([self isNotNull:button] && (button.frame.size.width < MINIMUM_BUTTON_WIDTH_FOR_DOUBLE_BUTTONS)) {
        float x = button.frame.origin.x;
        float y = button.frame.origin.y;
        float w = MINIMUM_BUTTON_WIDTH_FOR_DOUBLE_BUTTONS;
        float h = button.frame.size.height;
        [button setFrame:CGRectMake(x, y, w, h)];
    }
}

/**
 common method to add navigation bar buttons
 */
+ (void)addLeftNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithNegativeSpacerValue:(int)value {
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [leftBarButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName]] forState:UIControlStateHighlighted];
    [leftBarButton setFrame:CGRectMake(0.0f, -5.0f, leftBarButton.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processSingleNavigationButtons:leftBarButton];
    
    SEL selector = NSSelectorFromString(@"onClickOfLeftNavigationBarButton:");

    if ([caller respondsToSelector:selector]) [leftBarButton addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:leftBarButton], nil];
}

+ (void)addRightNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithNegativeSpacerValue:(int)value {
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [rightBarButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName]] forState:UIControlStateHighlighted];
    [rightBarButton setFrame:CGRectMake(0.0f, 0.0f, rightBarButton.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processSingleNavigationButtons:rightBarButton];
    
    SEL selector = NSSelectorFromString(@"onClickOfRightNavigationBarButton:");

    
    if ([caller respondsToSelector:selector]) [rightBarButton addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:rightBarButton], nil];
}

+ (void)addTwoLeftNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withImageName2:(NSString *)imageName2 WithNegativeSpacerValue:(int)value {
    UIButton *leftBarButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton1 setImage:[UIImage imageNamed:imageName1] forState:UIControlStateNormal];
    [leftBarButton1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName1]] forState:UIControlStateHighlighted];
    [leftBarButton1 setFrame:CGRectMake(0.0f, 0.0f, leftBarButton1.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:leftBarButton1];
    
    SEL selector = NSSelectorFromString(@"onClickOfLeftNavigationBarButton1:");

    
    if ([caller respondsToSelector:selector]) [leftBarButton1 addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton1 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    
    UIButton *leftBarButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton2 setImage:[UIImage imageNamed:imageName2] forState:UIControlStateNormal];
    [leftBarButton2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName2]] forState:UIControlStateHighlighted];
    [leftBarButton2 setFrame:CGRectMake(0.0f, 0.0f, leftBarButton2.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:leftBarButton2];

    SEL selector2 = NSSelectorFromString(@"onClickOfLeftNavigationBarButton2:");

    if ([caller respondsToSelector:selector2]) [leftBarButton2 addTarget:caller action:selector2 forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton2 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
                                                negativeSpacer,
                                                [[UIBarButtonItem alloc] initWithCustomView:leftBarButton1],
                                                [[UIBarButtonItem alloc] initWithCustomView:leftBarButton2],
                                                nil];
}

+ (void)addTwoRightNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withImageName2:(NSString *)imageName2 WithNegativeSpacerValue:(int)value {
    UIButton *rightBarButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton1 setImage:[UIImage imageNamed:imageName1] forState:UIControlStateNormal];
    [rightBarButton1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName1]] forState:UIControlStateHighlighted];
    [rightBarButton1 setFrame:CGRectMake(0.0f, 0.0f, rightBarButton1.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:rightBarButton1];
    
    SEL selector = NSSelectorFromString(@"onClickOfRightNavigationBarButton1:");

    
    if ([caller respondsToSelector:selector]) [rightBarButton1 addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton1 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    
    UIButton *rightBarButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton2 setImage:[UIImage imageNamed:imageName2] forState:UIControlStateNormal];
    [rightBarButton2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName2]] forState:UIControlStateHighlighted];
    [rightBarButton2 setFrame:CGRectMake(0.0f, 0.0f, rightBarButton2.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:rightBarButton2];
    
    SEL selector2 = NSSelectorFromString(@"onClickOfRightNavigationBarButton2:");

    
    if ([caller respondsToSelector:selector2]) [rightBarButton2 addTarget:caller action:selector2 forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton2 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil action:nil];
    fixedSpace.width = 10;
    
    negativeSpacer.width = value;
    caller.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                 negativeSpacer,
                                                 [[UIBarButtonItem alloc] initWithCustomView:rightBarButton2],
                                                 fixedSpace,
                                                 [[UIBarButtonItem alloc] initWithCustomView:rightBarButton1],
                                                 nil];
}

/**
 common method to add navigation bar buttons
 */
+ (void)addLeftNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value {
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (title) {
        [leftBarButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName]] forState:UIControlStateHighlighted];
    }
    else {
        [leftBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [leftBarButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName]] forState:UIControlStateHighlighted];
    }
    
    [leftBarButton setFrame:CGRectMake(0.0f, (NAVIGATION_BAR_HEIGHT - leftBarButton.currentImage.size.height) / 2, leftBarButton.currentImage.size.width, leftBarButton.currentImage.size.height)];
    [leftBarButton setTitle:title forState:UIControlStateNormal];
    [leftBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [leftBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    //[[leftBarButton titleLabel]setFont:fontSemiBold17];
    [leftBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self processSingleNavigationButtons:leftBarButton];
    
    SEL selector = NSSelectorFromString(@"onClickOfLeftNavigationBarButton:");

    if ([caller respondsToSelector:selector]) [leftBarButton addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) negativeSpacer.width = value + 16; else negativeSpacer.width = value;
    caller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:leftBarButton], nil];
}



+ (void)addRightNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value {
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (title) {
        [rightBarButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName]] forState:UIControlStateHighlighted];
    }
    else {
        [rightBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [rightBarButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName]] forState:UIControlStateHighlighted];
    }
    
    [rightBarButton setFrame:CGRectMake(0.0f, (NAVIGATION_BAR_HEIGHT - rightBarButton.currentImage.size.height) / 2, rightBarButton.currentImage.size.width, rightBarButton.currentImage.size.height)];
    [rightBarButton setTitle:title forState:UIControlStateNormal];
    [rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [rightBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self processSingleNavigationButtons:rightBarButton];
    
    SEL selector = NSSelectorFromString(@"onClickOfRightNavigationBarButton:");

    
    if ([caller respondsToSelector:selector]) [rightBarButton addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:rightBarButton], nil];
}

+ (void)clearApplicationCaches {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
#if 0
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] cleanDisk];
#endif
    [AKSMethods syncroniseNSUserDefaults];
}

#pragma mark - common method to show toast messages

+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration {
    [TSMessage showNotificationInViewController:viewController title:title subtitle:message image:nil type:type duration:duration callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:NO];
}



#pragma mark - common method to show toast messages

+ (void)showMessageWithTitle:(NSString *)title
                 withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

+ (void)showToastMessageWithMessage:(NSString *)message {
#if 0
    [APPDELEGATE.window.rootViewController.view makeToast:message
                                                 duration:MIN_DUR
                                                 position:@"bottom"
                                                    title:Nil];
#elif 0
    [KVNProgress showErrorWithParameters:@{ KVNProgressViewParameterStatus: message }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MIN_DUR * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CommonFunctions removeActivityIndicator];
    });
#else
   // [AFMInfoBanner showWithText:message style:AFMInfoBannerStyleError andHideAfter:MIN_DUR];
#endif
}


#pragma mark - common method for showing MBProgressHUD Activity Indicator

/*!
 @function	showActivityIndicatorWithText
 @abstract	shows the MBProgressHUD with custom text for information to user.
 @discussion
 MBProgressHUD will be added to window . hence complete ui will be blocked from any user interaction.
 @param	text
 the text which will be shown while showing progress
 */



#define INTENSITY -0.2

+ (UIColor *)lighterColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + INTENSITY, 1.0)
                               green:MIN(g + INTENSITY, 1.0)
                                blue:MIN(b + INTENSITY, 1.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)darkerColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - INTENSITY, 0.0)
                               green:MAX(g - INTENSITY, 0.0)
                                blue:MAX(b - INTENSITY, 0.0)
                               alpha:a];
    return nil;
}

/*!
 @function	removeActivityIndicator
 @abstract	removes the MBProgressHUD (if any) from window.
 */

+ (void)removeActivityIndicator {
    [self performSelectorOnMainThread:@selector(removeActivityIndicatorPrivate) withObject:nil waitUntilDone:YES];
}

+ (void)removeActivityIndicatorPrivate {
    HIDE_ACTIVITY_INDICATOR
}

#pragma mark - common method for Internet reachability checking

/*!
 @function	getStatusForNetworkConnectionAndShowUnavailabilityMessage
 @abstract	get internet reachability status and optionally can show network unavailability message.
 @param	showMessage
 to decide whether to show network unreachability message.
 */


+ (BOOL)isSuccess:(NSMutableDictionary *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        if ([[[response objectForKey:@"replyCode"] uppercaseString]isEqualToString:@"SUCCESS"]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)validateNotNullObject:(id)object WithIdentifier:(NSString *)identifier {
    if (object == nil) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please add %@", identifier]];
        return FALSE;
    }
    return TRUE;
}

+ (BOOL)validateNormalTextWithString:(NSString *)text WithIdentifier:(NSString *)identifier {
    if ((text == nil) || (text.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    return TRUE;
}

+ (BOOL)validateEmailWithString:(NSString *)email WithIdentifier:(NSString *)identifier {
    if ((email == nil) || (email.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:email]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter valid %@", identifier]];
        return FALSE;
    }
    else return TRUE;
}

+ (BOOL)validateUserNameWithString:(NSString *)name WithIdentifier:(NSString *)identifier {
    if ((name == nil) || (name.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    if ((name.length < MINIMUM_LENGTH_LIMIT_USERNAME)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ should contain atleast %d characters", identifier, MINIMUM_LENGTH_LIMIT_USERNAME]];
        return FALSE;
    }
    if ((name.length > MAXIMUM_LENGTH_LIMIT_USERNAME)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ can contain atmost %d characters", identifier, MAXIMUM_LENGTH_LIMIT_USERNAME]];
        return FALSE;
    }
    NSString *nameRegex = @"[a-zA-Z0-9_.@]+$";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    if (![nameTest evaluateWithObject:name]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter valid %@", identifier]];
        return FALSE;
    }
    else return TRUE;
}

+ (BOOL)validateNameWithString:(NSString *)name WithIdentifier:(NSString *)identifier {
    if ((name == nil) || (name.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    if ((name.length < MINIMUM_LENGTH_LIMIT_FIRST_NAME)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ should contain atleast %d characters", identifier, MINIMUM_LENGTH_LIMIT_FIRST_NAME]];
        return FALSE;
    }
    if ((name.length > MAXIMUM_LENGTH_LIMIT_FIRST_NAME)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ can contain atmost %d characters", identifier, MAXIMUM_LENGTH_LIMIT_FIRST_NAME]];
        return FALSE;
    }
    NSString *nameRegex = @"[a-zA-Z0-9_.@ ]+$";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    if (![nameTest evaluateWithObject:name]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter valid %@", identifier]];
        return FALSE;
    }
    else return TRUE;
}

+ (BOOL)validatePasswordWithString:(NSString *)password WithIdentifier:(NSString *)identifier {
    if ((password == nil) || (password.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    if ([[password substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ cannot start with spaces", identifier]];
        return FALSE;
    }
    if (([password length] > 1) && [[password substringWithRange:NSMakeRange(password.length - 1, 1)] isEqualToString:@" "]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ cannot end with spaces", identifier]];
        return FALSE;
    }
    if ((password.length < MINIMUM_LENGTH_LIMIT_PASSWORD)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ should contain atleast %d characters", identifier, MINIMUM_LENGTH_LIMIT_PASSWORD]];
        return FALSE;
    }
    if ((password.length > MAXIMUM_LENGTH_LIMIT_PASSWORD)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"%@ can contain atmost %d characters", identifier, MAXIMUM_LENGTH_LIMIT_PASSWORD]];
        return FALSE;
    }
    return TRUE;
}

+ (BOOL)validatePhoneNumberWithString:(NSString *)number WithIdentifier:(NSString *)identifier {
    if ((number == nil) || (number.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    
    NSString *numberRegex = @"[0-9]+$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    
    if (![numberTest evaluateWithObject:number]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter valid %@", identifier]];
        return FALSE;
    }
    else return TRUE;
}

+ (BOOL)validatePinCodeWithString:(NSString *)number WithIdentifier:(NSString *)identifier {
    if ((number == nil) || (number.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    
    if (number.length != 6) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter 6 digit %@", identifier]];
        return FALSE;
    }
    
    NSString *numberRegex = @"[0-9]+$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    
    if (![numberTest evaluateWithObject:number]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter valid %@", identifier]];
        return FALSE;
    }
    else
        return TRUE;
}

+ (BOOL)validateNumberWithString:(NSString *)number WithIdentifier:(NSString *)identifier {
    if ((number == nil) || (number.length == 0)) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter %@", identifier]];
        return FALSE;
    }
    
    NSString *numberRegex = @"[0-9]+$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    
    if (![numberTest evaluateWithObject:number]) {
        [CommonFunctions showToastMessageWithMessage:[NSMutableString stringWithFormat:@"Please enter valid %@", identifier]];
        return FALSE;
    }
    else
        return TRUE;
}

+ (void)openLocationInMapWithLatitude:(double)lat WithLongitide:(double)lon WithName:(NSString *)placeName {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:placeName];
        [mapItem openInMapsWithLaunchOptions:nil];
    }
}

+ (NSString *)getDeviceSpecificImageNameForName:(NSString *)name {
    NSString *fileName1 = name;
    NSString *fileName2;
    DeviceSize deviceSize = [SDiPhoneVersion deviceSize];
    switch (deviceSize) {
        case iPhone35inch:
            fileName2 = [NSString stringWithFormat:@"%@35inch", name];
            break;
            
        case iPhone4inch:
            fileName2 = [NSString stringWithFormat:@"%@4inch", name];
            break;
            
        case iPhone47inch:
            fileName2 = [NSString stringWithFormat:@"%@47inch", name];
            break;
            
        case iPhone55inch:
            fileName2 = [NSString stringWithFormat:@"%@55inch", name];
            break;
            
        case iPad:
            fileName2 = [NSString stringWithFormat:@"%@iPad", name];
            break;
            
        default:
            break;
    }
    if ([self isNotNull:[UIImage imageNamed:fileName2]]) {
        return fileName2;
    }
    else if ([self isNotNull:[UIImage imageNamed:fileName1]]) {
        return fileName1;
    }
    else {
        return name;
    }
}

+ (void)setPaddingOf:(int)padding onTextFeild:(UITextField *)textfeild {
    UIView *paddingView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, padding, 10)];
    UIView *paddingView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, padding, 10)];
    textfeild.leftView = paddingView1;
    textfeild.leftViewMode = UITextFieldViewModeAlways;
    textfeild.rightView = paddingView2;
    textfeild.rightViewMode = UITextFieldViewModeAlways;
}

+ (void)showStausBar:(BOOL)show {
    [[UIApplication sharedApplication]setStatusBarHidden:!show withAnimation:UIStatusBarAnimationNone];
}

+ (NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat = 0;
    NSInteger lng = 0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        }
        while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        }
        while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    
    return array;
}

+ (void)addLeftNavigationBarEditButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value object:(UIViewController *)vc {
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [leftBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    
    
    [leftBarButton setFrame:CGRectMake(0.0f, (NAVIGATION_BAR_HEIGHT - leftBarButton.currentImage.size.height) / 2, leftBarButton.currentImage.size.width, leftBarButton.currentImage.size.height)];
    [leftBarButton setTitle:title forState:UIControlStateNormal];
    [leftBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [leftBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    UIFont *fontSemiBold17 = [UIFont fontWithName:FONT_SEMI_BOLD size:17];

    [[leftBarButton titleLabel]setFont:fontSemiBold17];
    [leftBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self processSingleNavigationButtons:leftBarButton];
    
    
    SEL selector2 = NSSelectorFromString(@"onClickOfCustomisedLeftNavigationBarButton:");

    
    if ([vc respondsToSelector:selector2]) [leftBarButton addTarget:vc action:selector2 forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton method\n", [AKSMethods getClassNameForObject:vc]);
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) negativeSpacer.width = value + 16; else negativeSpacer.width = value;
    caller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:leftBarButton], nil];
}

+ (void)addLeftNavigationBarEditButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value {
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [leftBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    
    
    [leftBarButton setFrame:CGRectMake(0.0f, (NAVIGATION_BAR_HEIGHT - leftBarButton.currentImage.size.height) / 2, leftBarButton.currentImage.size.width , leftBarButton.currentImage.size.height)];
    [leftBarButton setTitle:title forState:UIControlStateNormal];
    [leftBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [leftBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    UIFont *fontSemiBold17 = [UIFont fontWithName:FONT_SEMI_BOLD size:17];

    [[leftBarButton titleLabel]setFont:fontSemiBold17];
    [leftBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self processSingleNavigationButtons:leftBarButton];
    
    
    SEL selector = NSSelectorFromString(@"onClickOfLeftNavigationBarButton:");

    if ([caller respondsToSelector:selector]) [leftBarButton addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) negativeSpacer.width = value + 16; else negativeSpacer.width = value;
    caller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:leftBarButton], nil];
}

+ (void)addTwoLeftNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withTitleName2:(NSString *)titleName2 WithNegativeSpacerValue:(int)value {
    UIButton *leftBarButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton1 setImage:[UIImage imageNamed:imageName1] forState:UIControlStateNormal];
    [leftBarButton1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName1]] forState:UIControlStateHighlighted];
    [leftBarButton1 setFrame:CGRectMake(0.0f, 0.0f, leftBarButton1.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:leftBarButton1];
    
    SEL selector = NSSelectorFromString(@"onClickOfLeftNavigationBarButton1:");

    
    if ([caller respondsToSelector:selector]) [leftBarButton1 addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton1 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    
    UIButton *leftBarButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [leftBarButton2 setTitle:titleName2 forState:UIControlStateNormal];
    [leftBarButton2 setTitle:titleName2 forState:UIControlStateHighlighted];
    [leftBarButton2 setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [leftBarButton2 setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    [leftBarButton2 setFrame:CGRectMake(0.0f, 0.0f, leftBarButton2.imageView.image.size.width , NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:leftBarButton2];
    
    SEL selector2 = NSSelectorFromString(@"onClickOfLeftNavigationBarButton2:");

    
    if ([caller respondsToSelector:selector2]) [leftBarButton2 addTarget:caller action:selector2  forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfLeftNavigationBarButton2 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
                                                negativeSpacer,
                                                [[UIBarButtonItem alloc] initWithCustomView:leftBarButton1],
                                                [[UIBarButtonItem alloc] initWithCustomView:leftBarButton2],
                                                nil];
}

+ (void)addTwoRightNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withTitleName2:(NSString *)titleName2 WithNegativeSpacerValue:(int)value {
    UIButton *rightBarButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton1 setImage:[UIImage imageNamed:imageName1] forState:UIControlStateNormal];
    [rightBarButton1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hover", imageName1]] forState:UIControlStateHighlighted];
    [rightBarButton1 setFrame:CGRectMake(0.0f, 0.0f, rightBarButton1.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:rightBarButton1];
    
    SEL selector = NSSelectorFromString(@"onClickOfRightNavigationBarButton1:");

    
    if ([caller respondsToSelector:selector]) [rightBarButton1 addTarget:caller action:selector forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton1 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    
    UIButton *rightBarButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [rightBarButton2 setTitle:titleName2 forState:UIControlStateNormal];
    [rightBarButton2 setTitle:titleName2 forState:UIControlStateHighlighted];
    [rightBarButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBarButton2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [rightBarButton2 setFrame:CGRectMake(0.0f, 0.0f, rightBarButton2.imageView.image.size.width , NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:rightBarButton2];
    
    SEL selector2 = NSSelectorFromString(@"onClickOfRightNavigationBarButton2:");

    
    if ([caller respondsToSelector:selector2]) [rightBarButton2 addTarget:caller action:selector2 forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton2 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                 negativeSpacer,
                                                 [[UIBarButtonItem alloc] initWithCustomView:rightBarButton1],
                                                 [[UIBarButtonItem alloc] initWithCustomView:rightBarButton2],
                                                 nil];
}

+ (void)addTwoRightNavigationBarButton:(UIViewController *)caller withTitleName1:(NSString *)titleName1 withTitleName2:(NSString *)titleName2 WithNegativeSpacerValue:(int)value {
    UIButton *rightBarButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton1 setTitle:titleName1 forState:UIControlStateNormal];
    [rightBarButton1 setTitle:titleName1 forState:UIControlStateHighlighted];
    [rightBarButton1 setFrame:CGRectMake(0.0f, 0.0f, rightBarButton1.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:rightBarButton1];
    
    
    SEL selector2 = NSSelectorFromString(@"onClickOfRightNavigationBarButton1:");

    if ([caller respondsToSelector:selector2]) [rightBarButton1 addTarget:caller action:selector2 forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton1 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    
    UIButton *rightBarButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [rightBarButton2 setTitle:titleName2 forState:UIControlStateNormal];
    [rightBarButton2 setTitle:titleName2 forState:UIControlStateHighlighted];
    [rightBarButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBarButton2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [rightBarButton2 setFrame:CGRectMake(0.0f, 0.0f, rightBarButton2.imageView.image.size.width, NAVIGATION_BAR_HEIGHT)];
    [self processDoubleNavigationButtons:rightBarButton2];
    
    SEL selector3 = NSSelectorFromString(@"onClickOfRightNavigationBarButton2:");

    if ([caller respondsToSelector:selector3]) [rightBarButton2 addTarget:caller action:selector3 forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton2 method\n", [AKSMethods getClassNameForObject:caller]);
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                 negativeSpacer,
                                                 [[UIBarButtonItem alloc] initWithCustomView:rightBarButton1],
                                                 [[UIBarButtonItem alloc] initWithCustomView:rightBarButton2],
                                                 nil];
}

+ (void)addRightNavigationBarEditButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value {
    //////////////////////////////////////////////////////////////////////
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [rightBarButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    [rightBarButton setTitle:title forState:UIControlStateNormal];
    [rightBarButton setTitle:title forState:UIControlStateHighlighted];
    
    [rightBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [rightBarButton setTitleColor:[UIColor colorWithRed:32.0f / 255.0f green:121.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    [rightBarButton setFrame:CGRectMake(0.0f, (NAVIGATION_BAR_HEIGHT - rightBarButton.currentImage.size.height) / 2, rightBarButton.currentImage.size.width, rightBarButton.currentImage.size.height)];
    
     UIFont *fontSemiBold17 = [UIFont fontWithName:FONT_SEMI_BOLD size:17];

    [[rightBarButton titleLabel]setFont:fontSemiBold17];
    [rightBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self processSingleNavigationButtons:rightBarButton];
    
    SEL selector2 = NSSelectorFromString(@"onClickOfRightNavigationBarButton:");

    
    if ([caller respondsToSelector:selector2]) [rightBarButton addTarget:caller action:selector2 forControlEvents:UIControlEventTouchUpInside];
    else {
        NSLog(@"\n\n%@ class forgets to implement onClickOfRightNavigationBarButton method\n", [AKSMethods getClassNameForObject:caller]);
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = value;
    caller.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:rightBarButton], nil];
}

+ (void)registerTableView:(UITableView *)tableView forCellNibWithClassName:(Class)classObject {
    [tableView registerNib:[UINib nibWithNibName:[classObject description] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[classObject description]];
}

+ (NSData *)getCompressedDataForImage:(UIImage *)image {
    CGFloat compression = 0.000009f;
    CGFloat maxCompression = 0.0000001f;
    int maxFileSize = 200 * 1024;
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    return imageData;
}

+ (NSData *)getBase64DataforData:(NSData *)imageData andImage:(UIImage *)image ofsizeInKB:(int)kBsize {
    if ((imageData.length / 1024) >= kBsize) {
        while ((imageData.length / 1024) >= kBsize) {
//            CGSize currentSize = CGSizeMake(image.size.width, image.size.height);
            // image = [image resizedImage:CGSizeMake(roundf(((currentSize.width / 100) * 80)), roundf(((currentSize.height / 100) * 80))) interpolationQuality:2];
            imageData = UIImageJPEGRepresentation(image, 0);
        }
    }
    return imageData;
}

@end
