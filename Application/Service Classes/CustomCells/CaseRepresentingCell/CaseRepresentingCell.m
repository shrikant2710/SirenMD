//
//  CaseRepresentingCell.m
//  Application
//
//  Created by Nakul Sharma on 6/10/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import "CaseRepresentingCell.h"
#import "NSCommonMethod.h"
#import "AppCommonFunctions.h"
@implementation CaseRepresentingCell
@synthesize iconImageView, caseHistoryLabel, caseNameLabel, doctorName;


-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    //    self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2;
    [AppCommonFunctions setRoundedView:self.iconImageView toDiameter:self.iconImageView.frame.size.height];
    //self.iconImageView.layer.borderWidth = 3.0;
    self.iconImageView.layer.masksToBounds = YES;
    //    self.iconImageView.layer.rasterizationScale = 4.0 * [UIScreen mainScreen].scale;
    //    self.iconImageView.layer.shouldRasterize = YES;
    //self.iconBgImageView.layer.cornerRadius = self.iconBgImageView.frame.size.height / 2;
    //    [AppCommonFunctions setRoundedView:self.iconBgImageView toDiameter:self.iconImageView.frame.size.height];
    //    self.iconBgImageView.layer.borderWidth = 3.0;
    //    self.iconBgImageView.layer.masksToBounds = YES;
    //    self.iconBgImageView.layer.rasterizationScale = 4.0 * [UIScreen mainScreen].scale;
    //    self.iconBgImageView.layer.shouldRasterize = YES;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
