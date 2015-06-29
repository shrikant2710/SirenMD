//
//  CasesVC.h
//  Application
//
//  Created by Nakul Sharma on 6/9/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NSCommonMethod.h"
#import "YSLScrollMenuView.h"
@interface CasesVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,assign)int caseType;// 0 for open and 1 for closed case 2 for all case
@property(nonatomic,weak)YSLScrollMenuView *menuView;// 0 for open and 1 for closed case 2 for all case

@end
