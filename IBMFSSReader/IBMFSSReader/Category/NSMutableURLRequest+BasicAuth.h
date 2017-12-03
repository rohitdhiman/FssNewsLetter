//
//  NSMutableURLRequest+BasicAuth.h
//  IBMFSSReader
//
//  Created by Rohit on 08/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (BasicAuth)

+ (void)basicAuthForRequest:(NSMutableURLRequest *)request withUsername:(NSString *)username andPassword:(NSString *)password;

@end
