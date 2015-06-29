//
//  TVRequestManager.m
//  TrueVault
//
//  Created by Edward Marks & Andrew Bellay on 8/21/14.
//  Copyright (c) 2014 TrueVault. All rights reserved.
//

#import "TVRequestManager.h"
#import "TVHelper.h"

@interface TVRequestManager () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *queueToArchive;

@end


@implementation TVRequestManager

static TVRequestManager *requestManager;

+ (void)sendRequest:(TVRequest *)request {

	if (!requestManager) {
		requestManager = [[TVRequestManager alloc] init];
		NSURLSessionConfiguration *ephemeralSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration]; // ephemeralSessionConfiguration "Returns a session configuration that uses no persistent storage for caches, cookies, or credentials." (Apple Docs)
		requestManager.operationQueue = [[NSOperationQueue alloc] init];
		requestManager.operationQueue.name = @"TrueVaultParallelOperationQueue";
		requestManager.URLSession = [NSURLSession sessionWithConfiguration:ephemeralSessionConfiguration delegate:requestManager delegateQueue:requestManager.operationQueue];
	}
	
	//NSLog(@"request.URL: %@", request.URL);
	//NSLog(@"request.HEADERS: %@", request.allHTTPHeaderFields);
	//NSLog(@"request.BODY: %@", request.HTTPBody);
	//NSLog(@"request.BODYSTRING: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
	//NSLog(@"request.METHOD: %@", request.HTTPMethod);
    NSURLSessionDataTask *requestDataTask = [requestManager.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = 0;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
            statusCode = [(NSHTTPURLResponse *)response statusCode];
        
		if (!error) {
            // Internal Server Error: This happen under some circumstances where the server will fail to provide a meaningful response but the request will not throw an error.
            if (statusCode >= 400) {
                if (request.completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        request.completion(nil, nil, [NSError errorWithDomain:kTrueVaultErrorDomain code:statusCode userInfo:@{@"Explanation": @"Internal Server Error"}]);
                    });
                    return;
                }
            }
            
			//NSLog(@"response: %@", response); // Debug.
			//NSLog(@"data: %@", data); // Debug.
			//NSLog(@"string: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); // Debug.

			NSDictionary *responseDict = [TVHelper JSONObjectWithData:data error:&error];

            // Decoding Error
            if (error) {
                error = nil;
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (responseString) {
                    NSData *base64ResponseData = [[NSData alloc] initWithBase64EncodedString:responseString options:0];
                    responseDict = [TVHelper JSONObjectWithData:base64ResponseData error:&error];
                }
                
                // Final decoding attempt failed
                if (error) {
                    if (request.completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            request.completion(nil, nil, error);
                        });
                    }
                    return;
                }
            }
            
            // Result Error
            BOOL resultIsError = [responseDict[@"result"] isEqualToString:@"error"];
            if (resultIsError) {
                NSError *resultError = [NSError errorWithDomain:kTrueVaultErrorDomain code:statusCode userInfo:responseDict[@"error"]];
                if (request.completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        request.completion(nil, nil, resultError);
                    });
                }
                return;
            }
			
            // Successfully Decoded Response
			if (request.completion) {
				// IFF GET for FILE.
				if (request.isFileRequest && request.TVHTTPMethod == TVHTTPMethodGET) {
					NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
					//NSLog(@"HTTPURLResponse: %@", HTTPURLResponse); // Debug.
					NSString *string = [HTTPURLResponse.allHeaderFields valueForKey:@"Content-Disposition"];
					[[string componentsSeparatedByString:@"; "] enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
						if ([string hasPrefix:@"filename="]) {
							NSString *fileName = [[string componentsSeparatedByString:@"="] lastObject];
							//NSLog(@"fileName: %@", fileName); // Debug.
							NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:responseDict];
							[dict setValue:fileName forKey:@"filename"];
							dispatch_async(dispatch_get_main_queue(), ^{
								request.completion([dict copy], data, nil);
							});
							return; // Return once a filename has been found.
						}
					}];
				} else {
					dispatch_async(dispatch_get_main_queue(), ^{
						request.completion(responseDict, data, nil);
					});
				}
			}
            return;
		} else {
			NSLog(@"HTTP Request Error: %@", error);
            if (request.completion) {
				dispatch_async(dispatch_get_main_queue(), ^{
					request.completion(nil, nil, error);
				});
			}
            return;
		}
	}];
	
	[requestDataTask resume];
}

@end
