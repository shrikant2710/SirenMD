//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#define ApplicationSpecificConstants_h


#define RETURN_IF_NO_INTERNET_AVAILABLE_WITH_USER_WARNING if (![CommonFunctions getStatusForNetworkConnectionAndShowUnavailabilityMessage:YES]) return;

#define RETURN_IF_NO_INTERNET_AVAILABLE                   if (![CommonFunctions getStatusForNetworkConnectionAndShowUnavailabilityMessage:NO]) return;

/**
 get status of internet connection
 */
#define IS_INTERNET_AVAILABLE_WITH_USER_WARNING           [CommonFunctions getStatusForNetworkConnectionAndShowUnavailabilityMessage:YES]
#define IS_INTERNET_AVAILABLE                             [CommonFunctions getStatusForNetworkConnectionAndShowUnavailabilityMessage:NO]

#define SHOW_SERVER_NOT_RESPONDING_MESSAGE                [CommonFunctions showNotificationInViewController:self withTitle:nil withMessage:@"Server not responding .Please try again after some time." withType:TSMessageNotificationTypeError withDuration:MIN_DUR];
#define CONTINUE_IF_MAIN_THREAD if ([NSThread isMainThread] == NO) { NSAssert(FALSE, @"Not called from main thread"); }


#define FUNCTIONALITY_PENDING_MESSAGE [CommonFunctions showStatusBarNotificationWithMessage:@"Development in progress." withDuration:2.0];

#define MIN_DUR 3

#define IMG(x) [CommonFunctions getDeviceSpecificImageNameForName: x]

#define PUSH_NOTIFICATION_DEVICE_TOKEN                    @"deviceToken"
#define DEVICE_KEY                                        @"deviceKey"

#define TIME_DELAY_IN_FREQUENTLY_SAVING_CHANGES 1

#define WINDOW_OBJECT ((UIWindow *)[[[UIApplication sharedApplication].windows sortedArrayUsingComparator: ^NSComparisonResult (UIWindow *win1, UIWindow *win2) { return win1.windowLevel - win2.windowLevel; }]lastObject])

#define COMMON_VIEW_CONTROLLER_METHODS \
- (id)initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil { \
self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];            \
if (self) {                                                                       \
}                                                                             \
return self;                                                                  \
}                                                                                 \
- (id)init {                                                                      \
self = [super init];                                                          \
if (self) {                                                                   \
}                                                                             \
return self;                                                                  \
}                                                                                 \
- (void)dealloc { \
[[NSNotificationCenter defaultCenter]removeObserver:self]; \
NSLog(@"%@ deallocated", [[self class]description]); \
[[NSUserDefaults standardUserDefaults]removeObjectForKey:[[self class]description]]; \
} \
- (void)didReceiveMemoryWarning {                                                 \
[super didReceiveMemoryWarning];                                              \
} \
- (void)viewDidDisappear:(BOOL)animated { \
CHECK_IF_VIEW_CONTROLLER_DEALLOCATED_WHEN_POPPED \
[super viewDidDisappear: animated]; \
}

#define LOG_VIEW_CONTROLLER_LOADING NSLog(@"%@ loaded", [[self class]description]);
#define LOG_VIEW_CONTROLLER_APPEARING NSLog(@"%@ appears", [[self class]description]);

#define APPLICATION_WEB_LINK @"http://www.getbetify.com/"
#define APPLICATION_APP_STORE_LINK @"https://itunes.apple.com/in/app/whatsthefoto/id910471409?mt=8"

#define  ACF  [AppCommonFunctions sharedInstance]
#define  DBM  [DatabaseManager sharedDatabaseManager]

/*
 Message titles AND texts for all alerts in the application
 */

#define MINIMUM_LENGTH_LIMIT_USERNAME 1
#define MAXIMUM_LENGTH_LIMIT_USERNAME 20

#define MINIMUM_LENGTH_LIMIT_FIRST_NAME 0
#define MAXIMUM_LENGTH_LIMIT_FIRST_NAME 24

