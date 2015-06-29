//
//  UIImageView+SCHEraser.h
//  eraser
//
//  Created by 沈 晨豪 on 14-5-4.
//  Copyright (c) 2014年 sch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SCHEraser)

typedef void (^Void_Block)();

@property (nonatomic, copy) Void_Block point_frame_animation_start;
@property (nonatomic, copy) Void_Block point_frame_animation_end;

/**
 *  通过一组点进行消除的动画  每一个点为中心建立一个正方形  每一个正方形为一帧 设置每一帧的时间 进行擦除动画
 *
 *  @param point_array 中间点的array
 *  @param frame_time  每一帧的时间
 *  @param radius      半径
 *  @param start_block 动画开始的block
 *  @param end_block   动画结束的block
 */
- (void)startErasureAnimationByPointFrame:(NSArray *)point_array
                                frameTime:(CGFloat)frame_time
                                   radius:(CGFloat)radius
                                    color:(UIColor *)color
                           animationStart:(Void_Block)start_block
                             animationEnd:(Void_Block)end_block;

@end
