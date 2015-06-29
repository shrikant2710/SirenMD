//
//  TrueVault.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVObject.h"
#import "TVFile.h"
#import "TVQuery.h"
#import "TVSort.h"
#import "TVConstants.h"
#import "TVIndexed.h"
#import "TVFilter.h"

/**
 The TrueVault class is how you connect to your TrueVault vault.
 */

@interface TrueVault : NSObject

/**
 Sets the Vault ID and the API key for your application.

 @param vaultID Vault ID for your project.
 @param APIKey API key for your project.
 @warning This should only be called once per run and it must be called before saving/fetching/deleting any TrueVault Objects or executing any queries. Recommendation is to call this in -application:didFinishLaunchingWithOptions:
 */
+ (void)setVaultID:(NSString *)vaultID APIKey:(NSString *)APIKey;

@end
