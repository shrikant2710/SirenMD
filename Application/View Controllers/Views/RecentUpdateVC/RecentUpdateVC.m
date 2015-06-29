//
//  RecentUpdateVC.m
//  Application
//
//  Created by Nakul Sharma on 6/10/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import "RecentUpdateVC.h"
#import "AppCommonFunctions.h"
@interface RecentUpdateVC ()

@end

@implementation RecentUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // [self setUpForNavigationBar];
    self.navigationView.backgroundColor=[UIColor colorWithRed:13.0/255.0 green:93/255.0 blue:183/255.0 alpha:0.9];
    
  
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    HIDE_NAVIGATION_BAR
    SHOW_STATUS_BAR
    FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpForNavigationBar {
    SHOW_NAVIGATION_BAR
    SHOW_STATUS_BAR
    FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE
    self.navigationItem.hidesBackButton = YES;
    [CommonFunctions setNavigationTitle:@"Recent Updates" ForNavigationItem:self.navigationItem];
    [CommonFunctions setNavigationBarBackgroundWithImage:navigationBarBackgroundImage1 fromViewController:self];
    [CommonFunctions addLeftNavigationBarButton:self withImageName:@"logout"WithNegativeSpacerValue:0];
    
}

- (IBAction)onClickOfLeftNavigationBarButton:(id)sender {
    [[AppCommonFunctions sharedInstance] logout];
}


@end
