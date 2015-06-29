//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//


#import "AKSMethods.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+PE.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation AKSMethods

+ (CGPoint)centerForRect:(CGRect)rect {
    return CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
}

+ (void)printErrorMessage:(NSError *)error showit:(BOOL)show {
    if (error) {
        NSLog(@"[error localizedDescription]        : %@", [error localizedDescription]);
        NSLog(@"[error localizedFailureReason]      : %@", [error localizedFailureReason]);
        NSLog(@"[error localizedRecoverySuggestion] : %@", [error localizedRecoverySuggestion]);
        
        if (show) [AKSMethods showMessage:[error localizedDescription]];
    }
}

+ (void)printFreeMemory {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");;
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used / 100000, mem_free / 100000, mem_total / 100000);
}

+ (NSString *)getClassNameForObject:(id)object {
    return [NSString stringWithFormat:@"%s", class_getName([object class])];
}

+ (void)showMessage:(NSString *)msg {
    if (!(msg && msg.length > 0)) return;
    [self performSelectorOnMainThread:@selector(messageFromMainThread:) withObject:msg waitUntilDone:NO];
}

+ (void)showDebuggingMessage:(NSString *)msg {
    if (!(msg && msg.length > 0)) return;
    [self performSelectorOnMainThread:@selector(messageFromMainThread:) withObject:msg waitUntilDone:NO];
}

+ (void)messageFromMainThread:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Information"
                          message:msg
                          delegate:nil
                          cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

+ (void)removeAllKeysHavingNullValue:(NSMutableDictionary *)dictionary {
    @try {
        NSSet *nullSet = [dictionary keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest: ^BOOL (id key, id obj, BOOL *stop) {
            return [obj isEqual:[NSNull null]] ? YES : NO;
        }];
        [dictionary removeObjectsForKeys:[nullSet allObjects]];
    }
    @catch (NSException *exception)
    {
    }
    @finally
    {
    }
}

+ (NSMutableString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}

+ (NSString *)limitThis:(NSString *)string ForLengthUpto:(int)maxLength {
    if (string && string.length > maxLength) return [NSString stringWithFormat:@"%@...", [string substringToIndex:maxLength - 4]];
    return string;
}

+ (UIImage *)compressThisImage:(UIImage *)image {
    return (image.size.width > SCREEN_FRAME_RECT.size.width) ? ([AKSMethods imageWithImage:image scaledToWidth:SCREEN_FRAME_RECT.size.width]) : image;
}

+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float)i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)highlightAllLabelsOfThisView:(UIView *)view {
    NSArray *subviews = [view subviews];
    for (int i = 0; i < subviews.count; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UILabel class]]) [((UILabel *)[subviews objectAtIndex:i])setBackgroundColor:[UIColor lightGrayColor]];
    }
}

+ (void)showThisAlertViewByWorkAroundForParallelButtons:(UIAlertView *)alertView {
    [alertView addButtonWithTitle:@"Fake"];
    
    for (int i = 0; i < alertView.subviews.count; i++) {
        if ([[AKSMethods getClassNameForObject:[alertView.subviews objectAtIndex:i]] isEqualToString:@"UIAlertButton"]) {
            if ([((UIButton *)[alertView.subviews objectAtIndex:i]).titleLabel.text isEqualToString:@"Fake"]) {
                [((UIButton *)[alertView.subviews objectAtIndex:i])setHidden:TRUE];
            }
        }
    }
    
    [alertView show];
}

