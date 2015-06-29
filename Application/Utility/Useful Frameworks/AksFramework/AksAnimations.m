//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//


#import "AksAnimations.h"
#import <QuartzCore/QuartzCore.h>

static AksAnimations *AksAnimations_ = nil;

@implementation AksAnimations


+ (AksAnimations *)sharedAksAnimations {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (AksAnimations_ == nil) {
            AksAnimations_ = [[AksAnimations alloc]init];
        }
    });
    return AksAnimations_;
}

+ (id)alloc {
    NSAssert(AksAnimations_ == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

+ (void)animateViewWithKeyboard:(float)yPosition onView:(UIView *)view withDuration:(float)duration {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [view setFrame:CGRectMake(0, yPosition, view.frame.size.width, view.frame.size.height)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)animateWobbleEffect:(UIView *)view forDuration:(int)seconds;
{
#define WOBBLE_ANIMATION_FREQUENCY 0.15
#define WOBBLE_ANIMATION_DEVIATION 1.2
    
    CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, ((-WOBBLE_ANIMATION_DEVIATION * M_PI) / 180.0));
    CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, ((WOBBLE_ANIMATION_DEVIATION * M_PI) / 180.0));
    
    view.transform = leftWobble;  // starting point
    
    [UIView beginAnimations:@"wobble" context:(__bridge void *)(view)];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:seconds / WOBBLE_ANIMATION_FREQUENCY]; // adjustable
    [UIView setAnimationDuration:WOBBLE_ANIMATION_FREQUENCY];
    [UIView setAnimationDelegate:self];
    
    view.transform = rightWobble; // end here & auto-reverse
    [UIView commitAnimations];
}

- (void)breathAnimation:(UIView *)view {
    NSString *kBreath = @"breath";
    NSString *kOpacity = @"opacity";
    
    [CATransaction begin];
    CAKeyframeAnimation *BreathAnimation = [CAKeyframeAnimation animationWithKeyPath:kOpacity];
    NSArray *OpacityValues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f],
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.1f], [NSNumber numberWithFloat:0.2f], [NSNumber numberWithFloat:0.30f], [NSNumber numberWithFloat:0.4f], [NSNumber numberWithFloat:0.5f], [NSNumber numberWithFloat:0.6f], [NSNumber numberWithFloat:0.7f], [NSNumber numberWithFloat:0.8f], [NSNumber numberWithFloat:0.9f], [NSNumber numberWithFloat:1.0f], nil];
    NSArray *OpacityTimes = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:0.1f], [NSNumber numberWithFloat:0.2f], [NSNumber numberWithFloat:0.30f], [NSNumber numberWithFloat:0.4f], [NSNumber numberWithFloat:0.5f], [NSNumber numberWithFloat:0.6f], [NSNumber numberWithFloat:0.7f], [NSNumber numberWithFloat:0.8f], [NSNumber numberWithFloat:0.9f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.1f], nil];
    [BreathAnimation setValues:OpacityValues];
    [BreathAnimation setKeyTimes:OpacityTimes];
    [BreathAnimation setDuration:1.1f];
    [BreathAnimation setRepeatCount:0];
    [BreathAnimation setFillMode:kCAFillModeRemoved];
    [BreathAnimation setCalculationMode:kCAAnimationLinear];
    [BreathAnimation setRemovedOnCompletion:YES];
    [BreathAnimation setDelegate:self];
    [view.layer addAnimation:BreathAnimation forKey:kBreath];
    [CATransaction commit];
}

- (void)breathAnimationSlow:(UIView *)view RepeatCount:(int)RepeatCount {
    NSString *kBreath = @"breath";
    NSString *kOpacity = @"opacity";
    
    [CATransaction begin];
    CAKeyframeAnimation *BreathAnimation = [CAKeyframeAnimation animationWithKeyPath:kOpacity];
    NSArray *OpacityValues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f],
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.1f], [NSNumber numberWithFloat:0.2f], [NSNumber numberWithFloat:0.30f], [NSNumber numberWithFloat:0.4f], [NSNumber numberWithFloat:0.5f], [NSNumber numberWithFloat:0.6f], [NSNumber numberWithFloat:0.7f], [NSNumber numberWithFloat:0.8f], [NSNumber numberWithFloat:0.9f], [NSNumber numberWithFloat:1.0f], nil];
    NSArray *OpacityTimes = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0f],
                             [NSNumber numberWithFloat:0.1f], [NSNumber numberWithFloat:0.2f], [NSNumber numberWithFloat:0.30f], [NSNumber numberWithFloat:0.4f], [NSNumber numberWithFloat:0.5f], [NSNumber numberWithFloat:0.6f], [NSNumber numberWithFloat:0.7f], [NSNumber numberWithFloat:0.8f], [NSNumber numberWithFloat:0.9f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.1f], nil];
    [BreathAnimation setValues:OpacityValues];
    [BreathAnimation setKeyTimes:OpacityTimes];
    [BreathAnimation setDuration:4.0f];
    [BreathAnimation setRepeatCount:RepeatCount];
    [BreathAnimation setFillMode:kCAFillModeRemoved];
    [BreathAnimation setCalculationMode:kCAAnimationLinear];
    [BreathAnimation setRemovedOnCompletion:YES];
    [BreathAnimation setDelegate:self];
    [view.layer addAnimation:BreathAnimation forKey:kBreath];
    [CATransaction commit];
}

