//
//  TVSchemaField.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/22/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVSchemaField.h"

@implementation TVSchemaField

+ (TVSchemaField *)schemaFieldWithName:(NSString *)name type:(NSString *)type isIndexed:(BOOL)isIndexed {
    TVSchemaField *schemaField = [[TVSchemaField alloc] init];
    schemaField.name = name;
    schemaField.type = type;
    schemaField.index = isIndexed;
    return schemaField;
}

#pragma mark - TVSerializable

- (NSDictionary *)dictionaryRepresentation {
    return @{@"name" : self.name,
             @"type" : self.type,
             @"index" : @(self.index)};
}

+ (id)objectFromDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {
    TVSchemaField *field = [[TVSchemaField alloc] init];
    field.name = dictionaryRepresentation[@"name"];
    field.type = dictionaryRepresentation[@"type"];
    field.index = [dictionaryRepresentation[@"index"] boolValue];
    return field;
}

#pragma mark - Helper

- (BOOL)isEqual:(TVSchemaField *)field {
    return (self.name && field.name && [self.name isEqualToString:field.name]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (name, type, index): (%@, %@, %i)", NSStringFromClass([self class]), self, self.name, self.type, self.index];
}

@end