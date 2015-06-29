//
//  YSLScrollMenuView.m
//  YSLContainerViewController
//
//  Created by yamaguchi on 2015/03/03.
//  Copyright (c) 2015年 h.yamaguchi. All rights reserved.
//

#import "YSLScrollMenuView.h"

static const CGFloat kYSLScrollMenuViewWidth  = 90;
static const CGFloat kYSLScrollMenuViewMargin = 10;
static const CGFloat kYSLIndicatorHeight = 3;

@interface YSLScrollMenuView ()


@property (nonatomic, strong) UIView *indicatorView;
@property (retain, nonatomic) UIButton *openButton;
@property (retain, nonatomic) UIButton *closedButton;
@property (retain, nonatomic) UIButton *allButton;


@end

@implementation YSLScrollMenuView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // default
        
        _viewbackgroudColor = [UIColor whiteColor];
        _itemfont = [UIFont systemFontOfSize:16];
        _itemTitleColor = [UIColor colorWithRed:0.866667 green:0.866667 blue:0.866667 alpha:1.0];
        _itemSelectedTitleColor = [UIColor colorWithRed:0.333333 green:0.333333 blue:0.333333 alpha:1.0];
        _itemIndicatorColor = [UIColor darkGrayColor];
        
        self.backgroundColor = _viewbackgroudColor;
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        self.openButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.allButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [self setItemTextColorForcurrentIndex:0];
        [self.openButton addTarget:self action:@selector(onClickOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self.closedButton addTarget:self action:@selector(onClickClosed:) forControlEvents:UIControlEventTouchUpInside];
        [self.allButton addTarget:self action:@selector(onClickAll:) forControlEvents:UIControlEventTouchUpInside];

        
           self.allCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth * 5/6+14,10, 25, 25)];

        NSDictionary *dictData = [AppCommonFunctions getDataFromNSUserDefault:@"userinfo"];

        if ([[dictData objectForKey:@"roleId"] intValue] == [UserRoleHeadDoctor intValue]){
            
            self.openButton.frame = CGRectMake(0, 0, screenWidth/3, 44);
            self.closedButton.frame = CGRectMake(screenWidth/3, 0, screenWidth/3, 44);
            self.allButton.frame = CGRectMake(screenWidth *2/3, 0, screenWidth/3, 44);

            self.openCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/6+19,10, 25, 25)];
            self.closedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth /2+27,10, 25, 25)];
            self.openCountLabel.layer.cornerRadius = (self.openCountLabel.frame.size.height / 2) ;
            self.openCountLabel.layer.masksToBounds = YES;
            self.closedCountLabel.layer.cornerRadius = (self.closedCountLabel.frame.size.height / 2);
            self.closedCountLabel.layer.masksToBounds = YES;
            self.allCountLabel.layer.cornerRadius = (self.allCountLabel.frame.size.height / 2);
            self.allCountLabel.layer.masksToBounds = YES;
            [self addSubview:_scrollView];
            [self addSubview:self.openButton];
            [self addSubview:self.closedButton];
            [self addSubview:self.allButton];

            [self addSubview:self.openCountLabel];
            [self addSubview:self.closedCountLabel];
            [self addSubview:self.allCountLabel];



        }
        else{
            self.openButton.frame = CGRectMake(0, 0, screenWidth/2, 44);
            self.closedButton.frame = CGRectMake(screenWidth/2, 0, screenWidth/2, 44);
            self.openCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4+30,10, 25, 25)];
            self.closedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth *3/4+40,10, 25, 25)];
            self.openCountLabel.layer.cornerRadius = (self.openCountLabel.frame.size.height / 2) ;
            self.openCountLabel.layer.masksToBounds = YES;
            self.closedCountLabel.layer.cornerRadius = (self.closedCountLabel.frame.size.height / 2);
            self.closedCountLabel.layer.masksToBounds = YES;
            [self addSubview:_scrollView];
            [self addSubview:self.openButton];
            [self addSubview:self.closedButton];
            [self addSubview:self.openCountLabel];
            [self addSubview:self.closedCountLabel];

        }
    }
    
    [self.openButton setTitle:@"OPEN" forState:UIControlStateNormal];
    self.openButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    self.closedButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    self.openCountLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    self.closedCountLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    [self.closedButton setTitle:@"CLOSED" forState:UIControlStateNormal];
    
    [self.allButton setTitle:@"ALL" forState:UIControlStateNormal];
    self.allButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    self.allCountLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];

    
    self.openCountLabel.text =@"0";
    self.closedCountLabel.text =@"0";
    self.allCountLabel.text =@"0";

    self.openCountLabel.textAlignment = 1;
    self.closedCountLabel.textAlignment = 1;
    self.allCountLabel.textAlignment = 1;


    return self;
}

