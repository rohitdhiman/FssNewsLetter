//
//  Cache.m
//  RevailViewDemo
//
//  Created by Rohit on 02/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "Cache.h"

static Cache *objCache = nil;

@implementation Cache
@synthesize touchIntercepterView = _touchIntercepterView;
@synthesize baseURL = _baseURL;
@synthesize fssHeader = _fssHeader;
@synthesize loginStatus = _loginStatus;
@synthesize w3UserId = _w3UserId;
@synthesize w3Password = _w3Password;
@synthesize deviceToken = _deviceToken;
@synthesize rootViewController = _rootViewController;
@synthesize menuDataModelArray = _menuDataModelArray;

+ (Cache *) cache
{
    if(objCache == nil)
    {
        objCache = [[Cache alloc] init];
    }
    return objCache;
}

+ (NSString *) getDeviceUserAgent {
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    return [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

+ (void) clearCookie {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
}

+ (BOOL) isValidEmail : (NSString *)checkEmail
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkEmail];
}

+ (int) fetchCurrentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    return [[NSString stringWithFormat:@"%@",yearString] intValue];
}

+ (float) checkDeviceOSVersion {
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    return ver_float;
}
@end
