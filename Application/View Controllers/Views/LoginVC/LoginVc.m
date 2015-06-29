//
//  LoginVc.m
//  SirenMD
//
//  Created by Shrikant  on 5/26/15.
//  Copyright (c) 2015 Shrikant . All rights reserved.
//

#import "LoginVc.h"
#import "CasesVC.h"
#import "AppDelegate.h"
#import "AppCommonFunctions.h"
#import "NSCommonMethod.h"
#import "ResendPasswordVC.h"
#import "SDiPhoneVersion.h"
#import "TermsVC.h"
#import "Service.h"
#import "AppCommonFunctions.h"
#import "TVRequest.h"
#import "TVObject.h"
#import "TVHelper.h"
#import <LocalAuthentication/LocalAuthentication.h>

@class AppCommonFunctions;
@interface LoginVc ()

@property(strong,nonatomic)NSTimer *timer;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) UITabBar *tabBar;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property(nonatomic,assign)BOOL isViewLoaded;
@property (weak, nonatomic) IBOutlet UITextField *_pwdTxtF;
@property (weak, nonatomic) IBOutlet UITextField *_emailTxtF;
@end

@implementation LoginVc


#pragma mark UI LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //UI Set UP
    [self onLoadViewAdjusments];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SHOW_NAVIGATION_BAR
    HIDE_STATUS_BAR
    if (!self.isViewLoaded && iOSVersionLessThan(@"8.0")) {
        self.isViewLoaded=YES;
        [self adjustLogoImage];
    }
    NSDate *lastLoginTime=[AppCommonFunctions getDataFromNSUserDefault:@"lastLoginTime"];
    NSTimeInterval timeInterval=[[NSDate date] timeIntervalSinceDate:lastLoginTime];
    if ([AppCommonFunctions getDataFromNSUserDefault:@"access_token"] && timeInterval<24*60*60) {
        [self.timer invalidate];
        self.timer=nil;
        self.timer=[NSTimer scheduledTimerWithTimeInterval:24*60*60-timeInterval target:self selector:@selector(logoutUserFromApp:) userInfo:nil repeats:NO];
        [[AppCommonFunctions sharedInstance]prepareViewWhenUserIsLoggedInFrom:[self navigationController] ];
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!self.isViewLoaded && iOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.isViewLoaded=YES;
        [self adjustLogoImage];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField=10;
}
-(void)dealloc{
    
    [self.timer invalidate];
    self.timer=nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Custom Functions
- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}
- (void)showLoginErrorMessage:(BOOL)param {
    if (param) {
        self.messageLabel.text = @"Email Address or Password is incorrect.";
        self.messageView.hidden = NO;
        self.btnSignIn.enabled=false;
    }
    else {
        self.messageLabel.text = @"";
        self.messageView.hidden = YES;
    }
}
#pragma mark View Adjusments
-(void)onLoadViewAdjusments
{
    [_btnSignIn setEnabled:NO];
    [self showLoginErrorMessage:false];
    [[NSCommonMethod sharedInstance] makeNavigationBarTransparentInViewController:self];
    
    //dismiss keyboad on click on view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    [NSCommonMethod setPlaceHolderOfTextField:__emailTxtF placeHolder:@"you@email.com" placeHolderColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25]];
    [NSCommonMethod setPlaceHolderOfTextField:__pwdTxtF placeHolder:@"At least 6 characters" placeHolderColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25]];
    
    //to make the profile pic rounded
    [NSCommonMethod makeViewRounded:self.loginView withCornerRadius:10.0 withBorderColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25] withBorderWidth:1.5];
    //to make the sign in button rounded
    [NSCommonMethod makeViewRounded:self.btnSignIn withCornerRadius:5.0 withBorderColor:nil withBorderWidth:0.0];
    [__emailTxtF setTextColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25]];
    [__pwdTxtF setTextColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeText:) name:UITextFieldTextDidChangeNotification object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)setImageOnButton:(UIButton *)button image:(NSString *)imageName {
    NSString *btnImage;
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        btnImage = [NSString stringWithFormat:@"%@@2x", imageName];
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone4inch) {
        btnImage = [NSString stringWithFormat:@"%@@2x", imageName];
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        btnImage = [NSString stringWithFormat:@"%@@3x", imageName];//should chage it @2x later on
    }
    else {
        btnImage = [NSString stringWithFormat:@"%@@3x", imageName];
    }
    [button setImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
}
-(void)adjustLogoImage{
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height == 667.0f)
        {
            
            NSLayoutConstraint *widthConstarint=[NSLayoutConstraint constraintWithItem:_profileImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:130];
            [_profileImageView addConstraint:widthConstarint];
        }
    }
}
#pragma mark Click Actions
- (IBAction)onClickSignIn:(id)sender {
    
    [self.view endEditing:YES];
    SHOW_ACTIVITY_INDICATOR
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:self._emailTxtF.text,@"username",self._pwdTxtF.text,@"password",AccountID,@"account_id", nil];
    [self callWebServiceWithParameters:dict];
}

#pragma mark service hits

