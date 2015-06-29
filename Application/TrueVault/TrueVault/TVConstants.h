//
//  TVConstants.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/23/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

/**
 Completion block that is performed when most commands are executed.
 Note that the object itself is not passed back but is instead updated.
 */
typedef void (^TVCompletionBlock)(NSError *error);

/**
 Completion block that is performed when a query is executed.
 Note that the object itself is not passed back but is instead updated.
 */
typedef void (^TVQueryCompletionBlock)(NSArray *results, NSError *error);

static NSString *kTrueVaultErrorDomain = @"kTrueVaultErrorDomain";