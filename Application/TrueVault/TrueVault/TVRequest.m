//
//  TVRequest.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVRequest.h"
#import "TrueVault.h"
#import "TVRequestManager.h"
#import "TVHelper.h"

// Expose a few private TrueVault properties and methods.
@interface TrueVault (TVRequest)
@property (nonatomic, readonly) NSString *APIKey;
@property (nonatomic, readonly) NSString *vaultID;
+ (TrueVault *)sharedVault;
@end

@interface TVRequest ()
@property (nonatomic, assign) BOOL isFileRequest;
@property (nonatomic, assign) TVHTTPMethod TVHTTPMethod;
@end

@implementation TVRequest

#pragma mark - HTTP Requests

+ (instancetype)requestWithHTTPMethod:(TVHTTPMethod)HTTPMethod endpoint:(NSString *)endpoint HTTPBodyString:(NSString *)bodyString completion:(TVRequestCompletionBlock)completion {
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@", kBaseURI, endpoint] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    TVRequest *request = [TVRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    request.completion = completion;
    [request setHTTPMethod:[TVRequest stringFromHTTPMethod:HTTPMethod]];
    
    if (bodyString && bodyString.length > 0) [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // REQUIRED for PUT requests:
    if (HTTPMethod == TVHTTPMethodPUT) [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Basic Authorization
    NSData *authData = [[NSString stringWithFormat:@"%@:", [TrueVault sharedVault].APIKey] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    request.TVHTTPMethod = HTTPMethod;
    request.isFileRequest = NO;
    return request;
}

+ (instancetype)fileRequestWithHTTPMethod:(TVHTTPMethod)HTTPMethod endpoint:(NSString *)endpoint fileName:(NSString *)fileName fileData:(NSData *)fileData completion:(TVRequestCompletionBlock)completion {
		
	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@", kBaseURI, endpoint] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	TVRequest *request = [TVRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	request.completion = completion;
	[request setHTTPMethod:[TVRequest stringFromHTTPMethod:HTTPMethod]];

	if (HTTPMethod == TVHTTPMethodPUT || HTTPMethod == TVHTTPMethodPOST) {
				
		if (fileData.length > 0) {
			NSMutableData *bodyData = [NSMutableData data];
			[bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", kHTTPRequestBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
			[bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSASCIIStringEncoding]];
			[bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[bodyData appendData:fileData];
			[bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kHTTPRequestBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
			[request setHTTPBody:bodyData];
		}
		
		[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHTTPRequestBoundary] forHTTPHeaderField: @"Content-Type"];
		
		// REQUIRED for PUT requests:
		if (HTTPMethod == TVHTTPMethodPUT) [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
	
	// Basic Authorization
	NSData *authData = [[NSString stringWithFormat:@"%@:", [TrueVault sharedVault].APIKey] dataUsingEncoding:NSASCIIStringEncoding];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
	[request setValue:authValue forHTTPHeaderField:@"Authorization"];

	request.TVHTTPMethod = HTTPMethod;
	request.isFileRequest = YES;
	return request;
}


+ (NSString *)stringFromHTTPMethod:(TVHTTPMethod)HTTPMethod {
	switch (HTTPMethod) {
		case TVHTTPMethodGET:
			return @"GET";
			break;
		case TVHTTPMethodPUT:
			return @"PUT";
			break;
		case TVHTTPMethodPOST:
			return @"POST";
			break;
		case TVHTTPMethodDELETE:
			return @"DELETE";
			break;
		default:
			return @"GET"; // Default is GET.
			break;
	}
}

- (void)sendRequest {
	[TVRequestManager sendRequest:self];
}

#pragma mark - HTTP Request Helper Methods


// Document (aka TVObject) API Methods

+ (TVRequest *)documentGETRequestWithDocument:(NSDictionary *)dictionary documentID:(NSString *)documentID completionHandler:(TVRequestCompletionBlock)completion {
    TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodGET endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointDocuments, documentID] HTTPBodyString:nil completion:completion];
	return request;
}

+ (TVRequest *)allDocumentsGETRequestWithCompletionHandler:(TVRequestCompletionBlock)completion {
	TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodGET endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointDocuments] HTTPBodyString:nil completion:completion];
	return request;
}

//+ (TVRequest *)documentGETRequestWithDocuments:(NSArray *)array completionHandler:(TVRequestCompletionBlock)completion {
//#warning
//	TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodGET endpoint:[NSString stringWithFormat:@"%@%@%@%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointDocuments, ] HTTPBodyString:nil completion:completion];
//	return request;
//}

+ (TVRequest *)documentsGETRequestWithSearchOptions:(NSDictionary *)document completionHandler:(TVRequestCompletionBlock)completion {
	NSString *searchString = [[TVHelper dataWithJSONObject:document] base64EncodedStringWithOptions:0];
	//NSLog(@"SearchString: %@", searchString);
	TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodGET endpoint:[NSString stringWithFormat:@"%@%@%@%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointSearchOption, searchString] HTTPBodyString:nil completion:completion];
	return request;
}

+ (TVRequest *)documentPUTRequestWithDocument:(NSDictionary *)dictionary documentID:(NSString *)documentID schemaID:(NSString *)schemaId completionHandler:(TVRequestCompletionBlock)completion {
	NSString *bodyDataString = [[TVHelper dataWithJSONObject:dictionary] base64EncodedStringWithOptions:0];
    if (schemaId) {
        bodyDataString = [NSString stringWithFormat:kBodyParameterDocumentAndSchemaID, bodyDataString, schemaId];
    } else {
        bodyDataString = [NSString stringWithFormat:kBodyParameterDocument, bodyDataString];
    }
    TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodPUT endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointDocuments, documentID] HTTPBodyString:bodyDataString completion:completion];
	return request;
}

+ (TVRequest *)documentPOSTRequestWithDocument:(NSDictionary *)dictionary schemaID:(NSString *)schemaId completionHandler:(TVRequestCompletionBlock)completion {
	NSString *bodyDataString = [[TVHelper dataWithJSONObject:dictionary] base64EncodedStringWithOptions:0];
	if (schemaId) {
		bodyDataString = [NSString stringWithFormat:kBodyParameterDocumentAndSchemaID, bodyDataString, schemaId];
	} else {
		bodyDataString = [NSString stringWithFormat:kBodyParameterDocument, bodyDataString];
	}
	//NSLog(@"%@ bodyString: %@", self, HTTPBodyString); // Debug.
	
    TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodPOST endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointDocuments] HTTPBodyString:bodyDataString completion:completion];
	return request;
}

