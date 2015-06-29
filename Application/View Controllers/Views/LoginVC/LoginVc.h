//
//  LoginVc.h
//  SirenMD
//
//  Created by Shrikant  on 5/26/15.
//  Copyright (c) 2015 Shrikant . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVc : UIViewController <UITextFieldDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIView *messageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *messageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bellImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
- (IBAction)onClickSignIn:(id)sender;

@end
