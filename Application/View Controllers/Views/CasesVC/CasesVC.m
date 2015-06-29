//
//  CasesVC.m
//  Application
//
//  Created by Nakul Sharma on 6/9/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//
#import "AppCommonFunctions.h"
#import "CaseRepresentingCell.h"
#import "CasesVC.h"
#import "NewCaseVC.h"
#import "ApplicationSpecificConstants.h"
#import "CaseDetailVc.h"
#import "TVHelper.h"
#import "TVRequest.h"
#import "TVFile.h"
#import "SDWebImageManager.h"
#define pagecount 10
@interface CasesVC ()
{
    NSMutableArray *caseIDArr;
    __weak IBOutlet UILabel *errorTextLabel;
    __weak IBOutlet UIImageView *errorImageView;
}
@property (strong, nonatomic) NSMutableArray *caseArr;
@property (strong, nonatomic) NSMutableDictionary *casePageInfo;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
/** Pagination
 *  Set this flag when loading data.
 */
@property (nonatomic, assign) __block BOOL isLoading;
@end

@implementation CasesVC
#pragma mark UI Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    caseIDArr=[[NSMutableArray alloc] init];
    self.caseArr = [NSMutableArray array];
    errorTextLabel.textColor=[UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1];
    if (self.caseType==1) {
        [self getCountOfAssignees];
    }
    if (self.caseType==2) {
        [self getTotalCaseCount];
    }
    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.tableView sendSubviewToBack:refreshControl];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isLoading=NO;
    SHOW_ACTIVITY_INDICATOR
    [self getCountOfAssignees];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)needLayoutUpdateCustom {
    [[self view]setNeedsLayout];
    [[self view]layoutIfNeeded];
}
#pragma mark Pull to Refresh
-(void)refreshTable:(UIRefreshControl*)refresh{
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    // custom refresh logic would be placed here...
    self.isLoading=NO;
    SHOW_ACTIVITY_INDICATOR
    [self getCountOfAssignees];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
    
}
#pragma mark Custom Functions
- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit units = NSCalendarUnitSecond|NSCalendarUnitMinute|NSCalendarUnitHour|NSDayCalendarUnit | NSWeekOfYearCalendarUnit |
    NSMonthCalendarUnit | NSYearCalendarUnit;
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    if (components.year > 0) {
        if (components.year == 1) {
            return [NSString stringWithFormat:@"%ldy ago", (long)components.year];
        }
        return [NSString stringWithFormat:@"%ldy ago", (long)components.year];
    }
    else if (components.month > 0) {
        if (components.month == 1) {
            return [NSString stringWithFormat:@"%ldm ago", (long)components.month];
        }
        return [NSString stringWithFormat:@"%ldm ago", (long)components.month];
    }
    else if (components.weekOfYear > 0) {
        
        if (components.weekOfYear == 1){
            
            return [NSString stringWithFormat:@"%ldw ago", (long)components.weekOfYear];
        }
        return [NSString stringWithFormat:@"%ldw ago", (long)components.weekOfYear];
    }
    else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ldd ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else if(components.hour>0){
        if (components.day == 1){
            return [NSString stringWithFormat:@"%dh ago", (int)components.hour];
        }else {
            return [NSString stringWithFormat:@"%ldh ago", (long)components.hour];
            
        }
    }
    else if(components.minute>0){
        if (components.minute == 1){
            return [NSString stringWithFormat:@"%dm ago", (int)components.minute];
        }
        else {
            return [NSString stringWithFormat:@"%ldm ago", (long)components.minute];
        }
    }
    else return @"Just Now";
    
}
#pragma mark tableview datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.casePageInfo[@"total_result_count"]) {
        NSString *total_result_count=[NSString stringWithFormat:@"%@",self.casePageInfo[@"total_result_count"]];
        if (self.caseArr.count<[total_result_count intValue]) {
            return self.caseArr.count+1;
        }
        else{
            return self.caseArr.count;
        }
    }
    return self.caseArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==self.caseArr.count) {
        return 44;
    }
    return 111;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==self.caseArr.count) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"activityIndicatorcell" forIndexPath:indexPath];
        UIActivityIndicatorView *view=(UIActivityIndicatorView*)[cell.contentView viewWithTag:2111];
        [view startAnimating];
        NSString *current_page=[NSString stringWithFormat:@"%@",self.casePageInfo[@"current_page"]];
        [self fetchCaseWhereAssignedForpageNumber:[current_page intValue]+1];
        return cell;
    }
    CaseRepresentingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CaseRepresentingCell" forIndexPath:indexPath];
    //configure the cell
    NSDictionary *dictData = [self.caseArr objectAtIndex:indexPath.row];
    NSString *base64String =  [dictData objectForKey:@"document"];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if ([[dict objectForKey:@"priorityId"] intValue] != PriorityUrgent) {
        cell.caseNameLabel.textColor = [UIColor blackColor];
        cell.iconBgImageView.image=[UIImage imageNamed:@"whiteuser.png"];
    }
    else {
        cell.caseNameLabel.textColor = [UIColor redColor];
        cell.iconBgImageView.image=[UIImage imageNamed:@"reduser.png"];
    }
    NSArray *createForDetails = [[dict objectForKey:@"createdForDetails"] componentsSeparatedByString:@"--"];
    NSArray *createByDetails = [[dict objectForKey:@"createdByDetails"] componentsSeparatedByString:@"--"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"updatedAt"] doubleValue]];
    NSString *str = [self relativeDateStringForDate:date];
    
    if (createByDetails.count>=2) {
        cell.doctorName.text = [NSString stringWithFormat:@"%@ %@, %@",[createByDetails objectAtIndex:0],[createByDetails objectAtIndex:1],str];
    }
    cell.caseHistoryLabel.text = [dict objectForKey:@"description"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *createdForDetails = [[dict objectForKey:@"createdForDetails"] componentsSeparatedByString:@"--"];
    if (createdForDetails.count>2) {
        cell.caseNameLabel.text = [NSString stringWithFormat:@"%@ %@",[createForDetails objectAtIndex:0],[createForDetails objectAtIndex:1]];
        if ([[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[createdForDetails objectAtIndex:2]]) {
            
            cell.iconImageView.image=[[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:[createdForDetails objectAtIndex:2]];
        }
        else{
            NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
            TVRequest *request = [TVRequest fetchImageFromBlobID:[createdForDetails objectAtIndex:2] forAuth:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                if (!error) {
                    
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:[createdForDetails objectAtIndex:2]];
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
    }
    return cell;
}
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.caseType ==2) {
        
        return;
    }
    if (indexPath.row<self.caseArr.count) {
        
        NSMutableDictionary *dictData = [self.caseArr objectAtIndex:indexPath.row];
        
        NSString *base64String =  [dictData objectForKey:@"document"];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *documentId =  [dictData objectForKey:@"document_id"];
        CaseDetailVc *caseDetailObj = [self.storyboard instantiateViewControllerWithIdentifier:@"CaseDetailVc"];
        caseDetailObj.dictCase =dict;
        caseDetailObj.docID = documentId;
        [self.navigationController pushViewController:caseDetailObj animated:YES];
    }
}

#pragma mark Service Hits
-(void)getCountOfAssignees
{
    NSString *userID =   [[AppCommonFunctions getDataFromNSUserDefault:@"userinfo"] objectForKey: @"userId"];
    NSMutableDictionary *assignIDFilter  = [[NSMutableDictionary alloc] init];
    [assignIDFilter setValue:userID forKey:@"value"];
    [assignIDFilter setValue:@"eq" forKeyPath:@"type"];
    NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObject:assignIDFilter forKey:@"assigneeId"];
    NSMutableDictionary *filterStatus  = [[NSMutableDictionary alloc] init];
    [filterStatus setValue:[NSNumber numberWithInt:1] forKey:@"value"];
    [filterStatus setValue:@"eq" forKeyPath:@"type"];
    [filter setObject:filterStatus forKey:@"statusId"];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:filter forKey:@"filter"];
    [param setObject:@"and" forKey:@"filter_type"];
    [param setObject:assigneeSchema forKey:@"schema_id"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    //service hit
    TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, VaultID, kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            int count = [[[[responseDictionary objectForKey:@"data"] objectForKey :@"info"] objectForKey:@"total_result_count"] intValue];
            if (count) {
                [self  getassigneedCases:count];
            }
            else{
                HIDE_ACTIVITY_INDICATOR
                self.caseArr=[NSMutableArray array];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                errorImageView.hidden=NO;
                if (self.caseType==1) {
                    errorTextLabel.text=@"You have no closed cases.";
                }
                else if (self.caseType !=2){
                    errorTextLabel.text=@"You have no open cases.";
                }
                else{
                    errorTextLabel.text=@"No cases found.";
                    
                }
            }
        } else {
            HIDE_ACTIVITY_INDICATOR
            NSLog(@"%@",error);
            self.caseArr=[NSMutableArray array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            errorImageView.hidden=NO;
            errorTextLabel.text=@"Oops! We are unable to retrieve Cases. Please try again in a few minutes.";
        }
    }];
    [request sendRequest];
}

