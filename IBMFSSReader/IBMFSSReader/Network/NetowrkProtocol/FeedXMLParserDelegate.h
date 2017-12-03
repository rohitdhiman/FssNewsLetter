//
//  FeedXMLParserDelegate.h
//  IBMFSSReader
//
//  Created by Rohit on 13/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FeedXMLParserDelegate <NSObject>

@optional
- (void) showXMLFeed : (NSString *)summeryFeed;

@end