#define MINIMUM_LENGTH_LIMIT_LAST_NAME 0
#define MAXIMUM_LENGTH_LIMIT_LAST_NAME 24

#define MINIMUM_LENGTH_LIMIT_PASSWORD 6
#define MAXIMUM_LENGTH_LIMIT_PASSWORD 20

#define MINIMUM_LENGTH_LIMIT_MOBILE_NUMBER 7
#define MAXIMUM_LENGTH_LIMIT_MOBILE_NUMBER 14

#define MINIMUM_LENGTH_LIMIT_EMOTION_TEXT 1
#define MAXIMUM_LENGTH_LIMIT_EMOTION_TEXT 24

#define MINIMUM_LENGTH_LIMIT_STATUS_TEXT 1
#define MAXIMUM_LENGTH_LIMIT_STATUS_TEXT 140

#define MAXIMUM_LENGTH_LIMIT_VERIFICATION_NUMBER 4

#define MAXIMUM_LENGTH_LIMIT_EMAIL 64




#define WAIT_FOR_RESPONSE_TIME 30

#define SHOW_EXCEPTION_MESSAGE(x) \
[CommonFunctions showNotificationInViewController: APPDELEGATE.window.rootViewController withTitle: nil withMessage: x withType: TSMessageNotificationTypeError withDuration: MIN_DUR];



#define PUSH_NOTIFICATION_TOKEN [[NSUserDefaults standardUserDefaults]objectForKey:PUSH_NOTIFICATION_DEVICE_TOKEN]

#define PATH_BY_APPENDING_DOCUMENT_DIRECTORY(x) [NSString stringWithFormat: @"%@/%@", [AKSMethods documentsDirectory], x]


#define Sign_in_Method             @"auth/login"
#define User_Method                @"auth/me"
#define Get_Users                  @"users"


//#define AccountID                   @"5096adcd-9124-4f53-b9a4-30e35c76c7c1"
//#define VaultID                     @"7e896622-7dbe-4b08-8be5-b56336773580"
//#define APIKEYTrueVault             @"c575a312-1a4d-4b85-8235-84b00ccfd592"
//#define InstabugToken               @"95fa0b79f120cf97b7d67381e3a26b93"
//#define atheleteSchema              @"2b839da4-89be-4f5d-b2da-1b14c7048e64"
//#define caseschema                  @"5b1b88e2-bab9-4418-a78d-3ecbeb54c6c0"
//#define userSchema                  @"4ac18cf1-92a4-4686-af08-d2597d559585"
//#define assigneeSchema              @"4f0a6c93-605b-43af-acf8-e8aaa7ae841f"



#define AccountID                   @"5096adcd-9124-4f53-b9a4-30e35c76c7c1"
#define VaultID                     @"afeaacf8-f950-463a-9825-bbea376a218c"
#define APIKEYTrueVault             @"c575a312-1a4d-4b85-8235-84b00ccfd592"
#define InstabugToken               @"95fa0b79f120cf97b7d67381e3a26b93"
#define atheleteSchema              @"784e1bcf-5489-40e8-a563-469f8c2c9162"
#define caseschema                  @"fde36993-ae0c-4ef9-9d92-96b6c157333d"
#define userSchema                  @"4ac18cf1-92a4-4686-af08-d2597d559585"
#define assigneeSchema              @"1a8fe6b9-232e-4a7a-9aeb-cd14791d1788"



#define UserRoleDoctor           @"1"
#define UserRoleTrainer          @"2"
#define UserRoleHeadDoctor       @"99"

#define PriorityUrgent           0
#define PriorityNormal           1

#define caseInjured         1
#define caseRecovering      2
#define caseClosed          3

#define atheleInjured          @"1"
#define atheleRecovering       @"2"
#define atheleHealthy          @"3"




//New Vault ID

#define oldVaultID @"7e896622-7dbe-4b08-8be5-b56336773580" //user images for old vault
