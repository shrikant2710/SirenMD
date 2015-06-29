//
//  CaseRepresentingCell.h
//  Application
//
//  Created by Nakul Sharma on 6/10/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaseRepresentingCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *iconImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *iconBgImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *caseNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *caseHistoryLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *doctorName;
@end
