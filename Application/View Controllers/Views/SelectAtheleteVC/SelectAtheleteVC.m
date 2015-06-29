//
//  SelectAtheleteVC.m
//  Application
//
//  Created by Nakul Sharma on 6/13/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//
//
//  SelectAtheleteTableViewCell.h
//  Application
//
//  Created by Nakul Sharma on 6/10/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAtheleteTableViewCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *iconImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *iconBgImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *checkBoxImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;

@end


//
//  SelectAtheleteTableViewCell.m
//  Application
//
//  Created by Nakul Sharma on 6/10/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

@implementation SelectAtheleteTableViewCell
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



#import "SelectAtheleteVC.h"
#import "Athelete.h"
#import "TVHelper.h"
#import "TVRequest.h"
#import "TVPrivateConstants.h"
#import "NewCaseVC.h"
#import "TVFile.h"
#import "SDWebImageManager.h"

@interface SelectAtheleteVC ()
- (IBAction)onClickCancel:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *assignProffessionalsHeaderText;
@end

@implementation SelectAtheleteVC
@synthesize allAtheletes, atheleteSectionTitles, atheleteIndexTitles, tableView, filteredAthelete, searchBar, ArrOfAllAtheletes, selectedAthlete, isSearching;
#pragma mark UI Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    filteredAthelete = nil;
    atheleteIndexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    allAtheletes=[NSMutableDictionary dictionary];
    isSearching = NO;
    self.tableView.bounces = YES;
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:244/255.0 green:0/255.0 blue:0/255.0 alpha:1] forState:UIControlStateNormal];
    self.assignProffessionalsHeaderText.textColor=[UIColor colorWithRed:12/255.0 green:12/255.0 blue:12/255.0 alpha:1];
    self.tableView.sectionIndexColor=[UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1];
    for (UIView *subView in searchBar.subviews) {
        for(id field in subView.subviews){
            if ([field isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)field;
                [textField setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1]];
            }
        }
    }
    SHOW_ACTIVITY_INDICATOR
    [self getAtheletesSearched];
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
#pragma mark On Click Actions
- (IBAction)onClickCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Custom Functions
- (NSMutableArray *)getAllValuesOfDictionaryInAnArray:(NSDictionary *)dictionary {
    NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
    NSArray *athlt = [dictionary allValues];
    for (NSArray *tempArray in athlt) {
        [mutableArr addObjectsFromArray:tempArray];
    }
    return mutableArr;
}
-(void)reloadTable{
    [self.tableView reloadData];
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
    if (isSearching) {
        return 1;
    }
    return atheleteSectionTitles.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!isSearching) {
        return [atheleteSectionTitles objectAtIndex:section];
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isSearching) {
        return ArrOfAllAtheletes.count;
    }
    else {
        NSString *sectionTitle = [atheleteSectionTitles objectAtIndex:section];
        NSArray *sectionAthelete = [allAtheletes objectForKey:sectionTitle];
        return [sectionAthelete count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableViewTemp cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectAtheleteTableViewCell *cell = (SelectAtheleteTableViewCell*)[tableViewTemp dequeueReusableCellWithIdentifier:@"atheleteCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *personInfoDict=nil;
    if (isSearching) {
        
        personInfoDict = [ArrOfAllAtheletes objectAtIndex:indexPath.row];
    }
    else {
        NSString *sectionTitle = [atheleteSectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionAthelete = [allAtheletes objectForKey:sectionTitle];
        personInfoDict = [sectionAthelete objectAtIndex:indexPath.row];
    }
    if ([personInfoDict isEqualToDictionary:self.selectedAthlete]) {
        cell.checkBoxImageView.hidden=NO;
    }
    else{
        cell.checkBoxImageView.hidden=YES;
    }
    cell.nameLabel.textColor=[UIColor colorWithRed:12/255.0 green:12/255.0 blue:12/255.0 alpha:1];

    [AppCommonFunctions setRoundedView:cell.iconImageView toDiameter:cell.iconImageView.frame.size.height];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",[personInfoDict objectForKey:@"firstName"],[personInfoDict objectForKey:@"lastName"]];
    cell.iconImageView.image=nil;
    if ([[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[personInfoDict objectForKey:@"imageId"]]) {
        
        cell.iconImageView.image=[[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:[personInfoDict objectForKey:@"imageId"]];
    }
    else{
        NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
        TVRequest *request = [TVRequest fetchImageFromBlobID:[personInfoDict objectForKey:@"imageId"] forAuth:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
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
    [self.tableView updateConstraintsIfNeeded];
    [self.tableView layoutIfNeeded];
    return cell;
}
#pragma mark Tableview Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* personInfoDict=nil;
    if (isSearching) {

        personInfoDict = [ArrOfAllAtheletes objectAtIndex:indexPath.row];

    }
    else {
        NSString *sectionTitle = [atheleteSectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionAthelete = [allAtheletes objectForKey:sectionTitle];
        personInfoDict = [sectionAthelete objectAtIndex:indexPath.row];

    }
    self.nCasedelegate.atheleteNameLable.text = [NSString stringWithFormat:@"%@ %@",[personInfoDict objectForKey:@"firstName"],[personInfoDict objectForKey:@"lastName"]];
    self.nCasedelegate.selectedAthlete=personInfoDict;
    [self dismissViewControllerAnimated:YES completion:nil];
  
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return atheleteIndexTitles;
}
#pragma mark Search
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    isSearching = YES;
    ArrOfAllAtheletes = [self getAllValuesOfDictionaryInAnArray:allAtheletes];
    filteredAthelete = [[NSMutableArray alloc]init];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"firstName contains[c] %@ OR lastName contains[c] %@", searchText,searchText];
    [filteredAthelete addObjectsFromArray:[ArrOfAllAtheletes filteredArrayUsingPredicate:resultPredicate]];
    if (searchText.length > 0) {
        
        ArrOfAllAtheletes = filteredAthelete;
    }
    else {
        
        isSearching = NO;
        filteredAthelete = [ArrOfAllAtheletes mutableCopy];
    }
    [tableView reloadData];
}
#pragma mark Service Hits
-(void)getAtheletesSearched
{
    NSMutableDictionary *filterRole  = [[NSMutableDictionary alloc] init];
    [filterRole setValue:@"*" forKey:@"value"];
    [filterRole setValue:@"wildcard" forKeyPath:@"type"];
    NSDictionary *filter = [NSDictionary dictionaryWithObject:filterRole forKey:@"firstName"];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:atheleteSchema forKey:@"schema_id"];
    [param setObject:@"1" forKey:@"full_document"];
    [param setObject:filter forKey:@"filter"];
    NSMutableDictionary *dictSort = [NSMutableDictionary dictionaryWithObject:@"asc" forKey:@"firstName"];
    NSArray * sort = [[NSArray alloc] initWithObjects:dictSort, nil];
    [param setObject:sort forKey:@"sort"];
    NSString *bodyDataString = [[TVHelper dataWithJSONObject:param] base64EncodedStringWithOptions:0];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bodyDataString,@"search_option",nil];
    NSString *authString = [AppCommonFunctions getDataFromNSUserDefault:@"access_token"];
    //service hit
    TVRequest *request = [TVRequest postRequesforFormData:paramDict endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, VaultID, kEndpointSearch] withAuthHeader:authString completion:^(NSDictionary *responseDictionary, NSData *data, NSError *error) {
        if (!error) {
            HIDE_ACTIVITY_INDICATOR
            for(NSDictionary *dictData in [[responseDictionary objectForKey:@"data"] objectForKey:@"documents"])
            {
                NSString *base64String =  [dictData objectForKey:@"document"];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
                NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                NSString* personName=[dict objectForKey:@"firstName"];
                NSString *firstLatter=[[personName substringToIndex:1] uppercaseString];
                if ([allAtheletes objectForKey:firstLatter]) {
                    
                    NSMutableArray *previousArr=[NSMutableArray arrayWithArray:[allAtheletes objectForKey:firstLatter]];
                    [previousArr addObject:dict];
                    [allAtheletes setObject:previousArr forKey:firstLatter];
                }
                else{
                    NSArray *tmpArray=@[dict];
                    [allAtheletes setObject:tmpArray forKey:firstLatter];
                }
            }
            ArrOfAllAtheletes = [self getAllValuesOfDictionaryInAnArray:allAtheletes];
            atheleteSectionTitles = [[allAtheletes allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.3];
        } else {
            NSLog(@"%@",error);
        }
    }];
    [request sendRequest];
}
@end


