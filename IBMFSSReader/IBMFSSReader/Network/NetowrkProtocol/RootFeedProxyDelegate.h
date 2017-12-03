//
//  RootFeedProxyDelegate.h
//  IBMFSSReader
//
//  Created by Rohit on 12/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RootFeedProxyDelegate <NSObject>

@optional
/**
 Method to get FSS Menu Dict
 @param : rootFssDict contains menu list
 */
- (void) getRootFssMenuDictionary : (NSMutableDictionary *)rootFssDict;

@required
- (void) rootFssFail : (NSString *)error;

@end
