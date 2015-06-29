//
//  NewCaseVC.m
//  Application
//
//  Created by Nakul Sharma on 6/10/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import "NewCaseVC.h"
#import "TextViewPlaceHolderSupport.h"
#import "CommonFunctions.h"
#import "NSCommonMethod.h"
#import "ApplicationSpecificConstants.h"
#import "TVRequest.h"
#import "TVHelper.h"
@interface NewCaseVC ()
@property (weak, nonatomic) IBOutlet UIView *tiltleContainerView;
@property (weak, nonatomic) IBOutlet UIView *headerDividerView;
@property (assign, nonatomic)int totalAssignedProffessionals;
@property (assign, nonatomic)BOOL isViewLoaded;
@property (strong, nonatomic) NSString *caseId;
@property (weak, nonatomic) IBOutlet UIView *tiltleContainerViewBottom;
@property (weak, nonatomic) IBOutlet UIView *tiltleContainerViewBottom2;
@property (weak, nonatomic) IBOutlet UIView *tiltleContainerViewBottom3;
@property (weak, nonatomic) IBOutlet UIView *choosePersonView;
@property (weak, nonatomic) IBOutlet UIButton *addAssigniBtn;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *caseDescriptionLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *caseCountLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *subTitleLable;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet TextViewPlaceHolderSupport *caseDescriptionTextView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *amButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *amButtonHidden;
@property (weak, nonatomic) IBOutlet UIButton *exclemationButton;
@property (weak, nonatomic) IBOutlet UIButton *addAtheleteButton;
@property (weak, nonatomic) IBOutlet UIButton *caseStatusDrpDwn;
@property (weak, nonatomic) IBOutlet UIView *athleteNameBg;
@property (weak, nonatomic) IBOutlet UIView *caseStatusBg;
@property (weak, nonatomic) IBOutlet UIImageView *lineImgView;

@end

@implementation NewCaseVC

