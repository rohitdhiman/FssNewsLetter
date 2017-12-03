//
//  NewsReaderViewController.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeopleProxy.h"
#import "MenuViewController.h"

@interface NewsReaderViewController : UIViewController <PeopleProxyDelegate, MenuViewControllerDelegate,UIWebViewDelegate>

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSMutableDictionary *rootMenuDict;
@end
