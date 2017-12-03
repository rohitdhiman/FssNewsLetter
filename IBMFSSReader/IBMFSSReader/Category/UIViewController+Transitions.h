//
//  UIViewController+Transitions.h
//  IBMFSSNewsLetter
//
//  Created by Rohit on 23/07/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Transitions)

- (void) presentModalViewController:(UIViewController *)modalViewController withPushDirection: (NSString *) direction;

- (void) dismissModalViewControllerWithPushDirection:(NSString *) direction;

@end
