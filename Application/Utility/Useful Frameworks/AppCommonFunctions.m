//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//
#import "AppCommonFunctions.h"
#import "AppDelegate.h"
#import "CasesVC.h"
#import "RDVTabBarItem.h"
#import "RecentUpdateVC.h"
#import "AtheleteVC.h"
#import "LoginVc.h"
#import "CaseBaseVc.h"


const char urlKey;
const char viewControllerKey;

@implementation AppCommonFunctions

UIImage *navigationBarBackgroundImage1 = nil;

@synthesize appDelegate;
@synthesize finished;
@synthesize information;
@synthesize myLocation;
@synthesize placemark;
@synthesize tabBar;
@synthesize activeUsers;
@synthesize inActiveUsers;
@synthesize newlyRegisteredUsers;
@synthesize arrayOfTextEditingResponders;
@synthesize currentIndex;

static AppCommonFunctions *singletonInstance = nil;
UIImageView * imgV;

+ (AppCommonFunctions *)sharedInstance {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (singletonInstance == nil) {
            singletonInstance = [[AppCommonFunctions alloc]init];
            singletonInstance.appDelegate = APPDELEGATE;
        }
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,screenWidth, 70)];
        imgV.backgroundColor = [UIColor blackColor];
        imgV.alpha=.8;

    });
    return singletonInstance;
}

#pragma mark - startup configurations required for this class

- (void)prepareStartup {
    [self enableIQKeyboardManager];
   
}
- (void)enableIQKeyboardManager {
    //Enabling keyboard manager
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:20];
    //Enabling autoToolbar behaviour. If It is set to NO. You have to manually create IQToolbar for keyboard.
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    
    //Setting toolbar behavious to IQAutoToolbarBySubviews. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarBySubviews];
    
    //Resign textField if touched outside of UITextField/UITextView.
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    //Giving permission to modify TextView's frame
    [[IQKeyboardManager sharedManager] setCanAdjustTextView:NO];
    
    //Show TextField placeholder texts on autoToolbar
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:YES];
    
    [[IQKeyboardManager sharedManager] setShouldPlayInputClicks:YES];
}

- (void)disableIQKeyboardManager {
    //Enabling keyboard manager
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:20];
    //Enabling autoToolbar behaviour. If It is set to NO. You have to manually create IQToolbar for keyboard.
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    //Setting toolbar behavious to IQAutoToolbarBySubviews. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarBySubviews];
    
    //Resign textField if touched outside of UITextField/UITextView.
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    //Giving permission to modify TextView's frame
    [[IQKeyboardManager sharedManager] setCanAdjustTextView:NO];
    
    //Show TextField placeholder texts on autoToolbar
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:NO];
    
    [[IQKeyboardManager sharedManager] setShouldPlayInputClicks:NO];
}

- (id)getVCObjectOfClass:(Class)classType {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[classType description]];
}

#pragma mark - register this class for required notifications




#pragma mark - push notification handler methods

#define ALERT                          @"alert"
#define APS                            @"aps"
#define SENDER_ID                      @"senderId"


- (void)presentVCOfClass:(Class)class1 fromVC:(UIViewController *)nc animated:(BOOL)animated modifyVC:(operationACFFinishedBlock)modify {
    RESIGN_KEYBOARD
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[class1 description]];
    if (modify) {
        modify(vc);
        modify = nil;
    }
    [nc presentViewController:[[UINavigationController alloc]initWithRootViewController:vc] animated:animated completion:nil];
}

- (void)pushVCOfClass:(Class)class1 fromNC:(UINavigationController *)nc animated:(BOOL)animated popFirstToVCOfClass:(Class)class2 modifyVC:(operationACFFinishedBlock)modify {
    RESIGN_KEYBOARD
    [self popToViewControllerOfKind: class2 from: nc];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[class1 description]];
    if (modify) {
        modify(vc);
        modify = nil;
    }
    [self pushAnimated:vc fromNc:nc animated:animated];
}

- (void)logout {
    
    [TSMessage showNotificationWithTitle:@"You are being securely logged out. Thank you for using SirenMD." type:TSMessageNotificationTypeSuccess];
    [self pushVCOfClass:[LoginVc class] fromNC:appDelegate.navigationController animated:YES setRootViewController:YES modifyVC:nil];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"access_token"];
    [userDefaults synchronize];
    
}

