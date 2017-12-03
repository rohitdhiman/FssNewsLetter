//
//  NetworkUtils.m
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "NetworkUtils.h"

@implementation NetworkUtils

+ (BOOL) hasNetworkConnection {
    
    SCNetworkReachabilityRef reach = SCNetworkReachabilityCreateWithName(kCFAllocatorSystemDefault, "google.com");
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(reach, &flags);
    BOOL ret = (kSCNetworkReachabilityFlagsReachable & flags) || (kSCNetworkReachabilityFlagsConnectionRequired & flags);
    CFRelease(reach);
    reach = nil;
    
    return ret;
}

@end