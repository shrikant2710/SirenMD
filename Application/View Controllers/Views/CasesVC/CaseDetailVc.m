//
//  CaseDetailVc.m
//  Application
//
//  Created by Shrikant  on 6/14/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import "CaseDetailVc.h"
#import "TVHelper.h"
#import "TVRequest.h"
#import "TVFile.h"
#import "SDWebImageManager.h"
@interface CaseDetailVc ()
{
    __weak IBOutlet UITableView *tableV;
    BOOL isPostOpen,isToAddTextOrImage,isImageAdded;
}
@property (weak, nonatomic) IBOutlet UILabel *caseStatusLbl;
- (IBAction)onClickBack:(UIButton *)sender;
- (IBAction)onClickHeart:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBg;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBgFront;
@property (strong, nonatomic) NSMutableArray *assigniDetails;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation CaseDetailVc
@synthesize dictCase,docID;
#pragma mark UI Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self onLoadViewAdjusments];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = true;
    SHOW_STATUS_BAR
    if (!isToAddTextOrImage) {
        SHOW_ACTIVITY_INDICATOR
        [self getassignees];
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [tableV reloadData];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void) viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = false;
}
#pragma mark View Adjuments
-(void)onLoadViewAdjusments
{
    [tableV setBackgroundColor:[UIColor clearColor]];
    self.assigniDetails=[NSMutableArray array];
    isPostOpen = NO;
    self.imageViewBg.image=[self getBlurrImage:self.imageViewBg.image];
    if (self.dictCase) {
        if ([[self.dictCase objectForKey:@"priorityId"] intValue] != PriorityUrgent) {
            //set navigation color blue
            self.navigationBar.backgroundColor=[UIColor colorWithRed:0/255.0f green:117/255.0f blue:190/255.0f alpha:0.74];
        }
        else {
            //set navigation color red
            self.navigationBar.backgroundColor=[UIColor colorWithRed:223/255.0f green:1/255.0f blue:1/255.0f alpha:0.74];
        }
    }
    NSArray *createForDetails = [[self.dictCase objectForKey:@"createdForDetails"] componentsSeparatedByString:@"--"];
    if (createForDetails.count>=2) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",[createForDetails objectAtIndex:0],[createForDetails objectAtIndex:1]];
    }
    if ([[NSString stringWithFormat:@"%@",[self.dictCase objectForKey:@"statusId"]] isEqual:@"1"]) {
        
        self.caseStatusLbl.text=@"Injured";
    }
    else if ([[NSString stringWithFormat:@"%@",[self.dictCase objectForKey:@"statusId"]] isEqual:@"2"]) {
        
        self.caseStatusLbl.text=@"Recovering";
    }
    else{
        self.caseStatusLbl.text=@"Closed";
    }
    // Do any additional setup after loading the view.
    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor=[UIColor whiteColor];
    [tableV addSubview:refreshControl];
    [tableV sendSubviewToBack:refreshControl];
}
-(void)renderAssigniWithBtn1:(UIButton*)btn1 andBtn2:(UIButton*)btn2 addBtn:(UIButton*)addbtn{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"statusId != %@",[NSNumber numberWithInt:0]];
    NSArray *matchingObjs = [self.assigniDetails filteredArrayUsingPredicate:predicate];
    switch (matchingObjs.count) {
        case 0:{
            btn1.hidden=YES;
            btn2.hidden=YES;
            [addbtn setBackgroundImage:[UIImage imageNamed:@"Add@3x.png"] forState:UIControlStateNormal];
            break;
        }
        case 1:
        {
            btn1.hidden=NO;
            btn2.hidden=YES;
            [btn1 setTitle:[((NSDictionary*)[matchingObjs objectAtIndex:0]) objectForKey:@"assigneeDetails"] forState:UIControlStateNormal];
            [addbtn setBackgroundImage:[UIImage imageNamed:@"Add@3x.png"] forState:UIControlStateNormal];
            break;
        }
        case 2:
        {
            btn1.hidden=NO;
            btn2.hidden=NO;
            [btn1 setTitle:[((NSDictionary*)[matchingObjs objectAtIndex:0]) objectForKey:@"assigneeDetails"] forState:UIControlStateNormal];
            [btn2 setTitle:[((NSDictionary*)[matchingObjs objectAtIndex:1]) objectForKey:@"assigneeDetails"] forState:UIControlStateNormal];
            [addbtn setBackgroundImage:[UIImage imageNamed:@"Add@3x.png"] forState:UIControlStateNormal];
            break;
        }
            
        default:
        {
            btn1.hidden=NO;
            btn2.hidden=NO;
            [btn1 setTitle:[((NSDictionary*)[matchingObjs objectAtIndex:0]) objectForKey:@"assigneeDetails"] forState:UIControlStateNormal];
            [btn2 setTitle:[((NSDictionary*)[matchingObjs objectAtIndex:1]) objectForKey:@"assigneeDetails"] forState:UIControlStateNormal];
            [addbtn setBackgroundImage:[UIImage imageNamed:@"Editassigned.png"] forState:UIControlStateNormal];
            break;
        }
    }
}
#pragma mark Pull To Refresh
-(void)refreshTable:(UIRefreshControl*)refresh{
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    // custom refresh logic would be placed here...
    SHOW_ACTIVITY_INDICATOR
    //[self.assigniDetails removeAllObjects];
    [self getassignees];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
}
#pragma mark Custom Functions
-(UIImage*)getBlurrImage:(UIImage*)image{
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    CIImage *inputImage = [CIImage imageWithCGImage:[image CGImage]];
    [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@02 forKey:kCIInputRadiusKey];
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[inputImage extent]];  // note, use input image extent if you want it the same size, the output image extent is larger
    UIImage *imageBlurred       = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return imageBlurred;
}
#pragma mark On Click Actions
- (IBAction)onClickBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onClickChangePriority:(UIButton *)sender
{
    if ([[self.dictCase objectForKey:@"priorityId"] intValue] != PriorityUrgent) {
        sender.selected=NO;
        self.navigationBar.backgroundColor=[UIColor colorWithRed:223/255.0f green:1/255.0f blue:1/255.0f alpha:0.74];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(changeCasePriority:) withObject:[NSNumber numberWithInt: 0] afterDelay:.3f];
    }
    else {
        sender.selected=YES;
        self.navigationBar.backgroundColor=[UIColor colorWithRed:0/255.0f green:117/255.0f blue:190/255.0f alpha:0.74];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(changeCasePriority:) withObject:[NSNumber numberWithInt:1] afterDelay:.3f];
    }
}
- (IBAction)onClickHeart:(id)sender {
    
    if ([[NSString stringWithFormat:@"%@",[self.dictCase objectForKey:@"statusId"]] isEqual:@"3"]) {
        return;// retun if case closed
    }
    int caseStatus = [[self.dictCase objectForKey:@"statusId"] intValue];
    [ActionSheetStringPicker showPickerWithTitle:@"  " rows:[NSArray arrayWithObjects:@"Injured", @"Recovering", @"Closed", nil] initialSelection:caseStatus-1 doneBlock: ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         if (selectedIndex == caseStatus-1)// no change made in case status
         {
             return ;
         }
         if ((int)selectedIndex+1 == caseInjured) {
             self.caseStatusLbl.text= @"Injured";
         }
         else if ((int)selectedIndex+1 == caseRecovering) {
             self.caseStatusLbl.text= @"Recovering";
         }
         else {
             self.caseStatusLbl.text= @"Closed";
         }
         [NSObject cancelPreviousPerformRequestsWithTarget:self];
         [self performSelector:@selector(changeCaseStatus:) withObject:[NSNumber numberWithInt:(int)selectedIndex+1] afterDelay:.3f];
         
     } cancelBlock: ^(ActionSheetStringPicker *picker) {
     } origin:self.view];
}
-(void)tapAddDetailsBtn:(UIButton*)sender{
    isToAddTextOrImage=YES;
    [tableV reloadData];
}
-(void)tapDeletePostBtn:(UIButton*)sender{
    isToAddTextOrImage=NO;
    //isImageAdded=NO;
    [tableV reloadData];
}
-(void)tapAddPostBtn:(UIButton*)sender{
}
-(void)tapAddPhotoBtn:(UIButton*)sender{
    
    [self.view endEditing:YES];
    UIActionSheet* actionSheet = nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose from gallery",@"Capture photo", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    actionSheet.tag=1;
}
-(void)onClickOfAddNewAssigni:(UIButton*)sender{
    
    if ([[NSString stringWithFormat:@"%@",[self.dictCase objectForKey:@"statusId"]] isEqual:@"3"]) {
        return;
    }
    AssignProffessionalVC *assignProffessionalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AssignProffessionalVC"];
    assignProffessionalVC.isfromCaseDetails=YES;
    NSMutableArray *arr=[NSMutableArray arrayWithArray:self.assigniDetails];
    NSString *userID =   [[AppCommonFunctions getDataFromNSUserDefault:@"userinfo"] objectForKey: @"userId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId != %@ AND statusId != %@", userID,[NSNumber numberWithInt:0]];
    NSArray *matchingObjs = [arr filteredArrayUsingPredicate:predicate];
    assignProffessionalVC.caseDetailsDict=self.dictCase;
    assignProffessionalVC.docId=self.docID;
    assignProffessionalVC.selectedProffessionals=[NSMutableSet setWithArray:matchingObjs];
    predicate = [NSPredicate predicateWithFormat:@"userId != %@", userID];
    matchingObjs = [arr filteredArrayUsingPredicate:predicate];
    assignProffessionalVC.allredySelectedProffessionals=[NSMutableSet setWithArray:matchingObjs];
    assignProffessionalVC.caseId=[[arr objectAtIndex:0] objectForKey:@"caseId"];
    assignProffessionalVC.delegate=self;
    assignProffessionalVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[AppCommonFunctions sharedInstance] presentControllerwithShadow:assignProffessionalVC overController:self];
    [self presentViewController:assignProffessionalVC animated:YES completion: ^{
    }];
}
#pragma mark Table Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10 + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==0) {
        
        CGSize size=[AppCommonFunctions sizeOfText:[self.dictCase objectForKey:@"description"] font:[UIFont fontWithName:@"Avenir Next Medium" size:14.0] bundingSize:CGSizeMake(APPDELEGATE.window.bounds.size.width-20, 100000)];
        if (size.height<51) {
            return 390;
        }
        return 346+size.height;
    }
    else  if (indexPath.row==1) {
        
        if (isToAddTextOrImage) {
            return 155;
        }
        return 59;
    }
    return 155;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.row==0) {
        UITableViewCell * cell = [tableV dequeueReusableCellWithIdentifier:@"cellID"];
        
        UIButton *assigniButton = (UIButton*)[[[cell.contentView viewWithTag:1111] viewWithTag:1211] viewWithTag:1214];
        UIButton *addButton = (UIButton*)[[[cell.contentView viewWithTag:1111] viewWithTag:1211] viewWithTag:1215];
        UIButton *assigniButton2 = (UIButton*)[[[cell.contentView viewWithTag:1111] viewWithTag:1211] viewWithTag:1216];
        UIButton *priorityBtn = (UIButton*)[[[cell.contentView viewWithTag:1111] viewWithTag:1211] viewWithTag:1213];
        [priorityBtn addTarget:self action:@selector(onClickChangePriority:) forControlEvents:UIControlEventTouchUpInside];
        [addButton addTarget:self action:@selector(onClickOfAddNewAssigni:) forControlEvents:UIControlEventTouchUpInside];
        assigniButton.backgroundColor=[UIColor colorWithRed:0/255.0f green:117/255.0f blue:190/255.0f alpha:1];
        assigniButton2.backgroundColor=[UIColor colorWithRed:0/255.0f green:117/255.0f blue:190/255.0f alpha:1];
        UIImageView *profileImgView = (UIImageView*)[[cell.contentView viewWithTag:1111] viewWithTag:2222];
        NSArray *createForDetails = [[self.dictCase objectForKey:@"createdForDetails"] componentsSeparatedByString:@"--"];
        if (createForDetails.count>2) {
            profileImgView.image=nil;
            if ([[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:createForDetails[2]]) {
                
                profileImgView.image=[[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:createForDetails[2]];
            }
            else{
                NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
                TVRequest *request = [TVRequest fetchImageFromBlobID:createForDetails[2] forAuth:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                    if (!error) {
                        
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:createForDetails[2]];
                        __weak UIImageView* weakProfileImgView=profileImgView;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakProfileImgView.image=image;
                            self.imageViewBg.image=[self getBlurrImage:image];
                        });
                    } else {
                        NSLog(@"%@",error);
                    }
                }];
                [request sendRequest];
            }
        }
        if (self.dictCase) {
            if ([[self.dictCase objectForKey:@"priorityId"] intValue] != PriorityUrgent) {
                priorityBtn.selected=YES;
            }
            else {
                priorityBtn.selected=NO;
            }
        }
        
        UILabel *refreshedLbl = (UILabel*)[[[[cell.contentView viewWithTag:1111] viewWithTag:1112] viewWithTag:1131] viewWithTag:1132];
        refreshedLbl.textColor=[UIColor colorWithRed:158/255.0f green:158/255.0f blue:158/255.0f alpha:1];
        UILabel *caseIdLbl = (UILabel*)[[[cell.contentView viewWithTag:1111] viewWithTag:1112] viewWithTag:1114];
        UILabel *descriptionLbl = (UILabel*)[[[cell.contentView viewWithTag:1111] viewWithTag:1112] viewWithTag:1115];
        caseIdLbl.text=[NSString stringWithFormat:@"Case #: %@",[self.dictCase objectForKey:@"createdAt"]];
        descriptionLbl.text= [self.dictCase objectForKey:@"description"];
        if (![[self.dictCase objectForKey:@"priorityId"] intValue]) {
            priorityBtn.selected = false;
        }
        else{
            priorityBtn.selected = true;
        }
        [self renderAssigniWithBtn1:assigniButton andBtn2:assigniButton2 addBtn:addButton];
        return cell;
    }
    else if (indexPath.row==1) {
        
        if (isToAddTextOrImage) {
            UITableViewCell *cell = [tableV dequeueReusableCellWithIdentifier:@"editDetailsCell" forIndexPath:indexPath];
            UIButton *deletePostBtn = (UIButton *)[cell.contentView viewWithTag:101];
            UIImageView *lineImageV = (UIImageView *)[cell.contentView viewWithTag:102];
            UIView *boxView = [cell.contentView viewWithTag:103];
            UIButton *addPhotoBtn=(UIButton*)[boxView viewWithTag:110];
            [deletePostBtn addTarget:self action:@selector(tapDeletePostBtn:) forControlEvents:UIControlEventTouchUpInside];
            [addPhotoBtn addTarget:self action:@selector(tapAddPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *addPostBtn=(UIButton*)[boxView viewWithTag:110];
            [addPostBtn addTarget:self action:@selector(tapAddPostBtn:) forControlEvents:UIControlEventTouchUpInside];
            // UITextView *textView = (UITextView *)[boxView viewWithTag:105];
            UIImageView *postImage = (UIImageView *)[boxView viewWithTag:106];
            postImage.layer.cornerRadius = 5.0f;
            postImage.layer.masksToBounds = NO;
            postImage.clipsToBounds = YES;
            // postImage.hidden = YES;
            boxView.layer.cornerRadius = 6.0f;
            boxView.layer.masksToBounds = NO;
            lineImageV.layer.borderColor = [UIColor colorWithRed:55/255.0f green:58/255.0f blue:60/255.0f alpha:0.9].CGColor;
            lineImageV.layer.masksToBounds = NO;
            lineImageV.layer.borderWidth = 4;
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            
            return cell;
            
        }
        else{
            UITableViewCell * cell = [tableV dequeueReusableCellWithIdentifier:@"addDetailCell"];
            UIImageView *lineImageV=(UIImageView*)[[cell.contentView viewWithTag:3260] viewWithTag:3261];
            UIButton *addDetailsBtn=(UIButton*)[[cell.contentView viewWithTag:3260] viewWithTag:3262];
            [addDetailsBtn addTarget:self action:@selector(tapAddDetailsBtn:) forControlEvents:UIControlEventTouchUpInside];
            lineImageV.layer.borderColor = [UIColor colorWithRed:55/255.0f green:58/255.0f blue:60/255.0f alpha:0.9].CGColor;
            lineImageV.layer.masksToBounds = NO;
            lineImageV.layer.borderWidth = 4;
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [tableV dequeueReusableCellWithIdentifier:@"caseDetailCell" forIndexPath:indexPath];
    UIImageView *profileImageV = (UIImageView *)[cell.contentView viewWithTag:101];
    UIImageView *lineImageV = (UIImageView *)[cell.contentView viewWithTag:102];
    UIView *boxView = [cell.contentView viewWithTag:103];
    UILabel *textLbl = (UILabel *)[cell.contentView viewWithTag:105];
    UIImageView *postImage = (UIImageView *)[cell.contentView viewWithTag:106];
    postImage.layer.cornerRadius = 5.0f;
    postImage.layer.masksToBounds = NO;
    postImage.clipsToBounds = YES;
    postImage.hidden = YES;
    profileImageV.layer.cornerRadius = 21;
    profileImageV.layer.borderWidth = 4;
    profileImageV.layer.borderColor = [UIColor whiteColor].CGColor;
    profileImageV.layer.masksToBounds = YES;
    profileImageV.image = [UIImage imageNamed:@"BradKaaya.png"];
    boxView.layer.cornerRadius = 6.0f;
    boxView.layer.masksToBounds = NO;
    lineImageV.layer.borderColor = [UIColor colorWithRed:55/255.0f green:58/255.0f blue:60/255.0f alpha:0.9].CGColor;
    lineImageV.layer.masksToBounds = NO;
    lineImageV.layer.borderWidth = 4;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    if(indexPath.row == 2)
    {
        textLbl.hidden = YES;
        postImage.hidden = NO;
        [postImage setImage:[UIImage imageNamed:@"Temp.png"]];
    }
    else
    {
        postImage.hidden = YES;
        textLbl.hidden = NO;
    }
    profileImageV.layer.borderWidth = 4;
    
    return cell;
}
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - Scrollview delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if ((constraint.secondItem!=nil) && (constraint.secondItem==self.imageViewBg.superview) && constraint.firstItem==self.imageViewBg) {
            if (constraint.firstAttribute==NSLayoutAttributeTop) {
                if (tableV.contentOffset.y>=0 && tableV.contentOffset.y<230) {
                    constraint.constant=210-tableV.contentOffset.y;
                }
                else if (tableV.contentOffset.y<0) {
                    constraint.constant=210;
                }
            }
        }
        if ((constraint.secondItem!=nil) && (constraint.secondItem==self.imageViewBg) && constraint.firstItem==self.imageViewBg.superview) {
            
            if (constraint.firstAttribute==NSLayoutAttributeTop) {
                if (tableV.contentOffset.y>=0 && tableV.contentOffset.y<230) {
                    constraint.constant=-250+tableV.contentOffset.y;
                }
                else if(tableV.contentOffset.y<0){
                    constraint.constant=-250;
                }
            }
        }
    }
}
#pragma mark Actionseat Delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==1)
    {
        if (buttonIndex==0 || buttonIndex==1) {
            UIImagePickerController *image_picker=nil;
            image_picker = [[UIImagePickerController alloc] init];
            image_picker.delegate =self;
            UIImagePickerControllerSourceType sourceType = (buttonIndex==0?UIImagePickerControllerSourceTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera);
            if ([UIImagePickerController isSourceTypeAvailable: sourceType] ){
                image_picker.sourceType = sourceType;
                if (image_picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
                    image_picker.allowsEditing = NO;
                    image_picker.showsCameraControls = YES;
                }
                [self.navigationController presentViewController:image_picker animated:YES completion:nil];
            }
            else{
                [TSMessage showNotificationWithTitle:@"Camera not available" type:TSMessageNotificationTypeError];
            }
        }
        else if (actionSheet.cancelButtonIndex){
        }
    }
}