- (void)pushVCOfClass:(Class)class1 fromNC:(UINavigationController *)nc animated:(BOOL)animated setRootViewController:(BOOL)isRootViewController modifyVC:(operationACFFinishedBlock)modify {
    RESIGN_KEYBOARD
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[class1 description]];
    if (modify) {
        modify(vc);
        modify = nil;
    }
    if (isRootViewController) {
        [nc setViewControllers:[NSMutableArray arrayWithObject:vc] animated:animated];
    }
    else {
        [self pushAnimated:vc fromNc:nc animated:animated];
    }
}

- (void)pushAnimated:(UIViewController *)vc fromNc:(UINavigationController *)nc animated:(BOOL)animated {
    [nc pushViewController:vc animated:animated];
}

- (UIViewController *)popToViewControllerOfKind:(Class)aClass from:(UINavigationController *)navController {
    RESIGN_KEYBOARD
    if (aClass) {
        NSArray *arrayOfViewControllersInStack = navController.viewControllers;
        for (int i = 0; i < arrayOfViewControllersInStack.count; i++) {
            if ([[arrayOfViewControllersInStack objectAtIndex:i] isKindOfClass:aClass]) {
                int index = (i > 0) ? (i - 1) : i;
                [navController popToViewController:[arrayOfViewControllersInStack objectAtIndex:index] animated:YES];
                break;
            }
        }
        return [navController topViewController];
    }
    return nil;
}

- (void)setCommonSetupForTableView:(UITableView *)tableView {
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBackgroundColor:[UIColor clearColor]];
}








- (void)setAttributedPlaceHolder:(NSString *)ph OnTextFeild:(UITextField *)tf withFont:(UIFont *)f withTextColor:(UIColor *)c {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:ph];
    [attributedText addAttribute:NSForegroundColorAttributeName value:c range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:NSFontAttributeName value:f range:NSMakeRange(0, attributedText.length)];
    [tf setAttributedPlaceholder:attributedText];
}

#pragma -
#pragma - tab bar controller

- (void)prepareViewWhenUserIsLoggedInFrom:(UINavigationController *)navigationController {
    /**
     uinavigationcontroller
     |
     viewdeckcontroller
     |
     left controller             center controller               right controller
     |                               |                               |
     chat/email settings(dynamically)  tabbarcontroller                      nil
     |
     email       chat
     */
    
    [navigationController setNavigationBarHidden:YES];
    [[navigationController view]setBackgroundColor:[UIColor whiteColor]];
    
    self.tabBar = [[RDVTabBarController alloc] init];
    //[tabBarController.tabBar setHeight:49];
    [self.tabBar setDelegate:self];
    RecentUpdateVC *viewControllerTab1 = [self getVCObjectOfClass:[RecentUpdateVC class]];
    CaseBaseVc *viewControllerTab2 = [self getVCObjectOfClass:[CaseBaseVc class]];
    AtheleteVC *viewControllerTab3 = [self getVCObjectOfClass:[AtheleteVC class]];
    [self.tabBar.tabBar setBackgroundColor:[UIColor blackColor]];
    [viewControllerTab1.tabBarItem setImage:nil];
    [viewControllerTab2.tabBarItem setImage:nil];
    [viewControllerTab3.tabBarItem setImage:nil];
    UINavigationController *navigationController1 =
    [[UINavigationController alloc] init];
    UINavigationController *navigationController2 =
    [[UINavigationController alloc] init];
    UINavigationController *navigationController3 =
    [[UINavigationController alloc] init];
    [navigationController1 setViewControllers:[NSArray arrayWithObject:viewControllerTab1] animated:NO];
    [navigationController2 setViewControllers:[NSArray arrayWithObject:viewControllerTab2] animated:NO];
    [navigationController3 setViewControllers:[NSArray arrayWithObject:viewControllerTab3] animated:NO];
    [self.tabBar setViewControllers:[NSArray arrayWithObjects:navigationController1, navigationController2, navigationController3, nil]];
    NSArray *tabBarItemImages = @[@"Imported", @"Cases", @"Athlete"];
    NSInteger index = 0;
    for (RDVTabBarItem *item in[[self.tabBar tabBar] items]) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
    [self setTabBar:self.tabBar];
    [navigationController setViewControllers:[NSArray arrayWithObject:self.tabBar] animated:NO];
    SHOW_STATUS_BAR
}



- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return TRUE;
}

- (void)setBackgroundOnViewController:(UIViewController *)vc withImage:(UIImage *)image {
#define TAG 9989
    [[vc.view viewWithTag:TAG]removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    [imageView setFrame:vc.view.bounds];
    [vc.view addSubview:imageView];
    [vc.view sendSubviewToBack:imageView];
    [imageView setTag:TAG];
}

- (void)setBackgroundOnView:(UIView *)v withImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    [imageView setFrame:imageView.bounds];
    [v addSubview:imageView];
    [v sendSubviewToBack:imageView];
}

-(void)presentControllerwithShadow:(UIViewController *)showVc overController:(UIViewController *)overController
{
    showVc.modalPresentationStyle = UIModalPresentationCustom;
    [overController.navigationController.view addSubview:imgV];
    
}

-(void)dismissViewControllerWithShadow:(UIViewController *)obj
{
    
    [imgV removeFromSuperview];
    [obj dismissViewControllerAnimated:YES completion:nil];
}
+ (void)saveUserDefaultWithObject:(id)object andKey:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:object forKey:key];
    [userDefaults synchronize];
    
}

+(void)removeObject:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
    
}
+(id)getDataFromNSUserDefault:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    id data = [userDefaults objectForKey:key];
    
    return data;
}
+(CGSize)sizeOfText:(NSString*)text font:(UIFont*)font bundingSize:(CGSize)size{
    
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: [mutableParagraphStyle copy]};
    CGRect rect = [text boundingRectWithSize:(CGSize){size.width, size.height}
                                     options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes
                                     context:nil];
    CGFloat height = ceilf(rect.size.height);
    CGFloat width  = ceilf(rect.size.width);
    return CGSizeMake(width, height);
}

+(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
    roundedView.layer.masksToBounds = YES;
}
-(void)showActivityIndicator{
    
    [[AppCommonFunctions sharedInstance] performSelector:@selector(showIndicator) withObject:nil afterDelay:0.3];

}
-(void)showIndicator{
   
    if (![AppCommonFunctions sharedInstance].activityIndicator) {
        [AppCommonFunctions sharedInstance].activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [AppCommonFunctions sharedInstance].activityIndicator.translatesAutoresizingMaskIntoConstraints = YES;
        
        [AppCommonFunctions sharedInstance].activityBgImageView=[UIImageView new];
        [AppCommonFunctions sharedInstance].activityBgImageView.translatesAutoresizingMaskIntoConstraints = YES;
        [AppCommonFunctions sharedInstance].activityBgImageView.frame=CGRectMake(0, 0, APPDELEGATE.window.bounds.size.width, APPDELEGATE.window.bounds.size.height);
        [AppCommonFunctions sharedInstance].activityBgImageView.backgroundColor=[UIColor blackColor];
        [AppCommonFunctions sharedInstance].activityBgImageView.alpha=0.5;
        [AppCommonFunctions sharedInstance].activityBgImageView.userInteractionEnabled=YES;
        
    }
    [AppCommonFunctions sharedInstance].activityIndicator.center = APPDELEGATE.window.center;
    [APPDELEGATE.window addSubview: [AppCommonFunctions sharedInstance].activityBgImageView];
    [APPDELEGATE.window addSubview: [AppCommonFunctions sharedInstance].activityIndicator];
    [APPDELEGATE.window bringSubviewToFront:[AppCommonFunctions sharedInstance].activityBgImageView];
    [APPDELEGATE.window bringSubviewToFront:[AppCommonFunctions sharedInstance].activityIndicator];
    [[AppCommonFunctions sharedInstance].activityIndicator startAnimating];
}
-(void)stopActivityIndicator{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[AppCommonFunctions sharedInstance] selector:@selector(showIndicator) object: nil];
    
    [[AppCommonFunctions sharedInstance] performSelector:@selector(hideActivityIndicator) withObject:nil afterDelay:0.3];
}
-(void)hideActivityIndicator{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([AppCommonFunctions sharedInstance].activityIndicator) {
            [[AppCommonFunctions sharedInstance].activityIndicator stopAnimating];
            [[AppCommonFunctions sharedInstance].activityBgImageView removeFromSuperview];
            [[AppCommonFunctions sharedInstance].activityIndicator removeFromSuperview];
        }
        
    });

}
@end
