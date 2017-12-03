//
//  MenuViewController.h
//  IBMFSSReader
//
//  Created by Rohit on 06/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCustomCell.h"
#import "MenuTableCustomHeader.h"
#import "RootFeedProxy.h"

@protocol MenuViewControllerDelegate <NSObject>

@optional
- (void) loadSelectedFSSNewsLetter : (NSString *)paramFSSNewsLetterIdentifier;
- (void) loadSelectedFSSNewsLetter : (NSString *)paramFSSNewsLetterIdentifier
                   andSubMenuArray : (NSArray *) paramSubMenuArray;

@end

@interface MenuViewController : UIViewController <ZUUIRevealControllerDelegate, MenuCustomDelegate, RootFeedProxyDelegate,UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *rootMenuDict;
@property (nonatomic, weak) id<MenuViewControllerDelegate>menuViewControllerDelegate;

@end