+ (TVRequest *)documentDELETERequestWithDocument:(NSDictionary *)dictionary documentID:(NSString *)documentID completionHandler:(TVRequestCompletionBlock)completion {
    TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodDELETE endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointDocuments, documentID] HTTPBodyString:nil completion:completion];
    return request;
}


// Blob (aka File) API Methods

+ (TVRequest *)blobGETRequestWithBlob:(NSDictionary *)dictionary blobID:(NSString *)blobID completionHandler:(TVRequestCompletionBlock)completion {
	TVRequest *request = [TVRequest fileRequestWithHTTPMethod:TVHTTPMethodGET endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointBlobs, blobID] fileName:nil fileData:nil completion:completion];
	return request;
}

+ (TVRequest *)blobPUTRequestWithBlob:(NSDictionary *)dictionary blobID:(NSString *)blobID fileName:(NSString *)fileName data:(NSData *)fileData completionHandler:(TVRequestCompletionBlock)completion {
	TVRequest *request = [TVRequest fileRequestWithHTTPMethod:TVHTTPMethodPUT endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointBlobs, blobID] fileName:fileName fileData:fileData completion:completion];
	return request;
}

+ (TVRequest *)blobPOSTRequestWithBlob:(NSDictionary *)dictionary fileName:(NSString *)fileName data:(NSData *)fileData completionHandler:(TVRequestCompletionBlock)completion {
	TVRequest *request = [TVRequest fileRequestWithHTTPMethod:TVHTTPMethodPOST endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointBlobs] fileName:fileName fileData:fileData completion:completion];
	return request;
}

