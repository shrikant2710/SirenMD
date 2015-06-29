//
//  TVSchemaHelper.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVSchemaHelper.h"
#import "TVSchema.h"
#import "TVSchemaField.h"
#import "TVObject.h"
#import "TVClassHelper.h"
#import "TVRequest.h"
#import "TrueVault.h"

@interface TVSchemaHelper ()
@property (nonatomic) NSInteger pendingSchemaFetches;
@property (nonatomic) NSInteger pendingSchemaUpdates;
@property (nonatomic) NSInteger pendingSchemaSaves;
@end

@interface TrueVault (TVSchemaHelper)
+ (TrueVault *)sharedVault;
- (void)getRemoteSchemasWithCompletionHandler:(void (^)(NSArray *remoteSchemaList, NSError *error))completionHandler;
@end

@implementation TVSchemaHelper

- (void)synchronizeSchemasWithCompletion:(void (^)(NSDictionary *schemasDictionary, NSError *error))completion {
    
    NSMutableDictionary *schemas = [NSMutableDictionary dictionary];
    
    NSDictionary *localSchemasDictionary = [TVSchemaHelper localSchemasDictionary];
    NSMutableDictionary *remoteSchemasDictionary = [NSMutableDictionary dictionary];
    
    [[TrueVault sharedVault] getRemoteSchemasWithCompletionHandler:^(NSArray *remoteSchemaList, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        // Update remote schemas if needed
        for (TVSchema *remoteSchema in remoteSchemaList) {
            [remoteSchemasDictionary setObject:remoteSchema forKey:remoteSchema.name];
            
            TVSchema *localSchema = localSchemasDictionary[remoteSchema.name];
            if (localSchema) {
                
                // Update the remote schema with details from the local one if needed
                if ([TVSchemaHelper shouldUpdateRemoteSchema:remoteSchema withLocalSchema:localSchema]) {
                    
                    TVSchema *unionSchema = [TVSchemaHelper unionOfRemoteSchema:remoteSchema withLocalSchema:localSchema];
                    
                    self.pendingSchemaUpdates = self.pendingSchemaUpdates + 1;
                    [unionSchema saveWithCompletionHandler:^(NSError *error) {
                        if (error) {
                            completion(nil, error);
                            return;
                        }
                        
                        self.pendingSchemaUpdates = self.pendingSchemaUpdates - 1;
                        if (self.pendingSchemaUpdates == 0 && self.pendingSchemaSaves == 0)
                            completion(schemas, nil);
                    }];
                    
                    schemas[remoteSchema.name] = unionSchema;
                } else {
                    schemas[remoteSchema.name] = remoteSchema; // Note this has the SchemaID so is used over the local Schema
                }
            }
        }
        
        // Save new local schemas if needed
        NSDictionary *localSchemasThatAreNotRemote = [TVSchemaHelper determineWhichOfLocalSchemas:localSchemasDictionary areNotPartOfRemoteScemas:remoteSchemasDictionary];
        for (NSString *newLocalSchemaName in localSchemasThatAreNotRemote) {
            TVSchema *newLocalSchema = localSchemasThatAreNotRemote[newLocalSchemaName];
        
            if ([newLocalSchema.fields count] > 0) { // The TrueVault server cannot save a schema with no fields
                self.pendingSchemaSaves = self.pendingSchemaSaves + 1;
                [newLocalSchema saveWithCompletionHandler:^(NSError *error) {
                    if (error) {
                        completion(nil, error);
                        return;
                    }
                    
                    schemas[newLocalSchema.name] = newLocalSchema;
                    
                    self.pendingSchemaSaves = self.pendingSchemaSaves - 1;
                    if (self.pendingSchemaUpdates == 0 && self.pendingSchemaSaves == 0)
                        completion(schemas, nil);
                }];
            }
        }
        
        if (self.pendingSchemaUpdates == 0 && self.pendingSchemaSaves == 0) {
            completion(schemas, nil);
        }
    }];
}

#pragma mark - Local Schemas

+ (NSDictionary *)localSchemasDictionary {
    NSMutableDictionary *schemasDictionary = [NSMutableDictionary dictionary];
    
    NSArray *subclasses = ClassGetSubclasses([TVObject class]);
    for (NSInteger i = 0; i < [subclasses count]; i++) {
        Class subclass = subclasses[i];
        
        // Name
        NSString *className = [subclass trueVaultClassName];
        
        // Fields
        NSMutableArray *fieldsArray = [NSMutableArray array];
        
        NSArray *propertiesArray = ClassGetProperties(subclass);
        for (NSDictionary *propertyDictionary in propertiesArray) {
            NSString *propertyName = propertyDictionary[kPropertyDictionaryNameKey];
            
            NSString *propertyTypeString = propertyDictionary[kPropertyDictionaryTypeKey];
            NSString *propertyType = propertyTypeFromPropertyTypeString(propertyTypeString);
            
            if (isValidPropertyType(propertyType)) {
            
                BOOL isIndexed = isIndexedFromPropertyTypeString(propertyTypeString);
            
                TVSchemaField *field = [TVSchemaField schemaFieldWithName:propertyName type:[self schemaTypeForPropertyType:propertyType] isIndexed:isIndexed];
                [fieldsArray addObject:field];
            }
        }
        
        TVSchema *schema = [TVSchema schemaWithSchemaID:nil name:className fields:fieldsArray];
        schemasDictionary[className] = schema;
    }
    
    return schemasDictionary;
}

