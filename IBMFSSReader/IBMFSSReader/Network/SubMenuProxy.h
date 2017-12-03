//
//  SubMenuProxy.h
//  IBMFSSNewsLetter
//
//  Created by Rohit on 25/07/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "Proxy.h"
#import "SubMenuProxyDelegate.h"

@interface SubMenuProxy : Proxy
@property (nonatomic, weak) id<SubMenuProxyDelegate>subMenuProxyDelegate;

#pragma mark
#pragma mark GET Method

/**
 Method to get sub menu of the page/parent
 @param paramPageIdentifier get sub menu of the selected page.
 */
- (void) getNewsFSSSubMenuWithPageIdentifier : (NSString *)paramPageIdentifier;

#pragma mark
#pragma mark Parser Method

/**
 Method to parse response returned from server.
 @param paramResponse the response which needs to be parsed
 */
- (void) saveSubMenuDetail : (NSString *) paramResponse;
@end
