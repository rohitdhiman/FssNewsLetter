//
//  SubMenuViewController.h
//  IBMFSSNewsLetter
//
//  Created by Rohit on 24/07/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCustomCell.h"
#import "MenuViewController.h"
#import "PeopleProxy.h"
#import "SubMenuProxy.h"

@interface SubMenuViewController : UIViewController <MenuCustomDelegate, MenuViewControllerDelegate, PeopleProxyDelegate, SubMenuProxyDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *rootMenuDict;

@end
