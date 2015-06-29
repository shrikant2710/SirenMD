//
//  TVFile.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/19/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVFile.h"
#import "TrueVault.h"

@interface TVFile ()
@property (nonatomic, strong) NSString *objectID;
@end

@interface TrueVault (TVFile)

+ (TrueVault *)sharedVault;

- (void)saveFile:(TVFile *)file withCompletionHandler:(TVCompletionBlock)completionHandler;
- (void)fetchFile:(TVFile *)file withCompletionHandler:(TVCompletionBlock)completionHandler;
- (void)deleteFile:(TVFile *)file withCompletionHandler:(TVCompletionBlock)completionHandler;

@end

@implementation TVFile

+ (TVFile *)fileWithName:(NSString *)name data:(NSData *)data {
    NSAssert(name && data, @"Error: Files must have both a Name and Data");
    TVFile *file = [[TVFile alloc] init];
    file.name = name;
    file.data = data;
    return file;
}

- (instancetype)init {
    return [self initWithObjectID:nil];
}

- (instancetype)initWithObjectID:(NSString *)objectID {
    self = [super init];
    if (self) {
        self.objectID = objectID;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    if (self.objectID)
        return @{@"objectID": self.objectID,
                 @"name": self.name,
                 @"data": self.data};
    else
        return @{@"name": self.name,
                 @"data": self.data};
}

+ (instancetype)objectFromDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {
    TVFile *file = [TVFile fileWithName:dictionaryRepresentation[@"name"] data:dictionaryRepresentation[@"data"]];
    file.objectID = dictionaryRepresentation[@"objectID"];
    return file;
}

- (void)saveWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] saveFile:self withCompletionHandler:completion];
}

- (void)fetchDataWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] fetchFile:self withCompletionHandler:completion];
}

- (void)deleteWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] deleteFile:self withCompletionHandler:completion];
}

@end