NSString *propertyTypeFromPropertyTypeString(NSString *propertyTypeString) {
    
    // Class properties are of the form T@"NSString" or T@"NSString<TVIndexed>" or similar. The following regex matches these and extracts the NSString or similar.
    NSRegularExpression *classRegex = [NSRegularExpression regularExpressionWithPattern:@"T@\"([a-zA-Z]*)<?[a-zA-Z]*>?\"" options:0 error:NULL];
    NSTextCheckingResult *match = [classRegex firstMatchInString:propertyTypeString options:0 range:NSMakeRange(0, [propertyTypeString length])];
    if (match.numberOfRanges > 0)
        return [propertyTypeString substringWithRange:[match rangeAtIndex:1]];

    // Non-classes have the format T[...] where the [...] is the representation of the property type (e.g. "i" for integer, "f" for float).
    if ([propertyTypeString length] > 0)
        return [propertyTypeString substringWithRange:NSMakeRange(1, [propertyTypeString length] - 1)];
    
    return nil;
}

BOOL isValidPropertyType(NSString *propertyType) {
    return ([propertyType isEqualToString:@"NSString"] || [propertyType isEqualToString:@"NSNumber"] || [propertyType isEqualToString:@"NSDate"] || [propertyType isEqualToString:@"NSArray"] || [propertyType isEqualToString:@"NSDictionary"]);
}

BOOL isIndexedFromPropertyTypeString(NSString *propertyTypeString) {
    
    // Properties with a protocol are of the form T@"NSString<TVIndexed>" (or similar). The following regex matches this and extracts the TVIndexed (or similar).
    NSRegularExpression *protocolRegex = [NSRegularExpression regularExpressionWithPattern:@"T@\"[a-zA-Z]*<([a-zA-Z]*)>\"" options:0 error:NULL];
    NSTextCheckingResult *match = [protocolRegex firstMatchInString:propertyTypeString options:0 range:NSMakeRange(0, [propertyTypeString length])];
    if (match.numberOfRanges > 0) {
        NSString *protocol = [propertyTypeString substringWithRange:[match rangeAtIndex:1]];
        if ([protocol isEqualToString:@"TVIndexed"])
            return YES;
    }
    return NO;
}

+ (NSString *)schemaTypeForPropertyType:(NSString *)propertyType {
    if ([propertyType isEqualToString:@"NSString"])
        return @"string";
    if ([propertyType isEqualToString:@"NSNumber"])
        return @"double";
    if ([propertyType isEqualToString:@"NSDate"])
        return @"date";
    if ([propertyType isEqualToString:@"NSArray"])
        return @"array";
    if ([propertyType isEqualToString:@"NSDictionary"])
        return @"dictionary";

    NSAssert(@"Invalid property type", @"Property type must be one of NSString, NSNumber or NSDate");
    return nil;
}

#pragma mark - Compare

+ (NSDictionary *)determineWhichOfLocalSchemas:(NSDictionary *)localSchemas areNotPartOfRemoteScemas:(NSDictionary *)remoteSchemas {
    NSMutableDictionary *localButNotRemoteSchemas = [NSMutableDictionary dictionary];
    for (NSString *schemaName in localSchemas) {
        if ([remoteSchemas objectForKey:schemaName] == nil)
            localButNotRemoteSchemas[schemaName] = localSchemas[schemaName];
    }
    return localButNotRemoteSchemas;
}

+ (BOOL)shouldUpdateRemoteSchema:(TVSchema *)remoteSchema withLocalSchema:(TVSchema *)localSchema {
    
    // Should update if there are local fields that are not remote.
    // Or if "index" is 1 in local and 0 in remote.
    for (TVSchemaField *localField in localSchema.fields) {

        NSInteger index = [remoteSchema.fields indexOfObject:localField];
        if (index == NSNotFound) {
            return YES;
        } else {
            TVSchemaField *remoteField = remoteSchema.fields[index];
            if (localField.index == YES && remoteField.index == NO)
                return YES;
        }
    }

    return NO;
}

+ (TVSchema *)unionOfRemoteSchema:(TVSchema *)remoteSchema withLocalSchema:(TVSchema *)localSchema {

    NSMutableArray *fields = [NSMutableArray array];
    
    // Iterate through local fields, adding any that are not present in remote.
    // If either field says it's indexed, make the field indexed.
    for (TVSchemaField *localField in localSchema.fields) {

        NSInteger index = [remoteSchema.fields indexOfObject:localField];
        if (index == NSNotFound) {
            [fields addObject:localField];
        } else {
            if (localField.index)
                [fields addObject:localField];
            else
                [fields addObject:remoteSchema.fields[index]];
        }
    }
    
    // Interate through remote fields, adding any that are not present in local.
    for (TVSchemaField *remoteField in remoteSchema.fields) {
        NSInteger index = [localSchema.fields indexOfObject:remoteField];
        if (index == NSNotFound)
            [fields addObject:remoteField];
    }
    
    TVSchema *unionSchema = [TVSchema schemaWithSchemaID:remoteSchema.schemaID name:localSchema.name fields:fields];
    return unionSchema;    
}

@end