#pragma mark -- Setter

- (void)setViewbackgroudColor:(UIColor *)viewbackgroudColor
{
    if (!viewbackgroudColor) { return; }
    _viewbackgroudColor = viewbackgroudColor;
    self.backgroundColor = viewbackgroudColor;
}

- (void)setItemfont:(UIFont *)itemfont
{
    if (!itemfont) { return; }
    _itemfont = itemfont;
    for (UILabel *label in _itemTitleArray) {
        label.font = itemfont;
    }
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor
{
    if (!itemTitleColor) { return; }
    _itemTitleColor = itemTitleColor;
    for (UILabel *label in _itemTitleArray) {
        label.textColor = itemTitleColor;
    }
}

- (void)setItemIndicatorColor:(UIColor *)itemIndicatorColor
{
    
    _itemIndicatorColor = [UIColor darkGrayColor];
    _indicatorView.backgroundColor = [UIColor darkGrayColor];
}

- (void)setItemTitleArray:(NSArray *)itemTitleArray
{
    if (_itemTitleArray != itemTitleArray) {
        _itemTitleArray = itemTitleArray;
        NSMutableArray *views = [NSMutableArray array];
        
        
        // CGRect frame = CGRectMake(0, 0, kYSLScrollMenuViewWidth, CGRectGetHeight(self.frame));
        [self.scrollView addSubview:self.openButton];
        [self.scrollView addSubview:self.closedButton];
        [self.scrollView addSubview:self.allButton];

        
        [self.scrollView addSubview:self.closedCountLabel];
        [self.scrollView addSubview:self.allCountLabel];
        [self.scrollView addSubview:self.openCountLabel];
        
        
        
        [views addObject:self.openButton];
        [views addObject:self.allButton];
        [views addObject:self.closedButton];
        
        //            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemViewTapAction:)];
        //            [itemView addGestureRecognizer:tapGesture];
        
        
        self.itemViewArray = [NSArray arrayWithArray:views];
        
        // indicator
        _indicatorView = [[UIView alloc]init];
        _indicatorView.frame = CGRectMake(10, _scrollView.frame.size.height - kYSLIndicatorHeight, kYSLScrollMenuViewWidth, kYSLIndicatorHeight);
        _indicatorView.backgroundColor = self.itemIndicatorColor;
        [_scrollView addSubview:_indicatorView];
    }
}

- (void)onClickOpen:(UIButton *)sender {
    sender.backgroundColor = [UIColor blackColor];
    self.openCountLabel.backgroundColor = [UIColor blackColor];
    sender.titleLabel.textColor = [UIColor whiteColor]; [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.openCountLabel.textColor = [UIColor whiteColor];
    [self toggleButtons:self.closedButton andLabel:self.closedCountLabel];
    [self toggleButtons:self.allButton andLabel:self.allCountLabel];

    [self.delegate scrollMenuViewSelectedIndex:0];
}




- (void)onClickClosed:(UIButton *)sender {
    sender.backgroundColor = [UIColor blackColor];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.closedCountLabel.textColor =[UIColor whiteColor];
    self.closedCountLabel.backgroundColor = [UIColor blackColor];
    [self toggleButtons:self.openButton andLabel:self.openCountLabel];
    [self toggleButtons:self.allButton andLabel:self.allCountLabel];
    [self.delegate scrollMenuViewSelectedIndex:1];
    
}
- (void)onClickAll:(UIButton *)sender {
    sender.backgroundColor = [UIColor blackColor];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.allCountLabel.textColor =[UIColor whiteColor];
    self.allCountLabel.backgroundColor = [UIColor blackColor];
    [self toggleButtons:self.closedButton andLabel:self.closedCountLabel];
    [self toggleButtons:self.openButton andLabel:self.openCountLabel];
    [self.delegate scrollMenuViewSelectedIndex:2];
    
}

- (void)toggleButtons:(UIButton *)button andLabel:(UILabel *)label {
    CGFloat red = 13.0 / 255.0; CGFloat green = 93.0 / 255.0; CGFloat blue = 183.0 / 255.0;
    UIColor *labelTextColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.9];
    CGFloat bred = 35.0 / 255.0; CGFloat bgreen = 72.0 / 255.0; CGFloat bblue = 106.0 / 255.0;
    button.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.9];
    ;
    button.titleLabel.textColor = [UIColor colorWithRed:bred green:bgreen blue:bblue alpha:0.9];
    label.backgroundColor = [UIColor colorWithRed:bred green:bgreen blue:bblue alpha:0.9];
    label.textColor = labelTextColor;
    
}