-(void)callWebServiceWithParameters:(NSMutableDictionary*)param
{
    Service * serviceObj = [Service sharedClient];
    [serviceObj POST:Sign_in_Method parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
     } success:^(NSURLSessionDataTask *operation, id responseObject)
     {
         if ([[responseObject objectForKey:@"result"] isEqualToString:@"success"])
         {
             [AppCommonFunctions saveUserDefaultWithObject:[[responseObject objectForKey:@"user"] objectForKey:@"access_token"] andKey:@"access_token"];
             [AppCommonFunctions saveUserDefaultWithObject:[[responseObject objectForKey:@"user"] objectForKey:@"user_id"] andKey:@"user_id"];
             NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[responseObject objectForKey:@"user"] objectForKey:@"user_id"],@"user_id",@"1",@"full",self._emailTxtF.text,@"email", nil];
             //Hit Service to fetch User Details
             [self getUserDetails:dict];
         }
         else
         {
             self._emailTxtF.text=@"";
             self._pwdTxtF.text=@"";
             self.btnSignIn.enabled=false;
             [self showLoginErrorMessage:true];
             HIDE_ACTIVITY_INDICATOR
         }
     } failure:^(NSURLSessionDataTask *operation, NSError *error) {
         
         HIDE_ACTIVITY_INDICATOR
         self._emailTxtF.text=@"";
         self._pwdTxtF.text=@"";
         self.btnSignIn.enabled=false;
         [self showLoginErrorMessage:true];
     }];
}
-(void)getUserDetails:(NSMutableDictionary*)param
{
    
    NSDictionary *dictDataUserSearch  = [[NSMutableDictionary alloc] init];
    [dictDataUserSearch setValue:[param objectForKey:@"email"] forKeyPath:@"value"];
    [dictDataUserSearch setValue:@"eq" forKeyPath:@"type"];
    NSDictionary *dictFilterValue = [NSDictionary dictionaryWithObject:dictDataUserSearch forKey:@"email"];
    NSMutableDictionary *dictFilterUser = [NSMutableDictionary dictionaryWithObject:dictFilterValue forKey:@"filter"];
    [dictFilterUser setObject:@"1" forKey:@"full_document"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:dictFilterUser] base64EncodedStringWithOptions:0];
    NSMutableDictionary *dictParam  = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option", nil];
    //service hit
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    TVRequest *request = [TVRequest postRequesforFormData:dictParam endpoint:[NSString stringWithFormat:@"%@%@",kEndpointUsers,kEndpointSearch]  withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            BOOL  failedForImageissue = true;
            for (NSDictionary *dict in [[responseDictionary objectForKey:@"data"] objectForKey:@"documents"]) {
                NSString *encodedString = [dict objectForKey:@"attributes"];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:decodedData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                if ([((NSString*)[json objectForKey:@"imageId"]) hasPrefix:@"/home/maheshy"]) {
                    failedForImageissue = true;
                    continue;
                }
                failedForImageissue = false;
                [AppCommonFunctions saveUserDefaultWithObject:json andKey:@"userinfo"];
                [self updateUsersAccessTokenforUserID:json];
                break;
            }
            if (failedForImageissue) {
                HIDE_ACTIVITY_INDICATOR
                NSString *encodedString = [[[[responseDictionary objectForKey:@"data"] objectForKey:@"documents"] objectAtIndex:0] objectForKey:@"attributes"];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:decodedData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                [AppCommonFunctions saveUserDefaultWithObject:[NSDate date] andKey:@"lastLoginTime"];
                [self.timer invalidate];
                self.timer=nil;
                self.timer=[NSTimer scheduledTimerWithTimeInterval:24*60*60 target:self selector:@selector(logoutUserFromApp:) userInfo:nil repeats:NO];
                if ([[json objectForKey:@"roleId"] intValue] == [UserRoleTrainer intValue]) {
                    [[AppCommonFunctions sharedInstance]prepareViewWhenUserIsLoggedInFrom:[self navigationController] ];
                }
                else
                {
                    [[AppCommonFunctions sharedInstance]prepareViewWhenUserIsLoggedInFrom:[self navigationController] ];
                    
                    [[AppCommonFunctions sharedInstance].tabBar setSelectedIndex:0];
                }
            }
        } else {
            HIDE_ACTIVITY_INDICATOR
            self._emailTxtF.text=@"";
            self._pwdTxtF.text=@"";
            self.btnSignIn.enabled=false;
            [self showLoginErrorMessage:true];
        }
    }];
    [request sendRequest];
}
-(void)updateUsersAccessTokenforUserID:(NSDictionary *)dictData
{
    
    NSMutableDictionary *userAttributes =  [[NSMutableDictionary alloc] init];
    [userAttributes setObject:[dictData objectForKey:@"createdAt"] forKey:@"createdAt"];
    [userAttributes setObject:[dictData objectForKey:@"email"] forKey:@"email"];
    [userAttributes setObject:[dictData objectForKey:@"firstName"] forKey:@"firstName"];
    [userAttributes setObject:[dictData objectForKey:@"imageId"] forKey:@"imageId"];
    [userAttributes setObject:[dictData objectForKey:@"isActive"] forKey:@"isActive"];
    [userAttributes setObject:[dictData objectForKey:@"lastName"] forKey:@"lastName"];
    [userAttributes setObject:[dictData objectForKey:@"password"] forKey:@"password"];
    [userAttributes setObject:[dictData objectForKey:@"phoneNo"] forKey:@"phoneNo"];
    [userAttributes setObject:[dictData objectForKey:@"roleId"] forKey:@"roleId"];
    [userAttributes setObject:[dictData objectForKey:@"team"] forKey:@"team"];
    [userAttributes setObject:[dictData objectForKey:@"updatedAt"] forKey:@"updatedAt"];
    [userAttributes setObject:[dictData objectForKey:@"userId"] forKey:@"userId"];
    [userAttributes setObject:[NSNumber numberWithInt:1] forKey:@"deviceType"];
    [userAttributes setObject:[[NSUserDefaults standardUserDefaults]objectForKey:PUSH_NOTIFICATION_DEVICE_TOKEN] forKey:@"deviceToken"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:userAttributes] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"attributes", nil];
    //service hit
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString * userId = [userDefaults objectForKey:@"user_id"];
    NSString *authString = APIKEYTrueVault;
    TVRequest *request = [TVRequest putDocumentwithData:paramDict endpoint:[NSString stringWithFormat:@"%@/%@",kEndpointUsers,userId] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            HIDE_ACTIVITY_INDICATOR
            [AppCommonFunctions saveUserDefaultWithObject:[NSDate date] andKey:@"lastLoginTime"];
            [self.timer invalidate];
            self.timer=nil;
            self.timer=[NSTimer scheduledTimerWithTimeInterval:24*60*60 target:self selector:@selector(logoutUserFromApp:) userInfo:nil repeats:NO];
            if ([[dictData objectForKey:@"roleId"] intValue] == [UserRoleTrainer intValue]) {
                [[AppCommonFunctions sharedInstance]prepareViewWhenUserIsLoggedInFrom:[self navigationController] ];
                [[AppCommonFunctions sharedInstance].tabBar setSelectedIndex:1];
                
            }
            else
            {
                [[AppCommonFunctions sharedInstance]prepareViewWhenUserIsLoggedInFrom:[self navigationController] ];
                [[AppCommonFunctions sharedInstance].tabBar setSelectedIndex:0];
            }
            
        } else {
            HIDE_ACTIVITY_INDICATOR
            self._emailTxtF.text=@"";
            self._pwdTxtF.text=@"";
            self.btnSignIn.enabled=false;
            [self showLoginErrorMessage:true];
            
        }
    }];
    [request sendRequest];
}