#pragma mark UI LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self onLoadViewAdjusments];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SHOW_NAVIGATION_BAR
    SHOW_STATUS_BAR
    FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE
    if (iOSVersionLessThan(@"8.0") && !self.isViewLoaded) {
        self.isViewLoaded=YES;
        [self adjustScreen];
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (iOSVersionGreaterThanOrEqualTo(@"8.0") && !self.isViewLoaded) {
        self.isViewLoaded=YES;
        [self adjustScreen];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
#pragma mark View Adjusments
- (void)setUpForNavigationBar {
    SHOW_NAVIGATION_BAR
    //SHOW_STATUS_BAR
    FIX_IOS_7_EDGE_START_LAY_OUT_ISSUE
    self.navigationItem.hidesBackButton = YES;
}
-(void)onLoadViewAdjusments
{
    self.athleteNameBg.layer.cornerRadius =  5.0;
    self.athleteNameBg.layer.masksToBounds = YES;
    self.caseStatusBg.layer.cornerRadius =  5.0;
    self.caseStatusBg.layer.masksToBounds = YES;
    self.tiltleContainerView.backgroundColor=[UIColor colorWithRed:0/255.0 green:117/255.0 blue:190/255.0 alpha:1];
    self.tiltleContainerViewBottom.backgroundColor=[UIColor colorWithRed:0/255.0 green:117/255.0 blue:190/255.0 alpha:1];
    self.choosePersonView.backgroundColor=[UIColor colorWithRed:0/255.0 green:117/255.0 blue:190/255.0 alpha:1];
    self.tiltleContainerViewBottom2.backgroundColor=[UIColor colorWithRed:0/255.0 green:57/255.0 blue:94/255.0 alpha:1];
    self.tiltleContainerViewBottom3.backgroundColor=[UIColor colorWithRed:0/255.0 green:57/255.0 blue:94/255.0 alpha:1];
    self.amButton.layer.cornerRadius =  self.amButton.frame.size.height / 2;
    self.amButton.layer.masksToBounds = YES;
    [self.amButton setTitleColor:[UIColor colorWithRed:2 / 255.0 green:115 / 255.0 blue:196/ 255.0 alpha:1] forState:UIControlStateNormal];
    self.amButtonHidden.layer.cornerRadius =  self.amButtonHidden.frame.size.height / 2;
    self.amButtonHidden.layer.masksToBounds = YES;
    [self.amButtonHidden setTitleColor:[UIColor colorWithRed:2 / 255.0 green:115 / 255.0 blue:196/ 255.0 alpha:1] forState:UIControlStateNormal];
    self.caseDescriptionTextView.placeholder = @"Tap to type the case description";
    self.caseDescriptionTextView.placeholderTextColor = [UIColor whiteColor];
    self.lineImgView.layer.borderColor = [UIColor colorWithRed:5/255.0f green:65/255.0f blue:101/255.0f alpha:1].CGColor;
    self.lineImgView.layer.masksToBounds = NO;
    self.lineImgView.layer.borderWidth = 6;
    // Get logged in user's info from nsuserdefaults
    NSDictionary *userInfoDict=[AppCommonFunctions getDataFromNSUserDefault:@"userinfo"];
    self.selectedProffessionals=[NSMutableSet set];
    // Set first latters of logged in user's first and last name in button
    NSString *firstName=[userInfoDict objectForKey:@"firstName"];
    NSString *lastName=[userInfoDict objectForKey:@"lastName"];
    NSString *firstLatter=[[firstName substringToIndex:1] uppercaseString];
    NSString *lastLatter=[[lastName substringToIndex:1] uppercaseString];
    NSString *combinedString=[NSString stringWithFormat:@"%@%@",firstLatter,lastLatter];
    [self.amButton setTitle:combinedString forState:UIControlStateNormal];
    // adjust button's image edge insets
    self.addAtheleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, APPDELEGATE.window.bounds.size.width-70, 0, 0);
    self.caseStatusDrpDwn.imageEdgeInsets = UIEdgeInsetsMake(0, APPDELEGATE.window.bounds.size.width-70, 0, 0);
}
#pragma mark Click Actions
- (IBAction)onClickOfAddAthelete:(id)sender {
    
    SelectAtheleteVC *selectAtheleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAtheleteVC"];
    selectAtheleteVC.selectedAthlete=self.selectedAthlete;
    selectAtheleteVC.nCasedelegate = self;
    selectAtheleteVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:selectAtheleteVC animated:YES completion: ^{
    }];
    
}
- (IBAction)onClickOfAddNewCase:(id)sender {
    if (self.selectedAthlete.allKeys==0) {
        [TSMessage showNotificationWithTitle:@"Please add an athlete" type:TSMessageNotificationTypeError];
        return;
    }
    else if ([self.caseStatusLabel.text isEqualToString: @"Case Status"]) {
        [TSMessage showNotificationWithTitle:@"Please choose the case status." type:TSMessageNotificationTypeError];
        return;
    }
    else if (self.caseDescriptionTextView.text.length==0) {
        
        [TSMessage showNotificationWithTitle:@"Please add the description of the case." type:TSMessageNotificationTypeError];
        return;
    }
    //service hit
    [self addCaseOnTrueVault];
}
- (IBAction)dismiss:(id)sender {
    [[AppCommonFunctions sharedInstance] dismissViewControllerWithShadow:self];
}
- (IBAction)onClickAddAssignee:(UIButton *)sender {
    AssignProffessionalVC *assignProffessionalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AssignProffessionalVC"];
    assignProffessionalVC.selectedProffessionals=[NSMutableSet setWithSet:self.selectedProffessionals];
    assignProffessionalVC.delegate=self;
    assignProffessionalVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:assignProffessionalVC animated:YES completion: ^{
    }];
}

