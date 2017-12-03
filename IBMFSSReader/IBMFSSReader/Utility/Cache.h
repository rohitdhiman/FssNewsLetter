//
//  Cache.h
//  RevailViewDemo
//
//  Created by Rohit on 02/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Cache : NSObject

@property (nonatomic, strong) UIView *touchIntercepterView;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *fssHeader;
@property (nonatomic, strong) NSString *w3UserId;
@property (nonatomic, strong) NSString *w3Password;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSMutableArray *menuDataModelArray;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL loginStatus;


+ (Cache *) cache;
+ (NSString *) getDeviceUserAgent;
+ (void) clearCookie;
+ (BOOL) isValidEmail : (NSString *)checkEmail;
+ (int) fetchCurrentYear;
+ (float) checkDeviceOSVersion;
@end
