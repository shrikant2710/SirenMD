//
//  ViewController.h
//  YSLContainerViewControllerDemo
//
//  Created by yamaguchi on 2015/03/24.
//  Copyright (c) 2015年 h.yamaguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaseBaseVc : UIViewController
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property(nonatomic,assign)BOOL shouldRefreshChildVC;


@end