-(void)getassigneedCases:(int)count
{
    NSString *userID =   [[AppCommonFunctions getDataFromNSUserDefault:@"userinfo"] objectForKey: @"userId"];
    NSMutableDictionary *assignIDFilter  = [[NSMutableDictionary alloc] init];
    [assignIDFilter setValue:userID forKey:@"value"];
    [assignIDFilter setValue:@"eq" forKeyPath:@"type"];
    NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObject:assignIDFilter forKey:@"assigneeId"];
    NSMutableDictionary *filterStatus  = [[NSMutableDictionary alloc] init];
    [filterStatus setValue:[NSNumber numberWithInt:1] forKey:@"value"];
    [filterStatus setValue:@"eq" forKeyPath:@"type"];
    [filter setObject:filterStatus forKey:@"statusId"];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:filter forKey:@"filter"];
    [param setObject:@"and" forKey:@"filter_type"];
    [param setObject:assigneeSchema forKey:@"schema_id"];
    [param setObject:@"1" forKey:@"full_document"];
    [param setObject:[NSNumber numberWithInt:count] forKey:@"per_page"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    //service hit
    TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, VaultID, kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            for(NSDictionary *dictData in [[responseDictionary objectForKey:@"data"] objectForKey:@"documents"])
            {
                NSString *base64String =  [dictData objectForKey:@"document"];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
                NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                [caseIDArr addObject:[dict objectForKey:@"caseId"]];
            }
            [self fetchCaseWhereAssignedForpageNumber:1];
        } else {
            NSLog(@"%@",error);
            HIDE_ACTIVITY_INDICATOR
            self.caseArr=[NSMutableArray array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            errorImageView.hidden=NO;
            errorTextLabel.text=@"Oops! We are unable to retrieve Cases. Please try again in a few minutes.";
        }
    }];
    [request sendRequest];
}
-(void)fetchCaseWhereAssignedForpageNumber:(int)pageNo //fetch open cases
{
    if (self.caseType !=2) {
        
        
        if (!self.isLoading) {
            self.isLoading=YES;
            NSMutableDictionary *assignFilter  = [[NSMutableDictionary alloc] init];
            [assignFilter setValue:caseIDArr forKey:@"value"];
            [assignFilter setValue:@"in" forKeyPath:@"type"];
            NSMutableDictionary *filterStatus  = [[NSMutableDictionary alloc] init];
            [filterStatus setValue:[NSNumber numberWithInt:caseClosed] forKey:@"value"];
            if (self.caseType==1) {
                [filterStatus setValue:@"eq" forKeyPath:@"type"];
            }
            else if (self.caseType!=2){
                [filterStatus setValue:@"not" forKeyPath:@"type"];//change to eq for closed cases
            }
            
            NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObjectsAndKeys:filterStatus,@"statusId",assignFilter,@"caseId", nil];
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:filter forKey:@"filter"];
            [param setObject:@"and" forKey:@"filter_type"];
            [param setObject:caseschema forKey:@"schema_id"];
            [param setObject:@"1" forKey:@"full_document"];
            [param setObject:[NSNumber numberWithInt:pagecount] forKey:@"per_page"];
            [param setObject:[NSNumber numberWithInt:pageNo] forKey:@"page"];
            NSMutableDictionary *dictSort1 = [NSMutableDictionary dictionaryWithObject:@"asc" forKey:@"priorityId"];
            NSMutableDictionary *dictSort2 = [NSMutableDictionary dictionaryWithObject:@"desc" forKey:@"updatedAt"];
            NSArray * sort = [[NSArray alloc] initWithObjects:dictSort1,dictSort2,nil];
            [param setObject:sort forKey:@"sort"];
            NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
            NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
            //service hit
            TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, VaultID, kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                if (!error) {
                    HIDE_ACTIVITY_INDICATOR
                    if (pageNo==1) {
                        self.caseArr=[NSMutableArray array];
                    }
                    self.casePageInfo=[NSMutableDictionary dictionaryWithDictionary:[[responseDictionary objectForKey:@"data"] objectForKey:@"info"]];
                    if (self.caseType ==1) {
                        self.menuView.closedCountLabel.text=[NSString stringWithFormat:@"%@",[self.casePageInfo objectForKey:@"total_result_count"]];

                    }
                    else
                    {
                        self.menuView.openCountLabel.text=[NSString stringWithFormat:@"%@",[self.casePageInfo objectForKey:@"total_result_count"]];

                    }
                    
                    [self.caseArr addObjectsFromArray:[[responseDictionary objectForKey:@"data"] objectForKey:@"documents"]];
                    if (self.caseArr.count==0) {
                        self.caseArr=[NSMutableArray array];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                        errorImageView.hidden=NO;
                        if (self.caseType==1) {
                            errorTextLabel.text=@"You have no closed cases.";
                        }
                        else if (self.caseType !=2){
                            errorTextLabel.text=@"You have no open cases.";
                        }
                        else{
                            errorTextLabel.text=@"No cases found.";
                            
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                        errorImageView.hidden=YES;
                        errorTextLabel.text=@"";
                    }
                    
                } else {
                    self.caseArr=[NSMutableArray array];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    errorImageView.hidden=NO;
                    errorTextLabel.text=@"Oops! We are unable to retrieve Cases. Please try again in a few minutes.";
                }
                HIDE_ACTIVITY_INDICATOR
                self.isLoading=NO;
            }];
            [request sendRequest];
        }
    }
    else
    {
        if (!self.isLoading) {
            NSMutableDictionary *wildCardFilter  = [[NSMutableDictionary alloc] init];
            [wildCardFilter setValue:@"*" forKey:@"value"];
            [wildCardFilter setValue:@"wildcard" forKeyPath:@"type"];
            NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObjectsAndKeys:wildCardFilter,@"caseId", nil];
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:filter forKey:@"filter"];
            [param setObject:caseschema forKey:@"schema_id"];
            [param setObject:@"1" forKey:@"full_document"];
            [param setObject:[NSNumber numberWithInt:pagecount] forKey:@"per_page"];
            [param setObject:[NSNumber numberWithInt:pageNo] forKey:@"page"];
            NSMutableDictionary *dictSort1 = [NSMutableDictionary dictionaryWithObject:@"asc" forKey:@"priorityId"];
            NSMutableDictionary *dictSort2 = [NSMutableDictionary dictionaryWithObject:@"desc" forKey:@"updatedAt"];
            NSArray * sort = [[NSArray alloc] initWithObjects:dictSort1,dictSort2,nil];
            [param setObject:sort forKey:@"sort"];
            NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
            NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
            //service hit
            TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, VaultID, kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
                if (!error) {
                    HIDE_ACTIVITY_INDICATOR
                    if (pageNo==1) {
                        self.caseArr=[NSMutableArray array];
                    }
                    self.casePageInfo=[NSMutableDictionary dictionaryWithDictionary:[[responseDictionary objectForKey:@"data"] objectForKey:@"info"]];
                    self.menuView.allCountLabel.text=[NSString stringWithFormat:@"%@",[self.casePageInfo objectForKey:@"total_result_count"]];
                    
                    [self.caseArr addObjectsFromArray:[[responseDictionary objectForKey:@"data"] objectForKey:@"documents"]];
                    if (self.caseArr.count==0) {
                        self.caseArr=[NSMutableArray array];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                        errorImageView.hidden=NO;

                        errorTextLabel.text=@"No cases found.";
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                        errorImageView.hidden=YES;
                        errorTextLabel.text=@"";
                    }
                    
                } else {
                    self.caseArr=[NSMutableArray array];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    errorImageView.hidden=NO;
                    errorTextLabel.text=@"Oops! We are unable to retrieve Cases. Please try again in a few minutes.";
                }
                HIDE_ACTIVITY_INDICATOR
                self.isLoading=NO;
            }];
            [request sendRequest];
        }
        
    }
}
-(void)getTotalCaseCount
{
    NSMutableDictionary *wildCardFilter  = [[NSMutableDictionary alloc] init];
    [wildCardFilter setValue:@"*" forKey:@"value"];
    [wildCardFilter setValue:@"wildcard" forKeyPath:@"type"];
    NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObjectsAndKeys:wildCardFilter,@"caseId", nil];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:filter forKey:@"filter"];
    [param setObject:caseschema forKey:@"schema_id"];
    [param setObject:@"0" forKey:@"full_document"];
    [param setObject:[NSNumber numberWithInt:1] forKey:@"per_page"];
    [param setObject:[NSNumber numberWithInt:1] forKey:@"page"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    //service hit
    TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, VaultID, kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            HIDE_ACTIVITY_INDICATOR
            int count = [[[[responseDictionary objectForKey:@"data"] objectForKey :@"info"] objectForKey:@"total_result_count"] intValue];
            self.menuView.allCountLabel.text = [NSString stringWithFormat:@"%@",[[[responseDictionary objectForKey:@"data"] objectForKey :@"info"] objectForKey:@"total_result_count"]];
            if (count) {
                [self fetchCaseWhereAssignedForpageNumber:1];
            }
            else
            {
                HIDE_ACTIVITY_INDICATOR
                self.caseArr=[NSMutableArray array];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                errorImageView.hidden=NO;
                errorTextLabel.text=@"No cases found.";
            }
        } else {
            self.caseArr=[NSMutableArray array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            errorImageView.hidden=NO;
            errorTextLabel.text=@"Oops! We are unable to retrieve Cases. Please try again in a few minutes.";
        }
        HIDE_ACTIVITY_INDICATOR
        self.isLoading=NO;
    }];
    [request sendRequest];
}
@end