+ (TVRequest *)blobDELETERequestWithBlob:(NSDictionary *)dictionary blobID:(NSString *)blobID completionHandler:(TVRequestCompletionBlock)completion {
	TVRequest *request = [TVRequest fileRequestWithHTTPMethod:TVHTTPMethodDELETE endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointBlobs, blobID] fileName:nil fileData:nil completion:completion];
	return request;
}


// Schema API Methods

+ (TVRequest *)schemasGETRequestWithCompletionHandler:(TVRequestCompletionBlock)completion {
	TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodGET endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointSchemas] HTTPBodyString:nil completion:completion];
	return request;
}

+ (TVRequest *)schemaGETRequestWithDocument:(NSDictionary *)dictionary schemaID:(NSString *)schemaID completionHandler:(TVRequestCompletionBlock)completion {
	TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodGET endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointSchemas, schemaID] HTTPBodyString:nil completion:completion];
	return request;
}

+ (TVRequest *)schemaPUTRequestWithSchema:(NSDictionary *)dictionary schemaID:(NSString *)schemaID completionHandler:(TVRequestCompletionBlock)completion {
	NSString *HTTPBodyString = [NSString stringWithFormat:kBodyParameterSchema, [[TVHelper dataWithJSONObject:dictionary] base64EncodedStringWithOptions:0]];
    TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodPUT endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointSchemas, schemaID] HTTPBodyString:HTTPBodyString completion:completion];
    return request;
}

+ (TVRequest *)schemaPOSTRequestWithSchema:(NSDictionary *)dictionary completionHandler:(TVRequestCompletionBlock)completion {
	NSString *HTTPBodyString = [NSString stringWithFormat:kBodyParameterSchema, [[TVHelper dataWithJSONObject:dictionary] base64EncodedStringWithOptions:0]];
    TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodPOST endpoint:[NSString stringWithFormat:@"%@%@%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointSchemas] HTTPBodyString:HTTPBodyString completion:completion];
    return request;
}

+ (TVRequest *)schemaDELETERequestWithSchema:(NSDictionary *)dictionary schemaID:(NSString *)schemaID completionHandler:(TVRequestCompletionBlock)completion {
    TVRequest *request = [TVRequest requestWithHTTPMethod:TVHTTPMethodDELETE endpoint:[NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointSchemas, schemaID] HTTPBodyString:nil completion:completion];
    return request;
}


+ (instancetype)putDocumentwithData:(NSMutableDictionary *)dict endpoint:(NSString *)endpoint withAuthHeader:(NSString *)auth completion:(TVRequestCompletionBlock)completion {
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@", kBaseURI, endpoint] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    TVRequest *request = [TVRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
    request.completion = completion;
    [request setHTTPMethod:[TVRequest stringFromHTTPMethod:TVHTTPMethodPUT]];
    
    request = [TVRequest addMultipartDataWithParameters:dict toURLRequest:request];
//     [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Basic Authorization
    NSData *authData = [[NSString stringWithFormat:@"%@:", auth] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    request.TVHTTPMethod = TVHTTPMethodPOST;
    //request.isFileRequest = YES;
    return request;
}


+ (instancetype)postRequesforFormData:(NSMutableDictionary *)dict endpoint:(NSString *)endpoint withAuthHeader:(NSString *)auth completion:(TVRequestCompletionBlock)completion {
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@", kBaseURI, endpoint] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    TVRequest *request = [TVRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
    request.completion = completion;
    [request setHTTPMethod:[TVRequest stringFromHTTPMethod:TVHTTPMethodPOST]];

    request = [TVRequest addMultipartDataWithParameters:dict toURLRequest:request];
    
    // Basic Authorization
    NSData *authData = [[NSString stringWithFormat:@"%@:", auth] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    request.TVHTTPMethod = TVHTTPMethodPOST;
    //request.isFileRequest = YES;
    return request;
}


#pragma mark - Content-type: multipart/form-data


+ (TVRequest *)addMultipartDataWithParameters:(NSDictionary *)parameters toURLRequest:(TVRequest *)request
{
    NSString *boundary = nil;
    NSData *post = [self multipartDataWithParameters:parameters boundary:&boundary];
    [request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:boundary] forHTTPHeaderField:@"Content-type"];
    request.HTTPBody = post;
    return request;
}

+ (NSData *)multipartDataWithParameters:(NSDictionary *)parameters boundary:(NSString **)boundary
{
    NSMutableData *result = [[NSMutableData alloc] init];
    if (boundary && !*boundary) {
        char buffer[32];
        for (NSUInteger i = 0; i < 32; i++) buffer[i] = "0123456789ABCDEF"[rand() % 16];
        NSString *random = [[NSString alloc] initWithBytes:buffer length:32 encoding:NSASCIIStringEncoding];
        *boundary = [NSString stringWithFormat:@"MyApp--%@", random];
    }
    NSData *newline = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundary ? *boundary : @""] dataUsingEncoding:NSUTF8StringEncoding];
    
    for (NSArray *pair in [self flatten:parameters]) {
        [result appendData:boundaryData];
        [self appendToMultipartData:result key:pair[0] value:pair[1]];
        [result appendData:newline];
    }
    NSString *end = [NSString stringWithFormat:@"--%@--\r\n", boundary ? *boundary : @""];
    [result appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    return result;
}

+ (void)appendToMultipartData:(NSMutableData *)data key:(NSString *)key value:(id)value
{
    if ([value isKindOfClass:NSData.class]) {
        NSString *name = key;
        if ([key rangeOfString:@"%2F"].length) {
            NSRange r = [name rangeOfString:@"%2F"];
            key = [key substringFromIndex:r.location + r.length];
            name = [name substringToIndex:r.location];
        }
        NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", name, key];
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:value];
    } else {
        NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value];
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}


