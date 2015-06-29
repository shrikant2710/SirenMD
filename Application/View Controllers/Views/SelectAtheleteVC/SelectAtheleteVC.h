//
//  SelectAtheleteVC.h
//  Application
//
//  Created by Nakul Sharma on 6/13/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewCaseVC;

@interface SelectAtheleteVC : UIViewController

@property (weak, nonatomic) NewCaseVC *nCasedelegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *allAtheletes;
@property (strong, nonatomic) NSDictionary *selectedAthlete;
@property (strong, nonatomic) NSArray *atheleteSectionTitles;
@property (strong, nonatomic) NSArray *atheleteIndexTitles;
@property (strong, nonatomic) NSMutableArray *filteredAthelete;
@property (strong, nonatomic) NSArray *ArrOfAllAtheletes;
@property BOOL isSearching;

@end
