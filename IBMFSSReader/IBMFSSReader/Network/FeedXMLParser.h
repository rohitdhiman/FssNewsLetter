//
//  FeedXMLParser.h
//  IBMFSSReader
//
//  Created by Rohit on 13/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedXMLParserDelegate.h"

@interface FeedXMLParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, weak) id<FeedXMLParserDelegate>feedXMLParserDelegate;

/**
 Method to parse XML input.
 */
- (void) startRSFeedParser : (NSString *)xmlDataToParse;

@end