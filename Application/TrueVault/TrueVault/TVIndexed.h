//
//  TVIndexed.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/19/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

/** TVIndexed is the protocol to which your properties must conform for them to be indexed (and thus searchable) by TrueVault.
 
	@property (nonatomic, strong) NSString <TVIndexed> *name;
 
 */
@protocol TVIndexed
@end

/** 
 Permits TVIndexed to be marked on NSStrings.
 */
@interface NSString (TVIndexed) <TVIndexed>
@end

/**
 Permits TVIndexed to be marked on NSNumbers.
 */
@interface NSNumber (TVIndexed) <TVIndexed>
@end

/**
 Permits TVIndexed to be marked on NSDates.
 */
@interface NSDate (TVIndexed) <TVIndexed>
@end
