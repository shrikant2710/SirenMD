//
//  TVObject.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/19/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVObject.h"
#import "TVClassHelper.h"
#import "TVQuery.h"
#import "TVRequest.h"
#import "TrueVault.h"
#import "TVHelpers.h"

@interface TrueVault (TVObject)

+ (TrueVault *)sharedVault;

- (void)saveObject:(TVObject *)object withCompletionHandler:(TVCompletionBlock)completionHandler;
- (void)fetchObject:(TVObject *)object withCompletionHandler:(TVCompletionBlock)completionHandler;
- (void)deleteObject:(TVObject *)object withCompletionHandler:(TVCompletionBlock)completionHandler;

@end

@interface TVQuery (TVObject) // Expose private initializer.
- (instancetype)initWithTrueVaultClassName:(NSString *)trueVaultClassName localClassName:(NSString *)localClassName filters:(NSArray *)filters;
@end

@interface TVObject ()
@property (nonatomic, strong) NSString *objectID;
@end

@implementation TVObject

NSDateFormatter *dateFormatterForTVObject = nil;
NSMutableDictionary *propertyTypesDictionary = nil;

+ (void)initialize {
    if (dateFormatterForTVObject == nil)
        dateFormatterForTVObject = dateFormatterForCommunicatingWithTrueVault();
    
    if (propertyTypesDictionary == nil)
        propertyTypesDictionary = [NSMutableDictionary dictionary];
}

+ (NSString *)trueVaultClassName {
    return NSStringFromClass([self class]);
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

- (void)saveWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] saveObject:self withCompletionHandler:completion];
}

- (void)fetchWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] fetchObject:self withCompletionHandler:completion];
}

- (void)deleteWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] deleteObject:self withCompletionHandler:completion];
}

+ (TVQuery *)queryWithFilters:(NSArray *)filters {
    TVQuery *query = [[TVQuery alloc] initWithTrueVaultClassName:[[self class] trueVaultClassName] localClassName:NSStringFromClass([self class]) filters:filters];
    return query;
}

#pragma mark - TVSerializable

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionary];

    for (NSDictionary *propertyDictionary in ClassGetProperties([self class])) {
        NSString *propertyName = propertyDictionary[kPropertyDictionaryNameKey];
        NSString *propertyType = propertyDictionary[kPropertyDictionaryTypeKey];
     
        if (propertyTypeStringIsValidTrueVaultType(propertyType)) {
            id value = [self valueForKey:propertyName];
            if (propertyTypeIsDateType(propertyType))
                value = [dateFormatterForTVObject stringFromDate:value];
            if ([value isKindOfClass:[[NSNumber numberWithBool:YES] class]])
                value = @((int)[value boolValue]);
            if (value)
                dictionaryRepresentation[propertyName] = value;
        }
    }
    
    return dictionaryRepresentation;
}

+ (instancetype)objectFromDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {
    id object = [[self alloc] init];
    [object updateWithDictionaryRepresentation:dictionaryRepresentation];
    return object;
}

// Update all of the fields on the object. @try{}@catch{} is used incase object no longer has this property.
- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {

    // Build property dictionary if needed
    NSString *className = NSStringFromClass([self class]);
    if (propertyTypesDictionary[className] == nil) {
        NSMutableDictionary *classPropertyTypesDictionary = [NSMutableDictionary dictionary];
        for (NSDictionary *propertyDictionary in ClassGetProperties([self class])) {
            classPropertyTypesDictionary[propertyDictionary[kPropertyDictionaryNameKey]] = propertyDictionary[kPropertyDictionaryTypeKey];
            propertyTypesDictionary[className] = classPropertyTypesDictionary;
        }
    }
    
    for (NSString *propertyKey in dictionaryRepresentation) {
        @try {
            id value = dictionaryRepresentation[propertyKey];
            if (propertyTypeIsDateType(propertyTypesDictionary[className][propertyKey]))
                value = [dateFormatterForTVObject dateFromString:value];
            [self setValue:value forKeyPath:propertyKey];
        } @catch (NSException *exception) {}
    }
}

BOOL propertyTypeStringIsValidTrueVaultType(NSString *propertyType) {
    for (NSString *validJSONType in @[@"NSString", @"NSNumber", @"NSDate", @"NSArray", @"NSDictionary"]) {
        if (propertyType && [propertyType rangeOfString:validJSONType].location != NSNotFound)
            return YES;
    }
    return NO;
}

BOOL propertyTypeIsDateType(NSString *propertyType) {
    return (propertyType && [propertyType rangeOfString:@"NSDate"].location != NSNotFound);
}

BOOL propertyTypeIsNumberType(NSString *propertyType) {
    return (propertyType && [propertyType rangeOfString:@"NSNumber"].location != NSNotFound);
}

@end
