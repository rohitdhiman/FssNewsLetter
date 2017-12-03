//
//  Proxy.m
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "Proxy.h"
//#import "NSData+Additions.h"
//#import "NSMutableURLRequest+BasicAuth.h"

static NSString *const kNullResponse = @"Null Response";

@implementation Proxy

- (void) getRequestDataWithURL : (NSString *)url
               usingSessionKey : (NSString *)key
                andRequestName : (NSString *)rName {
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    __block NSString *responseString = @"";
    @try {
        [request setURL:URL];
        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:60];
        
        if(![rName isEqualToString:kFSSRootAPIRequest]){
            [request setValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/atom+xml" forHTTPHeaderField:@"Accept"];
        }else {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        }
        
        [request setValue:[NSString stringWithFormat:@"%@",rName] forHTTPHeaderField:@"requestType"];
        [request setValue:[NSString stringWithFormat:@"%@",[Cache cache].userAgent] forHTTPHeaderField:@"User-Agent"];
 
        //encoding username and password
        NSString *authStr = [NSString stringWithFormat:@"%@:%@",[Cache cache].w3UserId,[Cache cache].w3Password];
        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@",[authData base64EncodedStringWithOptions:0]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if([data length] > 0 || [httpResponse statusCode] == 200)
                                   {
                                       responseString = [[NSString alloc] initWithData:data
                                                                              encoding:NSUTF8StringEncoding];
                                       //return responseString
                                       NSLog(@"Request Headers : \n%@",[request allHTTPHeaderFields]);
                                       NSLog(@"\nResponse : %@",responseString);
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self connectionFinishLoadingWithResponse:responseString];
                                       });
                                   }
                                   else
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self connectionFinishLoadingWithError:kNullResponse];
                                       });
                                   }
                               }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception  : %@",[exception reason]);
    }
    @finally {
        NSLog(@"Finally Called");
    }
}

#pragma mark
#pragma mark Response Handler Method
- (void) connectionFinishLoadingWithResponse : (NSString *)responseString
{
    
}

- (void) connectionFinishLoadingWithError : (NSString *)errorString
{
    
}

@end