+ (void)syncroniseNSUserDefaults {
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (UIView *)getCapturedImageAsView {
    UIView *mainView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    UIImageView *imageView  = [[UIImageView alloc]initWithImage:[AKSMethods getScreenCapture]];
    [imageView setFrame:[[UIScreen mainScreen]bounds]];
    [mainView addSubview:imageView];
    
    UIView *blackTranslucentView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [blackTranslucentView setBackgroundColor:[UIColor blackColor]];
    [blackTranslucentView setOpaque:NO];
    [blackTranslucentView.layer setOpacity:0.5];
    [mainView addSubview:blackTranslucentView];
    
    return mainView;
}

+ (UIImage *)getScreenCapture {
    UIImage *image = nil;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions([keyWindow bounds].size, NO, 0.0);
    [keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (CGRect)frameOfImageInImageView:(UIImageView *)imageView {
    CGSize imageSize = imageView.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(imageView.bounds) / imageSize.width, CGRectGetHeight(imageView.bounds) / imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width * imageScale, imageSize.height * imageScale);
    CGRect imageFrame = CGRectMake(roundf(0.5f * (CGRectGetWidth(imageView.bounds) - scaledImageSize.width)), roundf(0.5f * (CGRectGetHeight(imageView.bounds) - scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    return imageFrame;
}

+ (UIImage *)imageWithView:(UIView *)view withRect:(CGRect)rect {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

+ (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification *)notification {
    NSTimeInterval duration = 0;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    return duration;
}

+ (float)keyboardHeightForNotification:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo]
                            objectForKey:UIKeyboardFrameBeginUserInfoKey]
                           CGRectValue].size;
    return keyboardSize.height;
}

+ (void)From:(NSMutableDictionary *)source WithKey:(NSString *)sourceKey To:(NSMutableDictionary *)destination U:(NSString *)key OnM:(NSString *)method {
    if ([self isNotNull:[source objectForKey:sourceKey]]) [destination setObject:[source objectForKey:sourceKey] forKey:key];
    else[AKSMethods reportMissingParameterWithName:sourceKey WhileRequestingWithMethodName:method];
}

+ (void)addP:(id)data To:(NSMutableDictionary *)destination U:(NSString *)key OnM:(NSString *)method {
    if ([self isNotNull:data]) [destination setObject:data forKey:key];
    else[AKSMethods reportMissingParameterWithName:key WhileRequestingWithMethodName:method];
}

+ (void)reportMissingParameterWithName:(NSString *)missingParameter WhileRequestingWithMethodName:(NSString *)method {
    NSString *report = [NSString stringWithFormat:@"\nMISSING PARAMETER :--- %@ ---IN METHOD : %@\n", missingParameter, method];
    NSLog(@"%@", report);
}

+ (BOOL)validateUrl:(NSString *)url {
    NSString *theURL =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theURL];
    return [urlTest evaluateWithObject:url];
}

+ (void)reloadWithAnimationTableView:(UITableView *)tableView {
    [tableView setContentOffset:tableView.contentOffset animated:NO];
    [UIView transitionWithView:tableView duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations: ^(void) { [tableView reloadData]; } completion:NULL];
}

+ (void)scrollTableViewToLast:(UITableView *)tableView animated:(BOOL)animated withDelay:(float)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        NSInteger lasSection = [tableView numberOfSections] - 1;
        NSInteger lastRow = [tableView numberOfRowsInSection:lasSection] - 1;
        while (lastRow < 0 && lasSection > 0) {
            --lasSection;
            lastRow = [tableView numberOfRowsInSection:lasSection] - 1;
        }
        if (lasSection < 0 || lastRow < 0)
            return;
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:lasSection];
        [tableView selectRowAtIndexPath:lastRowIndexPath animated:animated scrollPosition:UITableViewScrollPositionBottom];
    });
}

+ (void)scrollTableViewToFirst:(UITableView *)tableView animated:(BOOL)animated withDelay:(float)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        [tableView setContentOffset:CGPointMake(0, 0) animated:animated];
    });
}
+ (BOOL)isApplicationUpdated {
#define APPLICATION_BUILD_VERSION_IDENTIFIER_KEY @"APPLICATION_BUILD_VERSION"
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *savedBuildVersion = [standardUserDefaults objectForKey:APPLICATION_BUILD_VERSION_IDENTIFIER_KEY];
    NSString *currentBuildVersion = CURRENT_DEVICE_VERSION_STRING;
    if (savedBuildVersion) {
        if ([savedBuildVersion isEqualToString:currentBuildVersion]) {
            return NO;
        }
        else {
            [standardUserDefaults setObject:currentBuildVersion forKey:APPLICATION_BUILD_VERSION_IDENTIFIER_KEY];
        }
    }
    else {
        [standardUserDefaults setObject:CURRENT_DEVICE_VERSION_STRING forKey:APPLICATION_BUILD_VERSION_IDENTIFIER_KEY];
    }
    return YES;
}


+ (NSString *)replaceString:(NSString *)mainString startingFrom:(NSString *)startingFrom toString:(NSString *)toString WithString:(NSString *)stringToReplace {
    NSRange rangeS = [mainString rangeOfString:startingFrom];
    NSRange rangeE = [mainString rangeOfString:toString];
    NSRange actualRangeToReplace;
    actualRangeToReplace.location = rangeS.location;
    actualRangeToReplace.length = rangeE.location - rangeS.location;
    return [mainString stringByReplacingCharactersInRange:actualRangeToReplace withString:stringToReplace];
}

