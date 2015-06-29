//
//  TVQuerySort.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "TVSort.h"

typedef NS_ENUM(NSInteger, TVSortType) {
    TVSortTypeAscending,
    TVSortTypeDescending
};

@interface TVSort ()
@property (nonatomic, strong) NSString *key;
@property (nonatomic) TVSortType sortType;
@end

@implementation TVSort

+ (TVSort *)sortAscendingWithKey:(NSString *)key {
    return [[TVSort alloc] initWithKey:key sortType:TVSortTypeAscending];
}

+ (TVSort *)sortDescendingWithKey:(NSString *)key {
    return [[TVSort alloc] initWithKey:key sortType:TVSortTypeDescending];
}

- (instancetype)initWithKey:(NSString *)key sortType:(TVSortType)sortType {
    self = [super init];
    if (self) {
        self.key = key;
        self.sortType = sortType;
    }
    return self;
}

#pragma mark - TVSerializable

- (NSDictionary *)dictionaryRepresentation {
    return @{self.key: stringForSortType(self.sortType)};
}

NSString *stringForSortType(TVSortType sortType){
    switch (sortType) {
        case TVSortTypeAscending:
            return @"asc";
        case TVSortTypeDescending:
            return @"desc";
    }
}

@end
