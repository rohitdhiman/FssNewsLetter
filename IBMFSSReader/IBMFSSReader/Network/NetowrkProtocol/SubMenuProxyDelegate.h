//
//  SubMenuProxyDelegate.h
//  IBMFSSNewsLetter
//
//  Created by Rohit on 25/07/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SubMenuProxyDelegate <NSObject>

@optional

/**
 Method to get FSS SubMenu from html into array
 @param : paramSubMenuArray contains sub menu list
 */
- (void) loadSubMenuFromParent : (NSMutableArray *)paramSubMenuArray;

@required
/**
 Method should implemented when there is some error returned from server or locally.
 @param paramError error message returned to user.
 */
- (void) subMenuDidFail : (NSString *) paramError;

@end
