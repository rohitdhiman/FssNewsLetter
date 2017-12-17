//
//  LoginViewController.h
//  IBMFSSReader
//
//  Created by Rohit on 15/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootFeedProxy.h"
#import "IBMFSSNewsLetter-Swift.h"

@interface LoginViewController : UIViewController <UINavigationControllerDelegate, RootFeedProxyDelegate, FSSUtilityManagerDelegate>

@end