#pragma mark - Helpers

+ (NSString *)unescape:(NSString *)string
{
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), kCFStringEncodingUTF8));
}

+ (NSString *)escape:(NSString *)string
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, CFSTR("*'();:@&=+$,/?!%#[]"), kCFStringEncodingUTF8));
}

+ (NSArray *)flatten:(NSDictionary *)dictionary
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:dictionary.count];
    NSArray *keys = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        id value = [dictionary objectForKey:key];
        if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:NSSet.class]) {
            NSString *k = [[self escape:key] stringByAppendingString:@"[]"];
            for (id v in value) {
                [result addObject:@[k, v]];
            }
        } else if ([value isKindOfClass:NSDictionary.class]) {
            for (NSString *k in value) {
                NSString *kk = [[self escape:key] stringByAppendingFormat:@"[%@]", [self escape:k]];
                [result addObject:@[kk, [value valueForKey:k]]];
            }
        } else {
            [result addObject:@[[self escape:key], value]];
        }
    }
    return result;
}
+ (instancetype)fetchImageFromBlobID:(NSString *)blobID forAuth:(NSString *)auth completion:(TVRequestCompletionBlock)completion{
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@", kBaseURI, [NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults, [TrueVault sharedVault].vaultID, kEndpointBlobs, blobID]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    TVRequest *request = [TVRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
    request.completion = completion;
    [request setHTTPMethod:[TVRequest stringFromHTTPMethod:TVHTTPMethodGET]];
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHTTPRequestBoundary] forHTTPHeaderField: @"Content-Type"];
    
    // Basic Authorization
    NSData *authData = [[NSString stringWithFormat:@"%@:", auth] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    request.TVHTTPMethod = TVHTTPMethodPOST;
    //request.isFileRequest = YES;
    return request;
}

+ (instancetype)fetchImageForUserFromBlobID:(NSString *)blobID forAuth:(NSString *)auth completion:(TVRequestCompletionBlock)completion{
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@", kBaseURI, [NSString stringWithFormat:@"%@%@%@/%@", kEndpointVaults,oldVaultID, kEndpointBlobs, blobID]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    TVRequest *request = [TVRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
    request.completion = completion;
    [request setHTTPMethod:[TVRequest stringFromHTTPMethod:TVHTTPMethodGET]];
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHTTPRequestBoundary] forHTTPHeaderField: @"Content-Type"];
    
    // Basic Authorization
    NSLog(@"%@",auth);
    NSData *authData = [[NSString stringWithFormat:@"%@:", auth] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    request.TVHTTPMethod = TVHTTPMethodPOST;
    //request.isFileRequest = YES;
    return request;
}

@end