+ (void)setEnabled:(BOOL)isEnabled contentsUserInteractionForView:(UIView *)view {
#define TAG_FOR_VIEW_ADDED_FOR_PREVENTING_USER_INTERACTION 121110
    [[view viewWithTag:TAG_FOR_VIEW_ADDED_FOR_PREVENTING_USER_INTERACTION]removeFromSuperview];
    if (isEnabled == NO) {
        CGRect mainScreenRect = [[UIScreen mainScreen]bounds];
        UIView *temporaryView = [[UIView alloc]init];
        [temporaryView setTag:TAG_FOR_VIEW_ADDED_FOR_PREVENTING_USER_INTERACTION];
        [temporaryView setFrame:CGRectMake(mainScreenRect.origin.y, NAVIGATION_BAR_HEIGHT, mainScreenRect.size.width, mainScreenRect.size.height - NAVIGATION_BAR_HEIGHT)];
        [view addSubview:temporaryView];
        [view bringSubviewToFront:temporaryView];
    }
}

+ (void)addSingleTapGestureRecogniserTo:(UIView *)view forSelector:(SEL)action ofObject:(id)object {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:object action:action];
    singleTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleTap];
    [view setUserInteractionEnabled:TRUE];
}

+ (void)addLongPressGestureRecogniserTo:(UIView *)view forSelector:(SEL)action ofObject:(id)object {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:object action:action];
    [longPress setMinimumPressDuration:1];
    [view addGestureRecognizer:longPress];
    [view setUserInteractionEnabled:TRUE];
}

+ (UIViewController *)popToViewControllerOfKind:(Class)aClass from:(UINavigationController *)navController {
    NSArray *arrayOfViewControllersInStack = navController.viewControllers;
    for (int i = 0; i < arrayOfViewControllersInStack.count; i++) {
        if ([[arrayOfViewControllersInStack objectAtIndex:i] isKindOfClass:aClass]) {
            int index = (i > 0) ? (i - 1) : i;
            [navController popToViewController:[arrayOfViewControllersInStack objectAtIndex:index] animated:FALSE];
            break;
        }
    }
    return [navController topViewController];
}

+ (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    return token;
}

+ (UIImage *)getFirstFrameOfVideoWithPath:(NSString *)filePath {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = TRUE;
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbnail;
}

+ (CGSize)getResolutionOfVideoWithPath:(NSString *)filePath {
    AVAssetTrack *videoTrack = nil;
    AVURLAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if ([videoTracks count] > 0)
        videoTrack = [videoTracks objectAtIndex:0];
    
    CMFormatDescriptionRef formatDescription = NULL;
    NSArray *formatDescriptions = [videoTrack formatDescriptions];
    if ([formatDescriptions count] > 0)
        formatDescription = (__bridge CMFormatDescriptionRef)[formatDescriptions objectAtIndex:0];
    
    CGSize trackDimensions = {
        .width = 0.0,
        .height = 0.0,
    };
    trackDimensions = [videoTrack naturalSize];
    
    int width = trackDimensions.width;
    int height = trackDimensions.height;
    UIImage *image = [AKSMethods getFirstFrameOfVideoWithPath:filePath];
    if (image.size.width > image.size.height) {
        return CGSizeMake(MAX(width, height), MIN(width, height));
    }
    else {
        return CGSizeMake(MIN(width, height), MAX(width, height));
    }
}

+ (NSString *)stringByReplacingMultipleSpacesWithSingleSpaceOnString:(NSString *)string {
    if (string.length > 0) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
        string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@" "];
    }
    return string;
}

+ (NSString *)generateUserNameForName:(NSString *)string {
    string = [string lowercaseString];
    string = [AKSMethods stringByReplacingMultipleSpacesWithSingleSpaceOnString:string];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@"."];
    return string;
}

+ (void)saveImageToPhotos:(UIImage *)image {
    if ([self isNull:image]) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
    });
}

+ (void)saveVideoToPhotos:(NSURL *)path {
    if ([self isNull:path]) return;
    if ([[NSFileManager defaultManager]fileExistsAtPath:path.path] == NO) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:path completionBlock:nil];
    });
}

+ (NSString *)stringByRemovingSpacesFromStartAndEndWithCleaningOutConsecutiveMultipleSpaces:(NSString *)string {
    if (string.length > 0) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
        string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@" "];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if (string.length > 0) {
        return [NSString stringWithFormat:@"%@ ", string];
    }
    else {
        return nil;
    }
}

