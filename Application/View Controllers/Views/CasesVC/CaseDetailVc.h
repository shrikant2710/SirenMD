//
//  CaseDetailVc.h
//  Application
//
//  Created by Shrikant  on 6/14/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssignProffessionalVC.h"
@interface CaseDetailVc : UIViewController<AssignProffessionalVCDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic)  NSMutableDictionary *dictCase;
@property (strong, nonatomic)  NSString *docID;
-(UIImage*)getBlurrImage:(UIImage*)image;
-(void)renderAssigniWithBtn1:(UIButton*)btn1 andBtn2:(UIButton*)btn2 addBtn:(UIButton*)addbtn;
@end
