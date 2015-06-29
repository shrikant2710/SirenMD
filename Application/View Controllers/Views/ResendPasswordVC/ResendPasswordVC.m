//
//  ResendPasswordVC.m
//  SirenMD
//
//  Created by Nakul Sharma on 6/5/15.
//  Copyright (c) 2015 Shrikant . All rights reserved.
//
#import "SDiPhoneVersion.h"
#import "ResendPasswordVC.h"
#import "AppCommonFunctions.h"
#import "TVRequest.h"
#import "TVObject.h"
#import "TVHelper.h"

@interface ResendPasswordVC ()
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *loginView;

@property (weak, nonatomic) IBOutlet UIButton *btnSendPassword;

@property (weak, nonatomic) IBOutlet UITextField *_emailTxtF;

@end

@implementation ResendPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSCommonMethod sharedInstance] setBackgroundOnView:self.view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    [NSCommonMethod setPlaceHolderOfTextField:__emailTxtF placeHolder:@"you@email.com" placeHolderColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25]];
    [NSCommonMethod makeViewRounded:self.loginView withCornerRadius:10.0 withBorderColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25] withBorderWidth:1.5];
    [NSCommonMethod makeViewRounded:self.btnSendPassword withCornerRadius:5.0 withBorderColor:nil withBorderWidth:0.0];
    [__emailTxtF setTextColor:[UIColor colorWithRed:90.0 green:90.0 blue:70.0 alpha:0.25]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeText:) name:UITextFieldTextDidChangeNotification object:nil];
    [self setUpForNavigationBar];
    self.btnSendPassword.enabled = NO;

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=YES;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField=10;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpForNavigationBar {
    SHOW_NAVIGATION_BAR
    SHOW_STATUS_BAR
    FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE
    [CommonFunctions setNavigationTitle: @"Resend Password" ForNavigationItem: self.navigationItem];
    [CommonFunctions setNavigationBarBackgroundWithImage:navigationBarBackgroundImage1 fromViewController:self];
    [CommonFunctions addLeftNavigationBarButton:self withImageName:@"Back"WithNegativeSpacerValue:0];
}

- (IBAction)onClickSendPassword:(id)sender {
   
    [self getUserDetailsForEmail:self._emailTxtF.text];

}

-(void)getUserDetailsForEmail:(NSString*)email
{
    
    NSDictionary *dictDataUserSearch  = [[NSMutableDictionary alloc] init];
    [dictDataUserSearch setValue:email forKeyPath:@"value"];
    [dictDataUserSearch setValue:@"eq" forKeyPath:@"type"];
    NSDictionary *dictFilterValue = [NSDictionary dictionaryWithObject:dictDataUserSearch forKey:@"email"];
    NSMutableDictionary *dictFilterUser = [NSMutableDictionary dictionaryWithObject:dictFilterValue forKey:@"filter"];
    [dictFilterUser setObject:@"1" forKey:@"full_document"];
    
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:dictFilterUser] base64EncodedStringWithOptions:0];
    NSMutableDictionary *dictDataSent  = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option", nil];
    //service hit
    TVRequest *request = [TVRequest postRequesforFormData:dictDataSent endpoint:[NSString stringWithFormat:@"%@%@",kEndpointUsers,kEndpointSearch] withAuthHeader:APIKEYTrueVault completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            
            NSArray *arrData = [[responseDictionary objectForKey:@"data"] objectForKey:@"documents"];
            if (arrData.count) {
                NSString *encodedString = [[arrData objectAtIndex:0] objectForKey:@"attributes"];
                
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:decodedData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                NSString *password = [json objectForKey:@"password"];
                NSLog(@"%@", password);
            }
            else {
                NSString *message = @"That email address was not found in our database. Please try again, or contact your account administrator.";
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                NSLog(@"%@",error);
            }

            
            
            
        } else {
            NSString *message = @"That email address was not found in our database. Please try again, or contact your account administrator.";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            NSLog(@"%@",error);
            
        }
    }];
    [request sendRequest];
}

-(void)sendNotificationofPassword:(NSString *)password
{
    //hit notification api
}

- (void)onClickOfLeftNavigationBarButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSCommonMethod sharedInstance] makeNavigationBarTransparentInViewController:self];
}

#pragma mark Textfeild Delegate
- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([NSCommonMethod validateEmailWithString:__emailTxtF.text]) {
        [self setImageOnButton:self.btnSendPassword image:@"eSendPassword"];
        self.btnSendPassword.enabled = YES;
    }
    else {
        [self setImageOnButton:self.btnSendPassword image:@"dSendPassword"];
        self.btnSendPassword.enabled = NO;
    }
}

- (void)textFieldDidChangeText:(id)sender {
    if ([NSCommonMethod validateEmailWithString:__emailTxtF.text]) {
        [self setImageOnButton:self.btnSendPassword image:@"eSendPassword"];
        self.btnSendPassword.enabled = YES;
    }
    else {
        [self setImageOnButton:self.btnSendPassword image:@"dSendPassword"];
        self.btnSendPassword.enabled = NO;
    }
    if (__emailTxtF.text.length==0) {
        
        [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=YES;
    }
    else{
        
        [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder=NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([NSCommonMethod validateEmailWithString:__emailTxtF.text]) {
        [self setImageOnButton:self.btnSendPassword image:@"eSendPassword"];
        self.btnSendPassword.enabled = YES;
    }
    else {
        [self setImageOnButton:self.btnSendPassword image:@"dSendPassword"];
        self.btnSendPassword.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return YES;
}


#pragma -
#pragma - to set the image on button
- (void)setImageOnButton:(UIButton *)button image:(NSString *)imageName {
    NSString *btnImage;
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        btnImage = [NSString stringWithFormat:@"%@", imageName];
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone4inch) {
        btnImage = [NSString stringWithFormat:@"%@@2x", imageName];
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        btnImage = [NSString stringWithFormat:@"%@@2x", imageName];//should chage it @2x later on
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        btnImage = [NSString stringWithFormat:@"%@@3x", imageName];
    }
    [button setImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
}

@end