#pragma mark -- public

- (void)setIndicatorViewFrameWithRatio:(CGFloat)ratio isNextItem:(BOOL)isNextItem toIndex:(NSInteger)toIndex
{
    CGFloat indicatorX = 0.0;
    if (isNextItem) {
        indicatorX = ((kYSLScrollMenuViewMargin + kYSLScrollMenuViewWidth) * ratio ) + (toIndex * kYSLScrollMenuViewWidth) + ((toIndex + 1) * kYSLScrollMenuViewMargin);
    } else {
        indicatorX =  ((kYSLScrollMenuViewMargin + kYSLScrollMenuViewWidth) * (1 - ratio) ) + (toIndex * kYSLScrollMenuViewWidth) + ((toIndex + 1) * kYSLScrollMenuViewMargin);
    }
    
    if (indicatorX < kYSLScrollMenuViewMargin || indicatorX > self.scrollView.contentSize.width - (kYSLScrollMenuViewMargin + kYSLScrollMenuViewWidth)) {
        return;
    }
    _indicatorView.frame = CGRectMake(indicatorX, _scrollView.frame.size.height - kYSLIndicatorHeight, kYSLScrollMenuViewWidth, kYSLIndicatorHeight);
    //  NSLog(@"retio : %f",_indicatorView.frame.origin.x);
}