+ (NSMutableArray *)componentsSeperatedOnString:(NSString *)string startingWith:(NSString *)start andEndingWith:(NSString *)end {
    if (string.length > 0) {
        NSString *aString = string;
        NSMutableArray *substrings = [NSMutableArray new];
        NSScanner *scanner = [NSScanner scannerWithString:aString];
        [scanner scanUpToString:start intoString:nil];
        while (![scanner isAtEnd]) {
            NSString *substring = nil;
            [scanner scanString:start intoString:nil];
            if ([scanner scanUpToString:end intoString:&substring]) {
                [substrings addObject:substring];
            }
            [scanner scanUpToString:start intoString:nil];
        }
        return [[NSMutableArray alloc]initWithArray:substrings];
    }
    return [[NSMutableArray alloc]init];
}

+ (NSMutableArray *)rangesOnString:(NSString *)string OfSubStringStartingWith:(NSString *)start andEndingWith:(NSString *)end {
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:0];
    NSRange startRange = [string rangeOfString:start];
    for (;; ) {
        if (startRange.location != NSNotFound) {
            NSRange targetRange;
            targetRange.location = startRange.location + startRange.length;
            targetRange.length = [string length] - targetRange.location;
            NSRange endRange = [string rangeOfString:end options:0 range:targetRange];
            if (endRange.location != NSNotFound) {
                targetRange.length = endRange.location - targetRange.location + 1;
                [strings addObject:[string substringWithRange:targetRange]];
                NSRange restOfString;
                restOfString.location = endRange.location + endRange.length;
                restOfString.length = [string length] - restOfString.location;
                startRange = [string rangeOfString:start options:0 range:restOfString];
            }
            else {
                break;
            }
        }
        else {
            break;
        }
    }
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    for (NSString *str in strings) {
        [tmp addObject:NSStringFromRange([string rangeOfString:str])];
    }
    return tmp;
}

+ (void)printAvailableFonts {
    for (NSString *family in[UIFont familyNames]) {
        for (NSString *name in[UIFont fontNamesForFamilyName: family]) {
            NSLog(@"  %@", name);
        }
    }
}

+ (NSArray *)getAvailableFonts {
    NSMutableArray *allFonts = [[NSMutableArray alloc]init];
    [allFonts addObject:@"Default"];
    for (NSString *family in[UIFont familyNames]) {
        for (NSString *name in[UIFont fontNamesForFamilyName: family]) {
            [allFonts addObject:name];
        }
    }
    return allFonts;
}

#define BLACK_VIEW_TAG_VALUE 1024

+ (void)addViewToMakeStatusBarBackgroundWithColor:(UIColor *)color {
    [self removeViewToMakeStatusBarBackground];
    UIView *statusBarBackgroundBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10240, 20)];
    [statusBarBackgroundBlackView setBackgroundColor:color];
    [statusBarBackgroundBlackView setTag:BLACK_VIEW_TAG_VALUE];
    [[[[APPDELEGATE window]rootViewController]view] addSubview:statusBarBackgroundBlackView];
}

+ (void)removeViewToMakeStatusBarBackground {
    [[[[[APPDELEGATE window]rootViewController]view] viewWithTag:BLACK_VIEW_TAG_VALUE]removeFromSuperview];
}

#define BG_VIEW_TAG_VALUE 1025

+ (void)createBackgroundOfViewWithImage:(UIImage *)image onView:(UIView *)view {
    [[view viewWithTag:BG_VIEW_TAG_VALUE]removeFromSuperview];
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.height, view.frame.size.width)];
    [backgroundImageView setImage:image];
    [backgroundImageView setTag:BG_VIEW_TAG_VALUE];
    [view addSubview:backgroundImageView];
    [view sendSubviewToBack:backgroundImageView];
}

+ (NSString *)getFilePathToSaveUnUpdatedVideo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    static int counter = 0;
    counter++;
    for (int i = counter; TRUE; i++, counter++) {
        if (![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Video%d.mp4", directory, i]]) return [NSString stringWithFormat:@"%@/Video%d.mp4", directory, i];
    }
}

+ (NSString *)getFilePathToSaveUnUpdatedImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    static int counter = 0;
    counter++;
    for (int i = counter; TRUE; i++, counter++) {
        if (![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Image%d.png", directory, i]]) return [NSString stringWithFormat:@"%@/Image%d.png", directory, i];
    }
}

+ (void)setSubviewsHidden:(BOOL)hidden onView:(UIView *)view {
    for (UIView *v in view.subviews) {
        [v setHidden:hidden];
    }
}

+ (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    }
    else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *)getJsonStringFromObject:(id)object {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if ([self isNull:data]) {
        return @"";
    }
    else {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

@end
