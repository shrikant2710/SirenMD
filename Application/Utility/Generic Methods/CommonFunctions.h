//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MapKit/MapKit.h>

/**
 
 CommonFunctions:-
 
 This singleton class implements some generic methods which are frequently needed in application.
 
 */
@interface CommonFunctions : NSObject

+ (NSString *)documentsDirectory;
+ (void)openEmail:(NSString *)address;
+ (void)openPhone:(NSString *)number;
+ (void)openSms:(NSString *)number;
+ (void)openBrowser:(NSString *)url;
+ (void)openMap:(NSString *)address;
+ (void)setNavigationBarBackgroundWithImageName:(NSString *)imageName fromViewController:(UIViewController *)viewController;
+ (void)setNavigationBarBackgroundWithImage:(UIImage *)image fromViewController:(UIViewController *)viewController;
+ (void)setNavigationTitle:(NSString *)title ForNavigationItem:(UINavigationItem *)navigationItem;
+ (void)setNavigationTitle:(NSString *)title subTitle:(NSString *)subTitle ForNavigationItem:(UINavigationItem *)navigationItem;
+ (void)setNavigationBarTitleImage:(NSString *)imageName WithViewController:(UIViewController *)caller;
+ (void)clearApplicationCaches;
+ (void)addLeftNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithNegativeSpacerValue:(int)value;
+ (void)addRightNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithNegativeSpacerValue:(int)value;
+ (void)addLeftNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value;
+ (void)addRightNavigationBarButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value;
+ (void)addTwoLeftNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withImageName2:(NSString *)imageName2 WithNegativeSpacerValue:(int)value;
+ (void)addTwoRightNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withImageName2:(NSString *)imageName2 WithNegativeSpacerValue:(int)value;
+ (void)removeActivityIndicator;
+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration;

+ (void)showMessageWithTitle:(NSString *)title
                 withMessage:(NSString *)message;
+ (void)showToastMessageWithMessage:(NSString *)message;
+ (BOOL)validateNotNullObject:(id)object WithIdentifier:(NSString *)identifier;
+ (BOOL)validateNormalTextWithString:(NSString *)text WithIdentifier:(NSString *)identifier;
+ (BOOL)validateEmailWithString:(NSString *)email WithIdentifier:(NSString *)identifier;
+ (BOOL)validatePasswordWithString:(NSString *)password WithIdentifier:(NSString *)identifier;
+ (BOOL)validateUserNameWithString:(NSString *)name WithIdentifier:(NSString *)identifier;
+ (BOOL)validateNameWithString:(NSString *)name WithIdentifier:(NSString *)identifier;
+ (BOOL)validatePhoneNumberWithString:(NSString *)number WithIdentifier:(NSString *)identifier;
+ (BOOL)validatePinCodeWithString:(NSString *)number WithIdentifier:(NSString *)identifier;
+ (BOOL)validateNumberWithString:(NSString *)number WithIdentifier:(NSString *)identifier;
+ (void)openLocationInMapWithLatitude:(double)lat WithLongitide:(double)lon WithName:(NSString *)placeName;
+ (NSString *)getDeviceSpecificImageNameForName:(NSString *)name;
+ (void)setPaddingOf:(int)padding onTextFeild:(UITextField *)textfeild;
+ (void)showStausBar:(BOOL)show;
+ (NSMutableArray *)decodePolyLine:(NSString *)encodedStr;
+ (void)addLeftNavigationBarEditButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value;
+ (void)addTwoLeftNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withTitleName2:(NSString *)titleName2 WithNegativeSpacerValue:(int)value;
+ (void)addTwoRightNavigationBarButton:(UIViewController *)caller withImageName1:(NSString *)imageName1 withTitleName2:(NSString *)titleName2 WithNegativeSpacerValue:(int)value;
+ (void)addTwoRightNavigationBarButton:(UIViewController *)caller withTitleName1:(NSString *)titleName1 withTitleName2:(NSString *)titleName2 WithNegativeSpacerValue:(int)value;
+ (void)addRightNavigationBarEditButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value;
+ (void)addLeftNavigationBarEditButton:(UIViewController *)caller withImageName:(NSString *)imageName WithTitle:(NSString *)title WithNegativeSpacerValue:(int)value object:(UIViewController *)vc;
+ (void)registerTableView:(UITableView *)tableView forCellNibWithClassName:(Class)classObject;
+ (NSData *)getCompressedDataForImage:(UIImage *)image;
+ (NSData *)getBase64DataforData:(NSData *)imageData andImage:(UIImage *)image ofsizeInKB:(int)kBsize;

@end