#pragma mark Textfeild Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showLoginErrorMessage:false];
    
    if ([NSCommonMethod validateEmailWithString:__emailTxtF.text] && [NSCommonMethod validatePasswordTextField:__pwdTxtF]) {
        [self setImageOnButton:_btnSignIn image:@"SignInEnabled"];
        self.btnSignIn.enabled = YES;
    }
    else {
        [self setImageOnButton:_btnSignIn image:@"SignInDisabled"];
        self.btnSignIn.enabled = NO;
    }
}

- (void)textFieldDidChangeText:(id)sender
{
    [self showLoginErrorMessage:false];
    if ([NSCommonMethod validateEmailWithString:__emailTxtF.text] && [NSCommonMethod validatePasswordTextField:__pwdTxtF]) {
        [self setImageOnButton:_btnSignIn image:@"SignInEnabled"];
        self.btnSignIn.enabled = YES;
    }
    else {
        [self setImageOnButton:_btnSignIn image:@"SignInDisabled"];
        self.btnSignIn.enabled = NO;
    }
    if (__emailTxtF.isFirstResponder) {
        
        if (__emailTxtF.text.length==0) {
            
            [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=YES;
        }
        else{
            
            [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=NO;
        }
    }
    else if (__pwdTxtF.isFirstResponder) {
        
        if (__pwdTxtF.text.length==0) {
            
            [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=YES;
        }
        else{
            
            [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=NO;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self showLoginErrorMessage:NO];
    if ([NSCommonMethod validateEmailWithString:__emailTxtF.text] && [NSCommonMethod validatePasswordTextField:__pwdTxtF]) {
        [self setImageOnButton:_btnSignIn image:@"SignInEnabled"];
        self.btnSignIn.enabled = YES;
    }
    else {
        [self setImageOnButton:_btnSignIn image:@"SignInDisabled"];
        self.btnSignIn.enabled = NO;
    }
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark- Logout user from app and invalidate session
-(void)logoutUserFromApp:(NSTimer*)timer{
    [[AppCommonFunctions sharedInstance] logout];
}
#pragma mark Authenticate via Touch ID
- (void)onClickAuthenticate:(id)sender {
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]){
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Are you the device owner?"
                          reply:^(BOOL success, NSError *error) {
                              
                              if (error) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"There was a problem verifying your identity."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  return;
                              }
                              
                              if (success) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                  message:@"You are the device owner!"
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  
                              } else {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"You are not the device owner."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                              }
                              
                          }];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device cannot authenticate using TouchID."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}
@end