- (void)setItemTextColorForcurrentIndex:(NSInteger)currentIndex
{
    
    UIColor * menuNameTextColor =[UIColor colorWithRed:35.0/255.0 green:72.0/255.0 blue:106.0/255.0 alpha:0.9];
    UIColor * menuNameSelectedTextColor = [UIColor whiteColor];
    UIColor * menuBackGroudColor = [UIColor colorWithRed:13.0/255.0 green:93/255.0 blue:183/255.0 alpha:0.9];
    UIColor * menuBackGroudSelectedColor =  [UIColor blackColor];
    UIColor * menuCircleBgColor = [UIColor colorWithRed:35.0/255.0 green:72.0/255.0 blue:106.0/255.0 alpha:0.9];
    UIColor * menuCircleSelectedBgColor = [UIColor blackColor];
    UIColor * menuCircleTextColor = [UIColor colorWithRed:13.0/255.0 green:93/255.0 blue:183/255.0 alpha:0.9];
    UIColor * menuCircleSelectedTextColor = [UIColor whiteColor];

    
    if (currentIndex == 0) {
        
        self.openButton.backgroundColor = menuBackGroudSelectedColor;
        self.closedButton.backgroundColor = menuBackGroudColor;
        self.allButton.backgroundColor = menuBackGroudColor;
        
        [self.openButton setTitleColor:menuNameSelectedTextColor forState:UIControlStateNormal];
        [self.allButton setTitleColor:menuNameTextColor forState:UIControlStateNormal];
        [self.closedButton setTitleColor:menuNameTextColor forState:UIControlStateNormal];
        
        self.openCountLabel.backgroundColor = menuCircleSelectedBgColor ;
        self.closedCountLabel.backgroundColor = menuCircleBgColor ;
        self.allCountLabel.backgroundColor = menuCircleBgColor ;
        
        self.openCountLabel.textColor = menuCircleSelectedTextColor ;
        self.closedCountLabel.textColor = menuCircleTextColor ;
        self.allCountLabel.textColor = menuCircleTextColor ;
        
    }
    else if  (currentIndex == 1)
    {
        
        self.closedButton.backgroundColor = menuBackGroudSelectedColor;
        self.openButton.backgroundColor = menuBackGroudColor;
        self.allButton.backgroundColor = menuBackGroudColor;
        
        [self.closedButton setTitleColor:menuNameSelectedTextColor forState:UIControlStateNormal];
        [self.allButton setTitleColor:menuNameTextColor forState:UIControlStateNormal];
        [self.openButton setTitleColor:menuNameTextColor forState:UIControlStateNormal];
        
        self.closedCountLabel.backgroundColor = menuCircleSelectedBgColor ;
        self.openCountLabel.backgroundColor = menuCircleBgColor ;
        self.allCountLabel.backgroundColor = menuCircleBgColor ;
        
        self.closedCountLabel.textColor = menuCircleSelectedTextColor ;
        self.openCountLabel.textColor = menuCircleTextColor ;
        self.allCountLabel.textColor = menuCircleTextColor ;
        
    }
    else
    {
        
        self.allButton.backgroundColor = menuBackGroudSelectedColor;
        self.openButton.backgroundColor = menuBackGroudColor;
        self.closedButton.backgroundColor = menuBackGroudColor;

        [self.allButton setTitleColor:menuNameSelectedTextColor forState:UIControlStateNormal];
        [self.closedButton setTitleColor:menuNameTextColor forState:UIControlStateNormal];
        [self.openButton setTitleColor:menuNameTextColor forState:UIControlStateNormal];
        
        self.allCountLabel.backgroundColor = menuCircleSelectedBgColor ;
        self.openCountLabel.backgroundColor = menuCircleBgColor ;
        self.closedCountLabel.backgroundColor = menuCircleBgColor ;

        self.allCountLabel.textColor = menuCircleSelectedTextColor ;
        self.openCountLabel.textColor = menuCircleTextColor ;
        self.closedCountLabel.textColor = menuCircleTextColor ;

        
    }
    
}

#pragma mark -- private

// menu shadow
- (void)setShadowView
{
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(0, self.frame.size.height - 0.5, CGRectGetWidth(self.frame), 0.5);
    view.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:view];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = kYSLScrollMenuViewMargin;
    for (NSUInteger i = 0; i < self.itemViewArray.count; i++) {
        CGFloat width = kYSLScrollMenuViewWidth;
        UIView *itemView = self.itemViewArray[i];
        itemView.frame = CGRectMake(x, 0, width, self.scrollView.frame.size.height);
        x += width + kYSLScrollMenuViewMargin;
    }
    self.scrollView.contentSize = CGSizeMake(x, self.scrollView.frame.size.height);
    
    CGRect frame = self.scrollView.frame;
    if (self.frame.size.width > x) {
        frame.origin.x = (self.frame.size.width - x) / 2;
        frame.size.width = x;
    } else {
        frame.origin.x = 0;
        frame.size.width = self.frame.size.width;
    }
    self.scrollView.frame = frame;
}

#pragma mark -- Selector --------------------------------------- //
- (void)itemViewTapAction:(UITapGestureRecognizer *)Recongnizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollMenuViewSelectedIndex:)]) {
        [self.delegate scrollMenuViewSelectedIndex:[(UIGestureRecognizer*) Recongnizer view].tag];
    }
}

@end
