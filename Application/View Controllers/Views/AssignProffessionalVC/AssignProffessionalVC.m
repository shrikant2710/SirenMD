//
//  AssignProffessionalVC.m
//  Application
//
//  Created by Nakul Sharma on 6/16/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface AssignProffessionalTableViewCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *iconImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *iconBgImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation AssignProffessionalTableViewCell
@synthesize iconImageView,iconBgImageView, nameLabel;


-(void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
#import "AssignProffessionalVC.h"
#import "TVHelper.h"
#import "TVRequest.h"
#import "TVFile.h"
#import "SDWebImageManager.h"
@interface AssignProffessionalVC ()
@property(nonatomic,assign)__block int indexCount;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UILabel *assignProffessionalsHeaderText;
@end

@implementation AssignProffessionalVC
@synthesize allAtheletes, atheleteSectionTitles, atheleteIndexTitles, tableView, filteredAthelete, ArrOfAllAtheletes, copOfallAtheletes, selectedProffessionals,caseDetailsDict,docId;

#pragma mark UI Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    filteredAthelete = nil;
    atheleteIndexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    allAtheletes=[NSMutableDictionary dictionary];
    ArrOfAllAtheletes = [self getAllValuesOfDictionaryInAnArray:allAtheletes];
    atheleteSectionTitles = [[allAtheletes allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self setAttributedTextOnAssignProffessionalLabel];
    self.tableView.bounces = YES;
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:244/255.0 green:0/255.0 blue:0/255.0 alpha:1] forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[UIColor colorWithRed:2/255.0 green:115/255.0 blue:196/255.0 alpha:1] forState:UIControlStateNormal];
    self.assignProffessionalsHeaderText.textColor=[UIColor colorWithRed:12/255.0 green:12/255.0 blue:12/255.0 alpha:1];
    self.tableView.sectionIndexColor=[UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1];
    SHOW_ACTIVITY_INDICATOR
    [self getProfessionals];
    
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.tableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark Table View Data Source
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1]];
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
     header.contentView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSLog(@"%lu",(unsigned long)atheleteSectionTitles.count);
    return atheleteSectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [atheleteSectionTitles objectAtIndex:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionTitle = [atheleteSectionTitles objectAtIndex:section];
    NSArray *sectionAthelete = [allAtheletes objectForKey:sectionTitle];
    return [sectionAthelete count];
}
- (UITableViewCell *)tableView:(UITableView *)tableViewTemp cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AssignProffessionalTableViewCell *cell = (AssignProffessionalTableViewCell*)[tableViewTemp dequeueReusableCellWithIdentifier:@"proffessionalCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *sectionTitle = [atheleteSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionAthelete = [allAtheletes objectForKey:sectionTitle];
    NSDictionary *personInfoDict=[sectionAthelete objectAtIndex:indexPath.row];
    
    NSArray *objs = [selectedProffessionals allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", [personInfoDict objectForKey:@"userId"]];
    NSArray *matchingObjs = [objs filteredArrayUsingPredicate:predicate];
    
    if ([matchingObjs count] == 0){
        cell.checkBoxImageView.hidden=YES;
    }
    else{
        cell.checkBoxImageView.hidden=NO;

    }
    [AppCommonFunctions setRoundedView:cell.iconImageView toDiameter:cell.iconImageView.frame.size.height];
    cell.nameLabel.textColor=[UIColor colorWithRed:12/255.0 green:12/255.0 blue:12/255.0 alpha:1];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",[personInfoDict objectForKey:@"firstName"],[personInfoDict objectForKey:@"lastName"]];
    cell.iconImageView.image=nil;
        if ([[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[personInfoDict objectForKey:@"imageId"]]) {
            
            cell.iconImageView.image=[[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:[personInfoDict objectForKey:@"imageId"]];
        }
        else{
            NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
            TVRequest *request = [TVRequest fetchImageForUserFromBlobID:[personInfoDict objectForKey:@"imageId"] forAuth:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                if (!error) {
                    
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:[personInfoDict objectForKey:@"imageId"]];
                    __weak UIImageView* weakProfileImgView=cell.iconImageView;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakProfileImgView.image=image;
                    });
                } else {
                    NSLog(@"%@",error);
                }
            }];
            [request sendRequest];
        }
       return cell;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return atheleteIndexTitles;
}
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AssignProffessionalTableViewCell *cell = (AssignProffessionalTableViewCell*)[atableView cellForRowAtIndexPath:indexPath];
    NSString *sectionTitle = [atheleteSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionAthelete = [allAtheletes objectForKey:sectionTitle];
    NSDictionary *personInfoDict=[sectionAthelete objectAtIndex:indexPath.row];
    NSArray *objs = [selectedProffessionals allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", [personInfoDict objectForKey:@"userId"]];
    NSArray *matchingObjs = [objs filteredArrayUsingPredicate:predicate];
    
    if ([matchingObjs count] > 0)
    {
        cell.checkBoxImageView.hidden=YES;
        [selectedProffessionals removeObject:[matchingObjs objectAtIndex:0]];
    }
    else{
        cell.checkBoxImageView.hidden=NO;
        [selectedProffessionals addObject:personInfoDict];
    }
    NSMutableString *str = [[NSMutableString alloc]initWithString:@"You"];
    int count = 0;
    for (NSDictionary *personInfoDict in selectedProffessionals) {
        if (count < selectedProffessionals.count - 1) {
            [str appendString:@", "];
        }
        else {
            [str appendString:@" and "];
        }
        count++;
        if ([personInfoDict objectForKey:@"assigneeDetails"]) {
            
            [str appendString:[personInfoDict objectForKey:@"assigneeDetails"]];
        }
        else{
            [str appendString:[NSString stringWithFormat:@"%@ %@",[personInfoDict objectForKey:@"firstName"],[personInfoDict objectForKey:@"lastName"]]];
        }
    }
    [str appendString:@" are Currently assigned."];
    self.assignedProffessionalLabel.text = str;
    [self setAttributedTextOnAssignProffessionalLabel];
    
}
- (void)tableView:(UITableView *)atableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [atableView cellForRowAtIndexPath:indexPath];
    
    if (!cell.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString *sectionTitle = [atheleteSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionAthelete = [allAtheletes objectForKey:sectionTitle];
    NSDictionary *athelete = [sectionAthelete objectAtIndex:indexPath.row];
    [selectedProffessionals removeObject:athelete];
    self.assignedProffessionalLabel.text = @"You";
    NSMutableString *str = [[NSMutableString alloc]initWithString:@"You"];
    int count = 0;
    for (NSDictionary *personInfoDict in selectedProffessionals) {
        if (count < selectedProffessionals.count - 1) {
            [str appendString:@", "];
        }
        else {
            [str appendString:@" and "];
        }
        count++;
        if ([personInfoDict objectForKey:@"assigneeDetails"]) {
            
            [str appendString:[personInfoDict objectForKey:@"assigneeDetails"]];
        }
        else{
            [str appendString:[NSString stringWithFormat:@"%@ %@",[personInfoDict objectForKey:@"firstName"],[personInfoDict objectForKey:@"lastName"]]];
        }
    }
    [str appendString:@" are Currently assigned."];
    self.assignedProffessionalLabel.text = str;
    
    [self setAttributedTextOnAssignProffessionalLabel];
    ///
}
#pragma mark Search
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}
- (NSMutableArray *)getAllValuesOfDictionaryInAnArray:(NSDictionary *)dictionary {
    NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
    NSArray *athlt = [dictionary allValues];
    for (NSArray *tempArray in athlt) {
        [mutableArr addObjectsFromArray:tempArray];
    }
    return mutableArr;
}
#pragma mark On Click Actions
- (IBAction)onClickCancel:(UIButton *)sender {
    
    if (self.isfromCaseDetails) {
        [[AppCommonFunctions sharedInstance] dismissViewControllerWithShadow:self];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onclickDone:(id)sender {
    
    if (self.isfromCaseDetails) {
        SHOW_ACTIVITY_INDICATOR
        [self changeStatusofAssignees:[self.allredySelectedProffessionals allObjects]];
    }
    else{
        if([self.delegate respondsToSelector:@selector(responseWithData:)]) {
            [self.delegate responseWithData:selectedProffessionals];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark Custom Functions
- (void)setAttributedTextOnAssignProffessionalLabel {
    UIColor *foregroundColorBlue = [UIColor colorWithRed:2/255.0 green:115/255.0 blue:196/255.0 alpha:1];
    UIColor *foregroundColorLightGray = [UIColor lightGrayColor];
    NSDictionary *attrsBlue = [NSDictionary dictionaryWithObjectsAndKeys:
                               foregroundColorBlue, NSForegroundColorAttributeName, nil];
    NSDictionary *attrsLightGray = [NSDictionary dictionaryWithObjectsAndKeys:
                                    foregroundColorLightGray, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@"You" attributes:attrsBlue];
    NSAttributedString *comma = [[NSAttributedString alloc]initWithString:@", " attributes:attrsLightGray];
    NSAttributedString *and = [[NSAttributedString alloc] initWithString:@" and " attributes:attrsLightGray];
    
    int count = 0;
    for (NSDictionary *personInfoDict in selectedProffessionals) {
        if (count < selectedProffessionals.count - 1) {
            [str1 appendAttributedString:comma];
        }
        else {
            [str1 appendAttributedString:and];
        }
        count++;
        if ([personInfoDict objectForKey:@"assigneeDetails"]) {
            
            [str1 appendAttributedString:[[NSAttributedString alloc]initWithString:[personInfoDict objectForKey:@"assigneeDetails"] attributes:attrsBlue]];
        }
        else{
            [str1 appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",[personInfoDict objectForKey:@"firstName"],[personInfoDict objectForKey:@"lastName"]] attributes:attrsBlue]];
        }
        
    }
    [str1 appendAttributedString:[[NSAttributedString alloc]initWithString:@" are currently assigned." attributes:attrsLightGray]];
    self.assignedProffessionalLabel.attributedText  = str1;
}
#pragma mark Service Hits
-(void)changeStatusofAssignees:(NSArray*)allredySelectedProffessionals
{
    if (self.indexCount<allredySelectedProffessionals.count) {
        NSDictionary *personInfoDict=[allredySelectedProffessionals objectAtIndex:self.indexCount];
        NSArray *objs = [self.selectedProffessionals allObjects];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", [personInfoDict objectForKey:@"userId"]];
        NSArray *matchingObjs = [objs filteredArrayUsingPredicate:predicate];
        if ([matchingObjs count] == 0)
        {
            if ([personInfoDict objectForKey:@"statusId"] && [((NSNumber*)[personInfoDict objectForKey:@"statusId"]) isEqual:[NSNumber numberWithInt:1]]) {
                NSMutableDictionary *assignAttributes =  [[NSMutableDictionary alloc] init];
                [assignAttributes setObject:[personInfoDict objectForKey:@"userId"] forKey:@"assigneeId"];
                [assignAttributes setObject:[personInfoDict objectForKey:@"assigneeDetails"] forKey:@"assigneeDetails"];
                [assignAttributes setObject:[personInfoDict objectForKey:@"caseId"] forKey:@"caseId"];
                [assignAttributes setObject:[personInfoDict objectForKey:@"timeStampofLastVisit"] forKey:@"timeStampofLastVisit"];
                NSString *statusId=[NSString stringWithFormat:@"%@",[personInfoDict objectForKey:@"statusId"]];
                if ([statusId intValue]==0) {
                    [assignAttributes setObject:[NSNumber numberWithInt:1] forKey:@"statusId"];
                }
                else{
                    [assignAttributes setObject:[NSNumber numberWithInt:0] forKey:@"statusId"];
                }
                NSString *bodyDataString = [[TVHelper dataWithJSONObject:assignAttributes] base64EncodedStringWithOptions:0];
                NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",assigneeSchema,@"schema_id", nil];
                //service hit
                NSString *authString = APIKEYTrueVault;
                TVRequest *request = [TVRequest putDocumentwithData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents/%@", kEndpointVaults, VaultID,[personInfoDict objectForKey:@"document_id"]] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                    if (!error) {
                    ++self.indexCount;
                    } else {
                        NSLog(@"%@",error);
                    }
                    [self changeStatusofAssignees:allredySelectedProffessionals];
                }];
                [request sendRequest];
            }
            else{
                ++self.indexCount;
                [self changeStatusofAssignees:allredySelectedProffessionals];
            }
        }
        else{
            
            if ([personInfoDict objectForKey:@"statusId"] && [((NSNumber*)[personInfoDict objectForKey:@"statusId"]) isEqual:[NSNumber numberWithInt:0]]) {
                NSMutableDictionary *assignAttributes =  [[NSMutableDictionary alloc] init];
                [assignAttributes setObject:[personInfoDict objectForKey:@"userId"] forKey:@"assigneeId"];
                [assignAttributes setObject:[personInfoDict objectForKey:@"assigneeDetails"] forKey:@"assigneeDetails"];
                [assignAttributes setObject:[personInfoDict objectForKey:@"caseId"] forKey:@"caseId"];
                [assignAttributes setObject:[personInfoDict objectForKey:@"timeStampofLastVisit"] forKey:@"timeStampofLastVisit"];
                NSString *statusId=[NSString stringWithFormat:@"%@",[personInfoDict objectForKey:@"statusId"]];
                if ([statusId intValue]==0) {
                    [assignAttributes setObject:[NSNumber numberWithInt:1] forKey:@"statusId"];
                }
                else{
                    [assignAttributes setObject:[NSNumber numberWithInt:0] forKey:@"statusId"];
                }
                NSString *bodyDataString = [[TVHelper dataWithJSONObject:assignAttributes] base64EncodedStringWithOptions:0];
                NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",assigneeSchema,@"schema_id", nil];
                //service hit
                NSString *authString = APIKEYTrueVault;
                TVRequest *request = [TVRequest putDocumentwithData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents/%@", kEndpointVaults, VaultID,[personInfoDict objectForKey:@"document_id"]] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                    if (!error) {
                        ++self.indexCount;
                        [self.selectedProffessionals removeObject:[matchingObjs objectAtIndex:0]];
                    } else {
                        NSLog(@"%@",error);
                    }
                    [self changeStatusofAssignees:allredySelectedProffessionals];
                }];
                [request sendRequest];
            }
            else{
                
                [self.selectedProffessionals removeObject:[matchingObjs objectAtIndex:0]];
                ++self.indexCount;
                [self changeStatusofAssignees:allredySelectedProffessionals];
            }
        }
    }
    else{
        self.indexCount=0;
        NSMutableArray *proffessionalsArray=[NSMutableArray arrayWithArray:[self.selectedProffessionals allObjects]];
        [self addNewAssigneesToCase:proffessionalsArray];
    }
}
-(void)getProfessionals
{
    
    NSArray * filterValueArr = [[NSArray alloc] initWithObjects:UserRoleTrainer,UserRoleDoctor,UserRoleHeadDoctor, nil];
    NSMutableDictionary *filterRole  = [[NSMutableDictionary alloc] init];
    [filterRole setValue:filterValueArr forKey:@"value"];
    [filterRole setValue:@"in" forKeyPath:@"type"];
    NSDictionary *filter = [NSDictionary dictionaryWithObject:filterRole forKey:@"roleId"];
    //    NSMutableDictionary *filterActive  = [[NSMutableDictionary alloc] init];
    //    [filterActive setValue:[NSNumber numberWithInt:0] forKey:@"value"];
    //    [filterActive setValue:@"eq" forKeyPath:@"type"];
    //    NSDictionary *filter2 = [NSDictionary dictionaryWithObject:filterActive forKey:@"isActive"];
    //    NSArray *filterArr = [NSArray arrayWithObjects:filter,filter2, nil];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:filter forKey:@"filter"];
    [param setObject:@"1" forKey:@"full_document"];
    [param setObject:@"and" forKey:@"filter_type"];
    NSMutableDictionary *dictSort = [NSMutableDictionary dictionaryWithObject:@"asc" forKey:@"firstName"];
    NSArray * sort = [[NSArray alloc] initWithObjects:dictSort, nil];
    [param setObject:sort forKey:@"sort"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
    //service hit
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@",kEndpointUsers,kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            NSArray *arrData = [[responseDictionary objectForKey:@"data"] objectForKey:@"documents"];
            HIDE_ACTIVITY_INDICATOR
            for (id data in arrData) {
                NSString *encodedString = [data objectForKey:@"attributes"];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:decodedData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                if ([((NSString*)[json objectForKey:@"imageId"]) hasPrefix:@"/home/maheshy"]) {
                    continue;
                }
                NSString *userID =   [[AppCommonFunctions getDataFromNSUserDefault:@"userinfo"] objectForKey: @"userId"];
                if (![userID isEqualToString:[json objectForKey:@"userId"]])
                {
                    NSString* personName=[json objectForKey:@"firstName"];
                    NSString *firstLatter=[[personName substringToIndex:1] uppercaseString];
                    if ([allAtheletes objectForKey:firstLatter]) {
                        
                        NSMutableArray *previousArr=[NSMutableArray arrayWithArray:[allAtheletes objectForKey:firstLatter]];
                        [previousArr addObject:json];
                        [allAtheletes setObject:previousArr forKey:firstLatter];
                    }
                    else{
                        NSArray *tmpArray=@[json];
                        [allAtheletes setObject:tmpArray forKey:firstLatter];
                    }
                }
            }
            atheleteSectionTitles = [[allAtheletes allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            __weak AssignProffessionalVC *weakSelf=self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        } else {
            
            HIDE_ACTIVITY_INDICATOR
            NSLog(@"%@",error);
        }
    }];
    [request sendRequest];
}
-(void)changeUpdateTimeForCase
{
    NSMutableDictionary *dict =  [NSMutableDictionary dictionaryWithDictionary:self.caseDetailsDict];
    [dict setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"updatedAt"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:dict] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"document",caseschema,@"schema_id", nil];
    //service hit
    NSString *authString = APIKEYTrueVault;
    TVRequest *request = [TVRequest putDocumentwithData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents/%@", kEndpointVaults, VaultID,self.docId] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            self.caseDetailsDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            HIDE_ACTIVITY_INDICATOR
            [TSMessage showNotificationWithTitle:@"Case updated successfully." type:TSMessageNotificationTypeSuccess];
            [[AppCommonFunctions sharedInstance] dismissViewControllerWithShadow:self];
            
        } else {
            HIDE_ACTIVITY_INDICATOR
            NSLog(@"%@",error);
        }
    }];
    [request sendRequest];
}
-(void)addNewAssigneesToCase:(NSMutableArray*)proffessionalsArray
{
    if (self.indexCount<proffessionalsArray.count) {
        NSDictionary *proffessionalInfoDict=proffessionalsArray[self.indexCount];
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
        __weak AssignProffessionalVC *weakSelf=self;
        //service hit
        NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
        TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@/documents", kEndpointVaults, VaultID] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
            if (!error) {
                ++self.indexCount;
                [weakSelf addNewAssigneesToCase:proffessionalsArray];
                //self loop to add all the assignees in assignee table
            } else {
                NSLog(@"%@",error);
                [weakSelf addNewAssigneesToCase:proffessionalsArray];
            }
        }];
        [request sendRequest];
    }
    else{
        [self changeUpdateTimeForCase];
    }
}
@end
