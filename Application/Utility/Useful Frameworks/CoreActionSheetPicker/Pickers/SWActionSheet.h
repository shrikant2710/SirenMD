//
// Created by Petr Korolev on 11/08/14.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AbstractActionSheetPicker;

@interface SWActionSheet : UIView
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic,weak)AbstractActionSheetPicker *abstractActionSheetPicker;
- (void)dismissWithClickedButtonIndex:(int)i animated:(BOOL)animated;

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;

- (id)initWithView:(UIView *)view;

- (void)showInContainerView;
@end