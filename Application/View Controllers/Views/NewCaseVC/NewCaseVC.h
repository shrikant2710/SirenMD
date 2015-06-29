//
//  NewCaseVC.h
//  Application
//
//  Created by Nakul Sharma on 6/10/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectAtheleteVC.h"
#import "AssignProffessionalVC.h"
#import "CaseBaseVc.h"

@interface NewCaseVC : UIViewController<AssignProffessionalVCDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *atheleteNameLable;
@property (strong, nonatomic) NSMutableSet *selectedProffessionals;
@property (strong, nonatomic) NSDictionary *selectedAthlete;
@property (weak, nonatomic) CaseBaseVc *caseBaseVC;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *caseStatusLabel;


@end
