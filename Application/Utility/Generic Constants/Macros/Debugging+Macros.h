//
//  Last Updated by Alok on 26/02/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#ifndef Debugging_Macros_h
#define Debugging_Macros_h

#ifndef DEBUG
#undef NSLog
#define NSLog(args, ...)
#endif

#define M_N                                    [NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]

#define OBSERVATION_POINT                       NSLog(@"\n%@ EXECUTED upto %d\n", M_N, __LINE__);

#define CLEAR_XCODE_CONSOLE            NSLog(@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

#endif


//////////////////////ADVANCED TRY CATCH SYSTEM////////////////////////////////////////
#ifndef UseTryCatch
#define UseTryCatch                                     1
#ifndef UsePTMName
#define UsePTMName                                      0 //USE 0 TO DISABLE AND 1 TO ENABLE PRINTING OF METHOD NAMES WHERE EVER TRY CATCH IS USED
#if UseTryCatch
#if UsePTMName
#define TCSTART                                         @try { NSLog(@"\n%@\n", M_N);
#else
#define TCSTART                                         @try {
#endif
#define TCEND                                           } @catch (NSException *e) { NSLog(@"\n\n\n\n\n\n\
\n\n|EXCEPTION FOUND HERE...PLEASE DO NOT IGNORE\
\n\n|FILE NAME         %s\
\n\n|LINE NUMBER       %d\
\n\n|METHOD NAME       %@\
\n\n|EXCEPTION REASON  %@\
\n\n\n\n\n\n\n", strrchr(__FILE__, '/'), __LINE__, M_N, e); };
#else
#define TCSTART                                         {
#define TCEND                                           }
#endif
#endif
#endif
//////////////////////ADVANCED TRY CATCH SYSTEM////////////////////////////////////////

#define EXCEPTION_MESSAGE(X)[CommonFunctions showNotificationInViewController : APPDELEGATE.window.rootViewController withTitle : nil withMessage :[NSString stringWithFormat:@"\n\n\n\n\n\n\
\n\n|EXCEPTION FOUND HERE...PLEASE DO NOT IGNORE\
\n\n|FILE NAME         %s\
\n\n|LINE NUMBER       %d\
\n\n|METHOD NAME       %@\
\n\n|EXCEPTION REASON  %@\
\n\n\n\n\n\n\n", strrchr(__FILE__, '/'), __LINE__, M_N, X] withType : TSMessageNotificationTypeError withDuration : MIN_DUR];


#ifdef DEBUG

#define CHECK_IF_VIEW_CONTROLLER_DEALLOCATED_WHEN_POPPED     {NSArray *viewControllers = self.navigationController.viewControllers;\
if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self){}else if ([viewControllers indexOfObject:self] == NSNotFound) {__block __weak typeof(self) bself = self;\
    NSLog(@"%@ just popped out and next within few seconds it should print its deallocation message", [[bself class]description]);\
    [[NSUserDefaults standardUserDefaults]setObject:@"exist" forKey:[[bself class]description]]; \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{if ((bself!=nil)&&[bself isNotNull:[[NSUserDefaults standardUserDefaults]objectForKey:[[bself class]description]]]) {NSLog(@"%@",[NSString stringWithFormat:@"%@ doesn't deallocated even it is popped out from navigation stack.. check for possibility of error", [[bself class]description]]);}});}}
#else

#define CHECK_IF_VIEW_CONTROLLER_DEALLOCATED_WHEN_POPPED

#endif
