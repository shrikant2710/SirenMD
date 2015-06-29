//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AksAnimations : NSObject
+ (AksAnimations *)sharedAksAnimations;
- (void)movingAnimationForViews:(NSArray *)views isLeftToRight:(bool)isLeftToRight;
- (void)animateWobbleEffect:(UIView *)view forDuration:(int)seconds;
- (void)breathAnimationSlow:(UIView *)view RepeatCount:(int)RepeatCount;
- (void)breathAnimation:(UIView *)view;
- (void)animationArrayOfWidgets:(NSArray *)Objects;
- (void)animationAsIfErrorfor:(UIView *)object;
- (void)showAnimationAsIfMoving:(UIView *)Object IsLeftToRight:(bool)IsLeftToRight;
- (void)aksDivertSubviewsAnimation:(UIView *)object With:(BOOL)AnimateOutWards;
- (void)bounceAnimation:(UIView *)view;
- (void)moveThis:(UIView *)view ToPoint:(CGPoint)point InDuration:(int)duration;
- (void)rotateThis:(UIView *)view ToAngle:(float)angle;
- (void)runSpinAnimationOnView:(UIView *)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
- (void)blink:(UIView *)view;
- (void)makeThisViewGlossy:(UIView *)view;
- (void)fadeInThisView:(NSArray *)views duration:(float)dur;
- (void)fadeOutThisView:(NSArray *)views duration:(float)dur;
- (void)performSlideFromBottomToTopForViews:(NSArray *)views;
- (void)pushViewControllerWithFlipAnimation:(UIViewController *)viewController fromViewController:(UIViewController *)currentViewController;
- (void)popViewControllerWithFlipAnimation:(UIViewController *)viewController;
- (void)popBySlidingToBottomForViewController:(UIViewController *)viewsController;
+ (void)animateViewWithKeyboard:(float)yPosition onView:(UIView *)view withDuration:(float)duration;
+ (void)fade:(BOOL)isFadeOut Serially:(NSArray*)views eachWithDuration:(float)duration;
+ (void)performPopInAnimation:(UIView*)view;
@end