- (IBAction)onClickOfCaseStatusDrpDwn:(id)sender {
    [self.caseStatusDrpDwn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    if ([self.caseStatusLabel.text isEqualToString:@"Injured"]) {
        [ActionSheetStringPicker showPickerWithTitle:@"  " rows:[NSArray arrayWithObjects:@"Injured", @"Recovering", @"Closed", nil] initialSelection:0 doneBlock: ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.subTitleLable.text = selectedValue;
            [self.caseStatusDrpDwn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
            [self.caseStatusLabel setText:selectedValue];
        } cancelBlock: ^(ActionSheetStringPicker *picker) {
            [self.caseStatusDrpDwn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
        } origin:self.view];
    }
    else if ([self.caseStatusLabel.text isEqualToString:@"Recovering"])
    {
        [ActionSheetStringPicker showPickerWithTitle:@"  " rows:[NSArray arrayWithObjects:@"Injured", @"Recovering", @"Closed", nil] initialSelection:1 doneBlock: ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.subTitleLable.text = selectedValue;
            [self.caseStatusDrpDwn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
            [self.caseStatusLabel setText:selectedValue];
        } cancelBlock: ^(ActionSheetStringPicker *picker) {
            [self.caseStatusDrpDwn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
        } origin:self.view];
    }
    else
    {
        [ActionSheetStringPicker showPickerWithTitle:@"  " rows:[NSArray arrayWithObjects:@"Injured", @"Recovering", @"Closed", nil] initialSelection:0 doneBlock: ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.subTitleLable.text = selectedValue;
            [self.caseStatusDrpDwn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
            [self.caseStatusLabel setText:selectedValue];
        } cancelBlock: ^(ActionSheetStringPicker *picker) {
            [self.caseStatusDrpDwn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
        } origin:self.view];
    }
}
- (IBAction)onClickOfExclemation:(UIButton *)sender {
    if (sender.tag == 1) {
        self.tiltleContainerView.backgroundColor = [UIColor colorWithRed:194.0 / 255.0 green:0.0 / 255.0 blue:22.0 / 255.0 alpha:1.0];
        [self.exclemationButton setImage:[UIImage imageNamed:@"exclamation"] forState:UIControlStateNormal];
        self.headerDividerView.hidden=YES;
        sender.tag = 0;
    }
    else {
        self.tiltleContainerView.backgroundColor=[UIColor colorWithRed:0/255.0 green:117/255.0 blue:190/255.0 alpha:1];
        [self.exclemationButton setImage:[UIImage imageNamed:@"greyexclamation"] forState:UIControlStateNormal];
        self.headerDividerView.hidden=NO;
        sender.tag = 1;
    }
}
#pragma mark Service Hits
-(void)addCaseOnTrueVault
{
    SHOW_ACTIVITY_INDICATOR
    NSDictionary *userInfoDict=[AppCommonFunctions getDataFromNSUserDefault:@"userinfo"];
    NSMutableDictionary *caseAttributes =  [[NSMutableDictionary alloc] init];
    self.caseId=[NSString stringWithFormat:@"%@%d",[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]],rand()%1000];
    [caseAttributes setObject:self.caseId forKey:@"caseId"];
    [caseAttributes setObject:[userInfoDict objectForKey:@"userId"] forKey:@"createdBy"];
    [caseAttributes setObject:[userInfoDict objectForKey:@"userId"] forKey:@"lastupdatedBy"];
    [caseAttributes setObject:_caseDescriptionTextView.text forKey:@"description"];
    [caseAttributes setObject:[self.selectedAthlete objectForKey:@"athleteId"] forKey:@"createdFor"];
    NSString *atheleteDetails = [NSString stringWithFormat:@"%@--%@--%@",[self.selectedAthlete objectForKey:@"firstName"],[self.selectedAthlete objectForKey:@"lastName"],[self.selectedAthlete objectForKey:@"imageId"]];
    [caseAttributes setObject:atheleteDetails forKey:@"createdForDetails"];
    NSString *userDetails = [NSString stringWithFormat:@"%@--%@--%@",[userInfoDict objectForKey:@"firstName"],[userInfoDict objectForKey:@"lastName"],[userInfoDict objectForKey:@"imageId"]];
    [caseAttributes setObject:userDetails forKey:@"createdByDetails"];
    [caseAttributes setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"createdAt"];
    [caseAttributes setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"updatedAt"];
    [caseAttributes setObject:[NSNumber numberWithInt:(int)self.exclemationButton.tag] forKey:@"priorityId"];
    if ([self.caseStatusLabel.text isEqual:@"Injured"]) {
        [caseAttributes setObject:[NSNumber numberWithInt:1] forKey:@"statusId"];
    }
    else if ([self.caseStatusLabel.text isEqual:@"Recovering"]) {
        [caseAttributes setObject:[NSNumber numberWithInt:2] forKey:@"statusId"];
    }
    else{
        [caseAttributes setObject:[NSNumber numberWithInt:3] forKey:@"statusId"];
    }
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:caseAttributes] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",caseschema,@"schema_id", nil];
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    //service hit
    TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents", kEndpointVaults, VaultID] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            _totalAssignedProffessionals=0;
            [self addAssigneesToCase];//self loop to add all the assignees in assignee table
        } else {
            NSLog(@"%@",error);
            
            HIDE_ACTIVITY_INDICATOR
        }
    }];
    [request sendRequest];
}