#pragma mark -
#pragma mark -Image Picker Delegate
//this is called when user picks any image.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UITableViewCell *cell=[tableV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UIView *boxView = [cell.contentView viewWithTag:103];
    UITextView *textView = (UITextView *)[boxView viewWithTag:105];
    textView.text=@"";
    UIImageView *postImage = (UIImageView *)[boxView viewWithTag:106];
    postImage.image=image;
    postImage.hidden = NO;
    //[tableV reloadData];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark Service Hits
-(void)changeCaseStatus:(NSNumber *)caseStatusId
{
    NSMutableDictionary *dict =  [NSMutableDictionary dictionaryWithDictionary:self.dictCase];
    [dict setObject:caseStatusId forKey:@"statusId"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:dict] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",caseschema,@"schema_id", nil];
    //service hit
    NSString *authString = APIKEYTrueVault;
    TVRequest *request = [TVRequest putDocumentwithData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents/%@", kEndpointVaults, VaultID,self.docID] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            self.dictCase = [NSMutableDictionary dictionaryWithDictionary:dict];
            [self changeUpdateTimeForCase];
        }
        else
        {
            int caseStatusId =   [[self.dictCase objectForKey:@"statusId"] intValue];
            if (caseStatusId == caseInjured){
                self.caseStatusLbl.text= @"Injured";
            }
            else if (caseStatusId == caseRecovering){
                self.caseStatusLbl.text= @"Recovering";
            }
            else{
                self.caseStatusLbl.text= @"Closed";
            }
            [TSMessage showNotificationWithTitle:@"Failed to update case status" type:TSMessageNotificationTypeError];
            NSLog(@"%@",error);
        }
    }];
    [request sendRequest];
}
-(void)changeCasePriority:(NSNumber*)casePriorityID
{
    UITableViewCell *cell = [tableV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIButton *priorityBtn = (UIButton*)[[[cell.contentView viewWithTag:1111] viewWithTag:1211] viewWithTag:1213];
    NSMutableDictionary *dict =  [NSMutableDictionary dictionaryWithDictionary:self.dictCase];
    [dict setObject:casePriorityID forKey:@"priorityId"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:dict] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",caseschema,@"schema_id", nil];
    //service hit
    NSString *authString = APIKEYTrueVault;
    TVRequest *request = [TVRequest putDocumentwithData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents/%@", kEndpointVaults, VaultID,self.docID] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            self.dictCase = [NSMutableDictionary dictionaryWithDictionary:dict];
            [self changeUpdateTimeForCase];
        }
        else
        {
            if ([[self.dictCase objectForKey:@"priorityId"] intValue] != PriorityUrgent) {
                self.navigationBar.backgroundColor=[UIColor colorWithRed:0/255.0f green:117/255.0f blue:190/255.0f alpha:0.74];
                priorityBtn.selected=YES;
            }
            else {
                self.navigationBar.backgroundColor=[UIColor colorWithRed:223/255.0f green:1/255.0f blue:1/255.0f alpha:0.74];
                priorityBtn.selected=NO;
            }
            NSLog(@"%@",error);
            HIDE_ACTIVITY_INDICATOR
            [TSMessage showNotificationWithTitle:@"Failed to update case priority" type:TSMessageNotificationTypeError];
        }
    }];
    [request sendRequest];
}
-(void)getassignees
{
    NSMutableDictionary *caseIDFilter  = [[NSMutableDictionary alloc] init];
    [caseIDFilter setValue:[self.dictCase objectForKey:@"caseId"] forKey:@"value"];
    [caseIDFilter setValue:@"eq" forKeyPath:@"type"];
    NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObject:caseIDFilter forKey:@"caseId"];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:filter forKey:@"filter"];
    [param setObject:@"and" forKey:@"filter_type"];
    [param setObject:assigneeSchema forKey:@"schema_id"];
    [param setObject:@"1" forKey:@"full_document"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    //service hit
    TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, VaultID, kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            HIDE_ACTIVITY_INDICATOR
            NSMutableSet *assigneeInfo=[NSMutableSet new];
            for(NSDictionary *dictData in [[responseDictionary objectForKey:@"data"] objectForKey:@"documents"])
            {
                NSString *base64String =  [dictData objectForKey:@"document"];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
                NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                [dict setObject:[dict objectForKey:@"assigneeId"] forKey:@"userId"];
                [dict setObject:[dictData objectForKey:@"document_id"] forKey:@"document_id"];
                [assigneeInfo addObject:dict];
            }
            self.assigniDetails=[NSMutableArray arrayWithArray:[assigneeInfo allObjects]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableV reloadData];
            });
        } else {
            NSLog(@"%@",error);
            HIDE_ACTIVITY_INDICATOR
        }
    }];
    [request sendRequest];
}
-(void)changeUpdateTimeForCase
{
    NSMutableDictionary *dict =  [NSMutableDictionary dictionaryWithDictionary:self.dictCase];
    [dict setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"updatedAt"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:dict] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",caseschema,@"schema_id", nil];
    //service hit
    NSString *authString = APIKEYTrueVault;
    TVRequest *request = [TVRequest putDocumentwithData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents/%@", kEndpointVaults, VaultID,self.docID] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            HIDE_ACTIVITY_INDICATOR
            self.dictCase = [NSMutableDictionary dictionaryWithDictionary:dict];
        } else {
            
            HIDE_ACTIVITY_INDICATOR
            NSLog(@"%@",error);
        }
    }];
    [request sendRequest];
}

@end