- (void)showAnimationAsIfMoving:(UIView *)Object IsLeftToRight:(bool)IsLeftToRight {
    float FullDistance = 320.0f;
    
    if (IsLeftToRight == NO) {
        FullDistance = -FullDistance;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.35];
    [animation setRepeatCount:0];
    [animation setAutoreverses:NO];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([Object center].x - FullDistance, [Object center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([Object center].x, [Object center].y)]];
    [[Object layer] addAnimation:animation forKey:@"position"];
}

- (void)animationArrayOfWidgets:(NSArray *)Objects {
    float FullDistance = 320.0f;
    float SmallDistance = 20.0f;
    int counter = 0;
    for (float i = 0.6; counter < Objects.count; i += 0.1, counter++) {
        SmallDistance = -SmallDistance;
        FullDistance = -FullDistance;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:i];
        [animation setRepeatCount:0];
        [animation setAutoreverses:NO];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([((UIView *)[Objects objectAtIndex:counter])center].x - FullDistance, [((UIView *)[Objects objectAtIndex:counter])center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([((UIView *)[Objects objectAtIndex:counter])center].x + SmallDistance, [((UIView *)[Objects objectAtIndex:counter])center].y)]];
        [[[Objects objectAtIndex:counter] layer] addAnimation:animation forKey:@"position"];
    }
}

- (void)animationAsIfErrorfor:(UIView *)object {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.07];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([object center].x - 8.0f, [object center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([object center].x + 8.0f, [object center].y)]];
    [[object layer] addAnimation:animation forKey:@"position"];
}

- (void)aksDivertSubviewsAnimation:(UIView *)object With:(BOOL)AnimateOutWards {
    for (int i = 0; i < object.subviews.count; i++) {
        CGRect Original = ((UIView *)[[object subviews] objectAtIndex:i]).frame;
        CGRect Modified = Original;
        
        if (i % 2) {
            Modified.origin.x += arc4random() % (int)960 + arc4random() % (int)480;
            Modified.origin.y -= arc4random() % (int)960 + arc4random() % (int)480;
        }
        else {
            Modified.origin.x += -arc4random() % (int)960 - arc4random() % (int)480;
            Modified.origin.y += -arc4random() % (int)960 - arc4random() % (int)480;
        }
        
        if (AnimateOutWards) [((UIView *)[[object subviews] objectAtIndex:i])setFrame:Original];
        else[((UIView *)[[object subviews] objectAtIndex:i])setFrame:Modified];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            if (AnimateOutWards) [((UIView *)[[object subviews] objectAtIndex:i])setFrame:Modified];
            else[((UIView *)[[object subviews] objectAtIndex:i])setFrame:Original];
            [UIView commitAnimations];
        });
    }
}

- (void)bounceAnimation:(UIView *)view {
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    [UIView commitAnimations];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.12];
        [UIView setAnimationDelegate:self];
        SEL selector = NSSelectorFromString(@"bounce2AnimationStopped:");
        [UIView setAnimationDidStopSelector:selector];
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        [UIView commitAnimations];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.32 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.12];
        view.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];
    });
}

- (void)moveThis:(UIView *)view ToPoint:(CGPoint)point InDuration:(int)duration {
    [UIView beginAnimations:@"MoveView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:duration];
    [view setCenter:point];
    [UIView commitAnimations];
}

- (void)rotateThis:(UIView *)view ToAngle:(float)angle {
    CATransform3D rotationTransform = CATransform3DIdentity;
    [view.layer removeAllAnimations];
    rotationTransform = CATransform3DRotate(rotationTransform, angle, 0.0, 0.0, 1);
    view.layer.transform = rotationTransform;
}

- (void)runSpinAnimationOnView:(UIView *)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0  * rotations * duration];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)blink:(UIView *)view {
    [view setAlpha:0.0];
    [UIView beginAnimations:@"Blink" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:10240];
    [UIView setAnimationDelegate:self];
    [view setAlpha:1.0f];
    [UIView commitAnimations];
}

- (void)makeThisViewGlossy:(UIView *)view {
    CALayer *thisLayer = view.layer;
    
    // Add a border
    thisLayer.cornerRadius = 8.0f;
    thisLayer.masksToBounds = NO;
    thisLayer.borderWidth = 0.0f;
    thisLayer.borderColor = view.backgroundColor.CGColor;
    
    // Give it a shadow
    if ([thisLayer respondsToSelector:@selector(shadowOpacity)]) {   // For compatibility, check if shadow is supported
        thisLayer.shadowOpacity = 0.7;
        thisLayer.shadowColor = [[UIColor blackColor] CGColor];
        thisLayer.shadowOffset = CGSizeMake(0.0, 3.0);
        
        // TODO: Need to test these on iPad
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
            thisLayer.rasterizationScale = 2.0;
        }
        thisLayer.shouldRasterize = YES;         // FYI: Shadows have a poor effect on performance
    }
    
    // Add backgorund color layer and make original background clear
    CALayer *backgroundLayer = [CALayer layer];
    backgroundLayer.cornerRadius = 8.0f;
    backgroundLayer.masksToBounds = YES;
    backgroundLayer.frame = thisLayer.bounds;
    backgroundLayer.backgroundColor = view.backgroundColor.CGColor;
    [thisLayer insertSublayer:backgroundLayer atIndex:0];
    
    thisLayer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
    
    // Add gloss to the background layer
    CAGradientLayer *glossLayer = [CAGradientLayer layer];
    glossLayer.frame = thisLayer.bounds;
    glossLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         nil];
    glossLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [backgroundLayer addSublayer:glossLayer];
}

