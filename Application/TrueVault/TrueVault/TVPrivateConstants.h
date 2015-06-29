//
//  TVPrivateConstants.h
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/20/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//


typedef void (^TVDataFetchedBlock)(NSData *data, NSError *error);
typedef void (^TVProgressBlock)(float percentComplete);

typedef void (^TVRequestCompletionBlock)(NSDictionary *responseDictionary, NSData *responseData, NSError *error);


@protocol TVSerializable <NSObject>
- (NSDictionary *)dictionaryRepresentation;
@optional
+ (instancetype)objectFromDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation;
- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation;
@end



/* Strings for TrueVault API & General Networking */
#define kBackgroundSessionConfigurationIdentifier @"com.TrueVault.TrueVaultSDK"

#define kBaseURI @"https://api.truevault.com/v1"
#define kEndpointVaults @"/vaults/"
#define kEndpointDocuments @"/documents"
#define kEndpointDocumentAll @"'\'?full_document'\'=false" // --> /documents\?full_document\=false
#define kEndpointBlobs @"/blobs"
#define kEndpointSchemas @"/schemas"
#define kEndpointSearchOption @"/?search_option="

#define kBodyParameterDocument @"document=%@"
#define kBodyParameterDocumentAndSchemaID @"document=%@&schema_id=%@"
#define kBodyParameterSchema @"schema=%@"

#define kHTTPRequestBoundary @"-----------a-unique-but-consistent-string-for-TrueVault"
#define searchParam   @"search_option"
#define kEndpointSearch @"/search"
#define kEndpointUsers @"/users"
#define kBodyParameterSearchOption @"search_option=%@"
