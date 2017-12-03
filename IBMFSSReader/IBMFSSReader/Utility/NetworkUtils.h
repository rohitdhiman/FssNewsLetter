//
//  NetworkUtils.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <SystemConfiguration/SCNetworkReachability.h>

@interface NetworkUtils : NSObject

+ (BOOL) hasNetworkConnection;

@end
