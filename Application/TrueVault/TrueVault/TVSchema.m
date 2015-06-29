//
//  TVSchema.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/22/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVSchema.h"
#import "TVSchemaField.h"
#import "TrueVault.h"

@interface TrueVault (TVSchema)
+ (TrueVault *)sharedVault;
- (void)saveSchema:(TVSchema *)schema withCompletionHandler:(TVCompletionBlock)completionHandler;
- (void)fetchSchema:(TVSchema *)schema withCompletionHandler:(TVCompletionBlock)completionHandler;
@end


@implementation TVSchema

+ (TVSchema *)schemaWithSchemaID:(NSString *)schemaID name:(NSString *)name fields:(NSArray *)fields {
    TVSchema *schema = [[TVSchema alloc] init];
    schema.schemaID = schemaID;
    schema.name = name;
    schema.fields = fields;
    return schema;
}

- (void)saveWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] saveSchema:self withCompletionHandler:completion];
}

- (void)fetchWithCompletionHandler:(TVCompletionBlock)completion {
    [[TrueVault sharedVault] fetchSchema:self withCompletionHandler:completion];
}

#pragma mark - TVSerializable

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionary];
    
    if (self.schemaID)
        dictionaryRepresentation[@"id"] = self.schemaID;
    
    if (self.name)
        dictionaryRepresentation[@"name"] = self.name;

    NSMutableArray *fields = [NSMutableArray array];
    for (TVSchemaField *field in self.fields)
        [fields addObject:[field dictionaryRepresentation]];
    dictionaryRepresentation[@"fields"] = fields;
    
    return dictionaryRepresentation;    
}

+ (id)objectFromDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {
    TVSchema *schema = [[TVSchema alloc] init];
    [schema updateWithDictionaryRepresentation:dictionaryRepresentation];
    return schema;
}

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {
    
    self.schemaID = dictionaryRepresentation[@"id"];
    self.name = dictionaryRepresentation[@"name"];
    
    NSMutableArray *finalFields = [NSMutableArray array];
    
    NSMutableArray *newFields = [NSMutableArray array];
    for (NSDictionary *fieldDictionary in dictionaryRepresentation[@"fields"])
        [newFields addObject:[TVSchemaField objectFromDictionaryRepresentation:fieldDictionary]];

    // Iterate through current fields, adding any that are not present in new set.
    // If either field says it's indexed, make the field indexed.
    for (TVSchemaField *field in self.fields) {
        NSInteger index = [newFields indexOfObject:field];
        if (index == NSNotFound) {
            [finalFields addObject:field];
        } else {
            if (field.index)
                [finalFields addObject:field];
            else
                [finalFields addObject:newFields[index]];
        }
    }
    
    // Interate through new fields, adding any that are not present in local.
    for (TVSchemaField *newField in newFields) {
        NSInteger index = [self.fields indexOfObject:newField];
        if (self.fields == nil || index == NSNotFound) // If self.fields == nil then index = 0.
            [finalFields addObject:newField];
    }
    
    self.fields = finalFields;
}

#pragma mark - Helpers

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p> %@, %@", NSStringFromClass([self class]), self, self.schemaID, self.name];
    for (TVSchemaField *field in self.fields)
        [description appendFormat:@"\r        %@", field];
    return description;
}

@end
