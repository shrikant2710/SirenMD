//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>
#import "RDVTabBarController.h"

/**
 
 AppCommonFunctions:-
 This singleton class implements some app specific methods which are frequently needed in application.
 
 */

typedef void (^operationACFFinishedBlock)(id info);

@interface AppCommonFunctions : UIViewController <UIPageViewControllerDelegate,UITabBarControllerDelegate,UITabBarDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) operationACFFinishedBlock finished;
@property (nonatomic, strong) NSMutableDictionary *information;
@property (nonatomic, strong) CLLocation *myLocation;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) RDVTabBarController *tabBar;
@property (strong, nonatomic) NSMutableArray *activeUsers;
@property (strong, nonatomic) NSMutableArray *inActiveUsers;
@property (strong, nonatomic) NSMutableArray *newlyRegisteredUsers;
@property (strong, nonatomic) NSArray *arrayOfTextEditingResponders;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *activityBgImageView;

@property (nonatomic, readwrite) NSInteger currentIndex;
extern UIImage *navigationBarBackgroundImage1;

+ (AppCommonFunctions *)sharedInstance;
- (void)logout;
- (void)prepareViewWhenUserIsLoggedInFrom:(UINavigationController *)navigationController;
- (void)setBackgroundOnViewController:(UIViewController *)vc withImage:(UIImage *)image;
- (void)setBackgroundOnView:(UIView *)v withImage:(UIImage *)image;
- (void)prepareStartup;
- (void)enableIQKeyboardManager;
- (void)disableIQKeyboardManager;
- (id)getVCObjectOfClass:(Class)classType;
- (void)presentVCOfClass:(Class)class1 fromVC:(UIViewController *)nc animated:(BOOL)animated modifyVC:(operationACFFinishedBlock)modify;
- (void)pushVCOfClass:(Class)class1 fromNC:(UINavigationController *)nc animated:(BOOL)animated popFirstToVCOfClass:(Class)class2 modifyVC:(operationACFFinishedBlock)modify;
- (void)pushVCOfClass:(Class)class1 fromNC:(UINavigationController *)nc animated:(BOOL)animated setRootViewController:(BOOL)isRootViewController modifyVC:(operationACFFinishedBlock)modify;
- (UIViewController *)popToViewControllerOfKind:(Class)aClass from:(UINavigationController *)navController;
- (void)setCommonSetupForTableView:(UITableView *)tableView;
- (void)setAttributedPlaceHolder:(NSString *)ph OnTextFeild:(UITextField *)tf withFont:(UIFont *)f withTextColor:(UIColor *)c;

-(void)presentControllerwithShadow:(UIViewController *)showVc overController:(UIViewController *)overController;

-(void)dismissViewControllerWithShadow:(UIViewController *)obj;

+(void)saveUserDefaultWithObject:(id)object andKey:(NSString*)key;
+(void)removeObject:(NSString*)key;
+(id)getDataFromNSUserDefault:(NSString*)key;
+(CGSize)sizeOfText:(NSString*)text font:(UIFont*)font bundingSize:(CGSize)size;
+(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
-(void)showActivityIndicator;
-(void)stopActivityIndicator;
@end
