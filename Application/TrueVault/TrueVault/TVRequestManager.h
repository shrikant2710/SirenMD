//
//  TVRequestManager.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVRequest.h"

@interface TVRequestManager : NSObject

+ (void)sendRequest:(TVRequest *)request;

@end
