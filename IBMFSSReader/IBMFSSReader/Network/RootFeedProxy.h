//
//  RootFeedProxy.h
//  IBMFSSReader
//
//  Created by Rohit on 12/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "Proxy.h"
#import "RootFeedProxyDelegate.h"

@interface RootFeedProxy : Proxy
@property (nonatomic, weak) id<RootFeedProxyDelegate>rootFeedProxyDelegate;

#pragma mark
#pragma mark GET Method
/**
 GET Method to get Root/LeftSide Menu list.
 */
- (void) getFSSRootFeed;


#pragma mark
#pragma mark Parser Method
/**
 Method to parse root fss menu response
 @param : response json data which is to be parsed
 */
- (void) saveFSSRootDetail : (NSDictionary *)responseDict;

@end
