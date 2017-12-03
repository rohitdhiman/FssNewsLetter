//
//  Proxy.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Proxy : NSObject <NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableData *serviceResponse;
#pragma mark
#pragma mark GET Method
/**
 Handle GET request.
 @URL : input url specify web service url
 @SessionKey : specify the key or token
 @requestName : request key to identify hitting request*/
- (void) getRequestDataWithURL : (NSString *)url
               usingSessionKey : (NSString *)key
                andRequestName : (NSString *)rName;


#pragma mark
#pragma mark Response Handler Method
- (void) connectionFinishLoadingWithResponse : (NSString *)responseString;
- (void) connectionFinishLoadingWithError : (NSString *)errorString;

@end
