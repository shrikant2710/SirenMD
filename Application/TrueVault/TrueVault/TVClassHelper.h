//
//  TVClassHelper.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/19/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static inline NSArray *ClassGetSubclasses(Class parentClass) {
    int numClasses = objc_getClassList(NULL, 0);
    
    Class *classes = NULL;
    classes = (Class *)malloc(sizeof(Class) * numClasses);

    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++)
    {
        Class superClass = classes[i];
        do {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil)
            continue;
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    
    return result;
}

static NSString *kPropertyDictionaryNameKey = @"name";
static NSString *kPropertyDictionaryTypeKey = @"type";

static inline NSArray *ClassGetProperties(Class class) {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);

    NSMutableArray *result = [NSMutableArray array];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        NSString *propertyAttributesString = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSArray *propertyAttributes = [propertyAttributesString componentsSeparatedByString:@","];
        NSString *propertyType = propertyAttributes[0];
        
        [result addObject:@{kPropertyDictionaryNameKey: propertyName, kPropertyDictionaryTypeKey: propertyType}];
    }
    
    return result;
}