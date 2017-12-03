//
//  PeopleProxy.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "Proxy.h"
#import "PeopleProxyDelegate.h"
#import "FeedXMLParser.h"

@interface PeopleProxy : Proxy <FeedXMLParserDelegate>
@property (nonatomic, weak) id<PeopleProxyDelegate>peopleProxyDelegate;
#pragma mark
#pragma mark GET Method
/**
 Method to call People news fss reader data.
 @peopleURL : input url to specify people webservice callback
 */
- (void) getNewsFSSDataWithPageIdentifer : (NSString *)pageIdentifer;


#pragma mark
#pragma mark Parser Method
/**
 Method to parse xml response
 @param response : contains xml response and to parse it.
 */
- (void) savePeopleDetail : (NSString *)response;

@end