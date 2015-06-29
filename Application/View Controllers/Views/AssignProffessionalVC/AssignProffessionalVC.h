//
//  AssignProffessionalVC.h
//  Application
//
//  Created by Nakul Sharma on 6/16/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//
#import "AppCommonFunctions.h"
#import <UIKit/UIKit.h>

@protocol AssignProffessionalVCDelegate <NSObject>
@optional
- (void)responseWithData:(NSSet *)arr;
@end

@interface AssignProffessionalVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *assignedProffessionalLabel;
@property (nonatomic, weak) id <AssignProffessionalVCDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *allAtheletes;
@property (strong, nonatomic) NSMutableDictionary *caseDetailsDict;
@property (strong, nonatomic) NSDictionary *copOfallAtheletes;
@property (strong, nonatomic) NSArray *atheleteSectionTitles;
@property (strong, nonatomic) NSArray *atheleteIndexTitles;
@property (strong, nonatomic) NSMutableArray *filteredAthelete;
@property (strong, nonatomic) NSArray *ArrOfAllAtheletes;
@property (strong, nonatomic) NSMutableSet *selectedProffessionals;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (strong, nonatomic) NSString *docId;
@property int index;
@property BOOL isfromCaseDetails;
@property (strong, nonatomic)  NSString *caseId;
@property (strong, nonatomic) NSMutableSet *allredySelectedProffessionals;
-(void)getProfessionals;
- (NSMutableArray *)getAllValuesOfDictionaryInAnArray:(NSDictionary *)dictionary;
- (IBAction)onClickCancel:(UIButton *)sender;
- (IBAction)onclickDone:(id)sender;

@end
