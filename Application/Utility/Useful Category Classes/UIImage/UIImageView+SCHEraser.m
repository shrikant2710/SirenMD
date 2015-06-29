//
//  UIImageView+SCHEraser.m
//  eraser
//
//  Created by 沈 晨豪 on 14-5-4.
//  Copyright (c) 2014年 sch. All rights reserved.
//

#import "UIImageView+SCHEraser.h"
#import <objc/runtime.h>


static char sch_eraser_point_frame_animation_start_key;
static char sch_eraser_point_frame_animation_end_key;

static int point_index;

@implementation UIImageView (SCHEraser)

@dynamic point_frame_animation_start;
@dynamic point_frame_animation_end;

- (void)setPoint_frame_animation_start:(Void_Block)point_frame_animation_start {
    [self willChangeValueForKey:@"point_frame_animation_start"];
    objc_setAssociatedObject(self, &sch_eraser_point_frame_animation_start_key, point_frame_animation_start, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"point_frame_animation_start"];
}

- (void)setPoint_frame_animation_end:(Void_Block)point_frame_animation_end {
    [self willChangeValueForKey:@"point_frame_animation_end"];
    objc_setAssociatedObject(self, &sch_eraser_point_frame_animation_end_key, point_frame_animation_end, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"point_frame_animation_end"];
}

- (Void_Block)point_frame_animation_start {
    return objc_getAssociatedObject(self, &sch_eraser_point_frame_animation_start_key);
}

- (Void_Block)point_frame_animation_end {
    return objc_getAssociatedObject(self, &sch_eraser_point_frame_animation_end_key);
}

- (void)clearByPointArray:(NSArray *)point_array
                   radius:(CGFloat)radius
                 duration:(CGFloat)duration
                  atIndex:(NSInteger)index {
    CGPoint point = [[point_array objectAtIndex:index] CGPointValue];
    
    UIGraphicsBeginImageContext(self.frame.size);
    [self.image drawInRect:self.bounds];
    
    CGContextClearRect(UIGraphicsGetCurrentContext(),
                       CGRectMake(point.x - radius,
                                  point.y - radius,
                                  2 * radius,
                                  2 * radius));
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    ++index;
    
    if (index == point_array.count) {
        if (self.point_frame_animation_end) {
            self.point_frame_animation_end();
        }
        
        return;
    }
    else {
        //usleep( 1000.0f);
        [self clearByPointArray:point_array
                         radius:radius
                       duration:duration
                        atIndex:index];
    }
}

- (void)clearByDic:(NSDictionary *)dic {
    CGFloat duration    = [[dic objectForKey:@"frame_time"] doubleValue];
    CGFloat radius      = [[dic objectForKey:@"radius"] doubleValue];
    NSArray *point_array = [dic objectForKey:@"point_array"];
    UIColor *color = [dic objectForKey:@"color"];
    CGPoint point = [[point_array objectAtIndex:point_index] CGPointValue];
    
#if 0
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:self.bounds];
    CGRect clippingEllipseRect = CGRectMake(point.x - radius, point.y - radius, 2 * radius, 2 * radius);
    CGContextAddEllipseInRect(ctx, clippingEllipseRect);
    CGContextClip(ctx);
    CGContextClearRect(ctx, clippingEllipseRect);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#else
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:self.bounds];
    CGRect ellipseRectToFill = CGRectMake(point.x - radius, point.y - radius, 2 * radius, 2 * radius);
    CGContextAddEllipseInRect(ctx, ellipseRectToFill);
    CGContextClip(ctx);
    CGContextClearRect(ctx, ellipseRectToFill);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, ellipseRectToFill);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif
    
    ++point_index;
    if (point_index == point_array.count) {
        if (self.point_frame_animation_end) {
            self.point_frame_animation_end();
        }
        return;
    }
    else {
        [self performSelector:@selector(clearByDic:) withObject:dic afterDelay:duration];
    }
}

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
                             animationEnd:(Void_Block)end_block {
    if (!color) {
        color = [UIColor clearColor];
    }
    
    self.point_frame_animation_start = start_block;
    self.point_frame_animation_end   = end_block;
    
    if (self.point_frame_animation_start) {
        self.point_frame_animation_start();
    }
    
    
    if (nil == point_array || 0 == point_array.count) {
        if (self.point_frame_animation_end) {
            self.point_frame_animation_end();
        }
    }
    else {
        NSDictionary *dic = @{ @"frame_time": [NSNumber numberWithFloat:frame_time],
                               @"radius": [NSNumber numberWithFloat:radius],
                               @"color": color,
                               @"point_array":point_array };
        
        
        point_index = 0;
        
        [self clearByDic:dic];
    }
}

@end
