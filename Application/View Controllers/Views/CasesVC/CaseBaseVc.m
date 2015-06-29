//
//  ViewController.m
//  YSLContainerViewControllerDemo
//
//  Created by yamaguchi on 2015/03/24.
//  Copyright (c) 2015年 h.yamaguchi. All rights reserved.
//

#import "CaseBaseVc.h"
#import "YSLContainerViewController.h"
#import "CasesVC.h"
#import "AppCommonFunctions.h"
#import "NewCaseVC.h"

@interface CaseBaseVc () <YSLContainerViewControllerDelegate>
@property(nonatomic,weak)CasesVC *casesVCOpen,*casesVCClosed,*casesVCAll;
@property(nonatomic,strong)YSLContainerViewController *containerVC;

@end

@implementation CaseBaseVc

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // NavigationBar
    self.navigationView.backgroundColor=[UIColor colorWithRed:13.0/255.0 green:93/255.0 blue:183/255.0 alpha:0.9];
    // SetUp ViewControllers
    self.casesVCOpen =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[CasesVC description]];
    self.casesVCClosed =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[CasesVC description]];

    self.casesVCOpen.title = @"Open";
    self.casesVCClosed.title = @"Closed";
    self.casesVCClosed.caseType=1;

    // ContainerView
    float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    NSDictionary *dictData = [AppCommonFunctions getDataFromNSUserDefault:@"userinfo"];
    if ([[dictData objectForKey:@"roleId"] intValue] == [UserRoleDoctor intValue])
    {
        self.casesVCAll =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[CasesVC description]];
        self.casesVCAll.title = @"All";
        self.casesVCAll.caseType=2;

        self.containerVC = [[YSLContainerViewController alloc]initWithControllers:@[self.casesVCOpen,self.casesVCClosed, self.casesVCAll] topBarHeight:statusHeight parentViewController:self];
        self.casesVCAll.menuView=self.containerVC.menuView;

    }
    else{
        self.containerVC = [[YSLContainerViewController alloc]initWithControllers:@[self.casesVCOpen,self.casesVCClosed] topBarHeight:statusHeight parentViewController:self];
    }
    self.containerVC.delegate = self;
    [self.view addSubview:self.containerVC.view];
    self.casesVCOpen.menuView=self.containerVC.menuView;
    self.casesVCClosed.menuView=self.containerVC.menuView;
    CGRect rect=self.containerVC.view.frame;
    rect.origin.y=70;
    rect.size.height=APPDELEGATE.window.bounds.size.height-(70+44);
    self.containerVC.view.frame=rect;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationView.hidden=NO;
    if (self.shouldRefreshChildVC) {
        if (self.containerVC.currentIndex==0) {
            
            [self.casesVCOpen viewWillAppear:false];
        }
        else if (self.containerVC.currentIndex==1){
            [self.casesVCClosed viewWillAppear:false];
        }
        else{
            [self.casesVCAll viewWillAppear:false];
        }
    }
    HIDE_NAVIGATION_BAR
    SHOW_STATUS_BAR
    FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}
- (void)setUpForNavigationBar {
    SHOW_NAVIGATION_BAR
    SHOW_STATUS_BAR
    FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE
    self.navigationItem.hidesBackButton = YES;
    [CommonFunctions setNavigationTitle:@"Cases" ForNavigationItem:self.navigationItem];
    [CommonFunctions setNavigationBarBackgroundWithImage:navigationBarBackgroundImage1 fromViewController:self];
    [CommonFunctions addLeftNavigationBarButton:self withImageName:@"logout"WithNegativeSpacerValue:0];
    [CommonFunctions addRightNavigationBarButton:self withImageName:@"Add"WithNegativeSpacerValue:0];
}
- (IBAction)onClickOfRightNavigationBarButton:(id)sender {
    NewCaseVC *newCaseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewCaseVC"];
    newCaseVC.modalPresentationStyle = UIModalPresentationCustom;
    newCaseVC.caseBaseVC=self;
    [[AppCommonFunctions sharedInstance] presentControllerwithShadow:newCaseVC overController:self];
    
    [self presentViewController:newCaseVC animated:YES completion: ^{
    }];
}

- (IBAction)onClickOfLeftNavigationBarButton:(id)sender {
    [[AppCommonFunctions sharedInstance] logout];
}
#pragma mark -- YSLContainerViewControllerDelegate
- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller
{
    [controller viewWillAppear:YES];
}
@end
