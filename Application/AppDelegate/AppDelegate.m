//
//  Created by Alok Kumar Singh on 01/03/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import "AppDelegate.h"
#import "AppCommonFunctions.h"
#import "TrueVault.h"
#import <Instabug/Instabug.h>
@implementation AppDelegate
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initializeGlobalData];
    [self initializeContents];
    [self prepareForApplePushNotificationsService:application];
    [self initializeWindowAndStartUpViewController];
    [self afterInitialisationSetup];
    
#if TARGET_IPHONE_SIMULATOR
    NSString *hello = @"Hello, iPhone simulator!";
#elif TARGET_OS_IPHONE
    [Instabug startWithToken:@"95fa0b79f120cf97b7d67381e3a26b93" captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventShake];
#else
    [Instabug startWithToken:@"95fa0b79f120cf97b7d67381e3a26b93" captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventShake];
#endif
    
    [TrueVault setVaultID:VaultID APIKey:APIKEYTrueVault];

    return YES;
}

- (void)initializeGlobalData {
   
    CGFloat red = 13.0 / 255.0; CGFloat green = 93.0 / 255.0; CGFloat blue = 183.0 / 255.0;
    navigationBarBackgroundImage1 = [UIImage imageWithColor:[UIColor colorWithRed:red green:green blue:blue alpha:0.9] size:CGSizeMake(320, 64)];
}

- (void)initializeContents {
    navigationController = (UINavigationController *)self.window.rootViewController;
    [ACF prepareStartup];
    if ([AKSMethods isApplicationUpdated]) {
        [CommonFunctions clearApplicationCaches];
    }
    if ([self isNull:PUSH_NOTIFICATION_TOKEN] || ((NSString *)PUSH_NOTIFICATION_TOKEN).length == 0) {
        //[[NSUserDefaults standardUserDefaults]setObject:@"CD9B999D192133CB346602713B1D831D24896939444B42A97CFE380FADA3098A" forKey:PUSH_NOTIFICATION_DEVICE_TOKEN];
    }
}

#pragma mark - Methods for initialising window and startup view controllers

- (void)initializeWindowAndStartUpViewController {
    [self prepareViews];
    [self.window setBackgroundColor:[UIColor blackColor]];
    [self.window makeKeyAndVisible];
}

- (void)afterInitialisationSetup {
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {
}

- (void)prepareViews {
    HIDE_STATUS_BAR
}

#pragma mark - Local Notifications Delegate Methods

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
}

#pragma mark - Apple Push Notifications Service Methods

- (void)prepareForApplePushNotificationsService:(UIApplication *)application {
    CLEAR_NOTIFICATION_BADGE
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:@"declineAction"]) {
    }
    else if ([identifier isEqualToString:@"answerAction"]) {
    }
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSUserDefaults standardUserDefaults]setObject:[AKSMethods stringWithDeviceToken:deviceToken] forKey:PUSH_NOTIFICATION_DEVICE_TOKEN];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Push notification failed");
    [[NSUserDefaults standardUserDefaults]setObject:@"CD9B999D192133CB346602713B1D831D24896939444B42A97CFE380FADA3098A" forKey:PUSH_NOTIFICATION_DEVICE_TOKEN];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return YES;
}

#pragma mark - Application Life Cycle Methods

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - Memory management methods

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [CommonFunctions clearApplicationCaches];
}

@end
