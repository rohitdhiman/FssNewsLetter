//
//  Constant.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPDELEGATE     ((AppDelegate *)[[UIApplication sharedApplication] delegate])

//Crittercism App Id
#define CrittercismAppId                        @"cf2bf2ce-a2ed-4456-a852-3379d5c3ca6d"

//Storyborad
#define RootStoryboardIdentifier                @"FSSNewsReader"
#define MenuViewControllerIdentifier            @"MenuViewController"
#define SubMenuViewControllerIdentifer          @"SubMenuViewController"
#define NewsReaderViewControllerIdentifier      @"NewsReaderViewController"
#define LoginViewControllerIdentifier           @"LoginViewController"
#define RootNavigationControllerIdentifier      @"RootNavigationController"
#define MenuDetailViewControllerIdentifier      @"MenuDetailViewController"

//Alert for n/w
#define NETWORKERROR                            @"Please check network connection."
#define NETWORKTITLE                            @"No Connectivity"

//Request
#define kPeopleAPIRequest                       @"kPeopleAPIRequest"
#define kFSSRootAPIRequest                      @"kFSSRootAPIRequest"
#define kFSSSubMenuRequest                      @"kFSSSubMenuRequest"

//Error Message
#define kUnknownErrorMessage                    @"Unknown error occured."

//Custom Font
//#define HeaderFont                              @"Prism-Regular"
#define HeaderFont                              @"LubalinGraphStd-Book"

@interface Constant : NSObject

@end