-(void)addAssigneesToCase
{
    NSMutableArray *proffessionalsArray=[NSMutableArray arrayWithArray:[self.selectedProffessionals allObjects]];
    NSDictionary *userInfoDict=[AppCommonFunctions getDataFromNSUserDefault:@"userinfo"];
    
    [proffessionalsArray addObject:userInfoDict];
    if (_totalAssignedProffessionals<proffessionalsArray.count) {
        NSDictionary *proffessionalInfoDict=proffessionalsArray[_totalAssignedProffessionals];
        NSMutableDictionary *caseAssigneeAtribute =  [[NSMutableDictionary alloc] init];
        [caseAssigneeAtribute setObject:self.caseId forKey:@"caseId"];
        [caseAssigneeAtribute setObject:[proffessionalInfoDict objectForKey:@"userId"] forKey:@"assigneeId"];
        [caseAssigneeAtribute setObject:[NSNumber numberWithInt:1] forKey:@"statusId"];
        NSString *firstName=[proffessionalInfoDict objectForKey:@"firstName"];
        NSString *lastName=[proffessionalInfoDict objectForKey:@"lastName"];
        NSString *firstLatter=[[firstName substringToIndex:1] uppercaseString];
        NSString *lastLatter=[[lastName substringToIndex:1] uppercaseString];
        NSString *combinedString=[NSString stringWithFormat:@"%@%@",firstLatter,lastLatter];
        [caseAssigneeAtribute setObject:combinedString forKey:@"assigneeDetails"];
        [caseAssigneeAtribute setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]-600] forKey:@"timeStampofLastVisit"];
        NSString *bodyDataString = [[TVHelper dataWithJSONObject:caseAssigneeAtribute] base64EncodedStringWithOptions:0];
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",assigneeSchema,@"schema_id", nil];
        __weak NewCaseVC *weakSelf=self;
        //service hit
        NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
        TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents", kEndpointVaults, VaultID] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
            if (!error) {
                ++_totalAssignedProffessionals;
                [weakSelf addAssigneesToCase];
                //self loop to add all the assignees in assignee table
            } else {
                NSLog(@"%@",error);
                [weakSelf addAssigneesToCase];
            }
        }];
        [request sendRequest];
    }
    else{
        HIDE_ACTIVITY_INDICATOR
        [TSMessage showNotificationWithTitle:@"Case added successfully." type:TSMessageNotificationTypeSuccess];
        self.caseBaseVC.shouldRefreshChildVC=YES;
        [self.caseBaseVC viewWillAppear:NO];
        [[AppCommonFunctions sharedInstance] dismissViewControllerWithShadow:self];
        
    }
}
#pragma mark- AssignProffessionalVCDelegate methode
- (void)responseWithData:(NSSet *)arr{
    if (arr) {
        self.selectedProffessionals=[NSMutableSet setWithSet:arr];
        NSUInteger count=self.selectedProffessionals.count;
        switch (count) {
            case 0:{
                self.amButtonHidden.hidden=YES;
                [self.addAssigniBtn setBackgroundImage:[UIImage imageNamed:@"Add@3x.png"] forState:UIControlStateNormal];
                break;
            }
            case 1:
            {
                self.amButtonHidden.hidden=false;
                NSArray *arr=[_selectedProffessionals allObjects];
                NSString* firstName=[((NSDictionary*)[arr objectAtIndex:0]) objectForKey:@"firstName"];
                NSString* lastName=[((NSDictionary*)[arr objectAtIndex:0]) objectForKey:@"lastName"];
                NSString* firstLatter=[[firstName substringToIndex:1] uppercaseString];
                NSString* lastLatter=[[lastName substringToIndex:1] uppercaseString];
                NSString* combinedString=[NSString stringWithFormat:@"%@%@",firstLatter,lastLatter];
                [self.amButtonHidden setTitle:combinedString forState:UIControlStateNormal];
                [self.addAssigniBtn setBackgroundImage:[UIImage imageNamed:@"Add@3x.png"] forState:UIControlStateNormal];
                break;
            }
            default:
            {
                self.amButtonHidden.hidden=false;
                NSArray *arr=[_selectedProffessionals allObjects];
                NSString* firstName=[((NSDictionary*)[arr objectAtIndex:0]) objectForKey:@"firstName"];
                NSString* lastName=[((NSDictionary*)[arr objectAtIndex:0]) objectForKey:@"lastName"];
                NSString* firstLatter=[[firstName substringToIndex:1] uppercaseString];
                NSString* lastLatter=[[lastName substringToIndex:1] uppercaseString];
                NSString* combinedString=[NSString stringWithFormat:@"%@%@",firstLatter,lastLatter];
                [self.amButtonHidden setTitle:combinedString forState:UIControlStateNormal];
                [self.addAssigniBtn setBackgroundImage:[UIImage imageNamed:@"Editassigned.png"] forState:UIControlStateNormal];
                break;
            }
        }
    }
}

#pragma mark- touch delegate
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}
-(void)adjustScreen{
    for (NSLayoutConstraint *constraint in self.tiltleContainerViewBottom.constraints) {
        if ((constraint.secondItem==nil) && constraint.firstItem==self.tiltleContainerViewBottom) {
            if (constraint.firstAttribute==NSLayoutAttributeWidth) {
                constraint.constant=APPDELEGATE.window.bounds.size.width;
            }
        }
    }
}
#pragma mark- TextView delegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.scrollView.contentOffset=CGPointZero;
}
@end