- (void)fadeInThisView:(NSArray *)views duration:(float)dur {
    for (int i = 0; i  < views.count; i++) {
        UIView *view = [views objectAtIndex:i];
        view.alpha = 0;
        view.hidden = NO;
        [UIView animateWithDuration:dur animations: ^{
            view.alpha = 1;
        }];
    }
}

- (void)fadeOutThisView:(NSArray *)views duration:(float)dur {
    for (int i = 0; i  < views.count; i++) {
        UIView *view = [views objectAtIndex:i];
        
        [UIView animateWithDuration:dur animations: ^
         {
             view.alpha = 0;
         }
         
                         completion: ^(BOOL finished)
         {
             view.hidden = YES;
         }];
    }
}

- (void)movingAnimationForViews:(NSArray *)views isLeftToRight:(bool)isLeftToRight {
    int variable = -[UIScreen mainScreen].bounds.size.width;
    
    if (isLeftToRight) variable *= -1;
    
    for (int i = 0; i < views.count; i++) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.2];
        [animation setRepeatCount:0];
        [animation setAutoreverses:NO];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([((UIView *)[views objectAtIndex:i])center].x - variable, [((UIView *)[views objectAtIndex:i])center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([((UIView *)[views objectAtIndex:i])center].x, [((UIView *)[views objectAtIndex:i])center].y)]];
        [[[views objectAtIndex:i] layer] addAnimation:animation forKey:@"position"];
    }
}

- (void)performSlideFromBottomToTopForViews:(NSArray *)views {
    int variable = -[UIScreen mainScreen].bounds.size.height;
    
    for (int i = 0; i < views.count; i++) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.2];
        [animation setRepeatCount:0];
        [animation setAutoreverses:NO];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([((UIView *)[views objectAtIndex:i])center].x, [((UIView *)[views objectAtIndex:i])center].y - variable)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([((UIView *)[views objectAtIndex:i])center].x, [((UIView *)[views objectAtIndex:i])center].y)]];
        
        [[[views objectAtIndex:i] layer] addAnimation:animation forKey:@"position"];
    }
}

- (void)pushViewControllerWithFlipAnimation:(UIViewController *)viewController fromViewController:(UIViewController *)currentViewController {
    [UIView transitionWithView:currentViewController.navigationController.view duration:0.6  options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations: ^(void)
     {
         BOOL oldState = [UIView areAnimationsEnabled];
         [UIView setAnimationsEnabled:NO];
         [currentViewController.navigationController pushViewController:viewController animated:YES];
         [UIView setAnimationsEnabled:oldState];
     }               completion:nil];
}

- (void)popViewControllerWithFlipAnimation:(UIViewController *)viewController {
    [UIView transitionWithView:viewController.navigationController.view duration:0.6  options:UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^(void)
     {
         BOOL oldState = [UIView areAnimationsEnabled];
         [UIView setAnimationsEnabled:NO];
         [viewController.navigationController popViewControllerAnimated:YES];
         [UIView setAnimationsEnabled:oldState];
     }               completion:nil];
}

- (void)popBySlidingToBottomForViewController:(UIViewController *)viewsController {
    [UIView animateWithDuration:0.2 animations: ^
     {
         [viewsController.view setCenter:CGPointMake([viewsController.view center].x, [viewsController.view center].y + [UIScreen mainScreen].bounds.size.height)];
     }                completion: ^(BOOL finished)
     {
         [viewsController.navigationController popViewControllerAnimated:NO];
     }];
}

+ (void)fade:(BOOL)isFadeOut Serially:(NSArray *)views eachWithDuration:(float)duration {
    if ([views count] > 0) {
        NSMutableArray *arrayOfItems = [[NSMutableArray alloc]initWithArray:views];
        UIView *view = [arrayOfItems objectAtIndex:0];
        [arrayOfItems removeObjectAtIndex:0];
        [[view layer]setOpacity:isFadeOut ? 1 : 0];
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
        [UIView animateWithDuration:duration delay:0 options:options animations: ^{
            [[view layer]setOpacity:isFadeOut ? 0 : 1];
        } completion: ^(BOOL finished) {
            [AksAnimations fade:isFadeOut Serially:arrayOfItems eachWithDuration:duration];
        }];
    }
}

+ (void)performPopInAnimation:(UIView *)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .2;
    [view.layer addAnimation:animation forKey:@"popup"];
}

@end
