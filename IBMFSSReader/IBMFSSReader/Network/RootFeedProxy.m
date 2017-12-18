//
//  RootFeedProxy.m
//  IBMFSSReader
//
//  Created by Rohit on 12/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "RootFeedProxy.h"
#import "MenuModel.h"
#import "ReferenceModel.h"

static NSString *const kFssRootURL = @"46823d8e-fd6d-4fed-9742-63d8f407240a/nav/6d5f9423-50ca-4302-a172-d29b9f96faf1/feed";

@interface RootFeedProxy ()

@property (nonatomic, strong) NSString *requestName;

@end

@implementation RootFeedProxy


#pragma mark
#pragma mark GET Method
- (void) getFSSRootFeed {
    
    //Enable this code, if online is required
    
    NSMutableString *urlStr = [[NSMutableString alloc] initWithFormat:@"%@%@",[Cache cache].baseURL,kFssRootURL];
    [super getRequestDataWithURL:urlStr
                 usingSessionKey:@""
                  andRequestName:kFSSRootAPIRequest];
    
    self.requestName = kFSSRootAPIRequest;
    /*
    //Read json from local, in offline mode only
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"json"];
    NSString *resposeString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self connectionFinishLoadingWithResponse:resposeString];
    */
}

#pragma mark
#pragma mark Proxy Super Method

- (void) connectionFinishLoadingWithResponse:(NSString *)responseString
{
    
    NSError *error;
    NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:0
                                                                 error:&error];
    
    NSRange range = [responseString rangeOfString:@"<!DOCTYPE html>"];
    if(range.length > 0)
    {
        if(self.rootFeedProxyDelegate)
        {
            [self.rootFeedProxyDelegate rootFssFail:kUnknownErrorMessage];
        }
    }
    else
    {
        if([self.requestName isEqualToString:kFSSRootAPIRequest])
        {
            [self saveFSSRootDetail:mainDict];
        }
    }
    
}

- (void) connectionFinishLoadingWithError : (NSString *)errorString
{
    if(self.rootFeedProxyDelegate && [self.rootFeedProxyDelegate conformsToProtocol:@protocol(RootFeedProxyDelegate)])
    {
        [self.rootFeedProxyDelegate rootFssFail:[NSString stringWithFormat:@"%@",errorString]];
    }
    
}

#pragma mark
#pragma mark Parser Method

- (void) saveFSSRootDetail : (NSDictionary *)responseDict {
    //Parsing json
    if([self.requestName isEqualToString:kFSSRootAPIRequest]) {
        NSMutableDictionary *menuDict = [RootFeedProxy parseFSSMenuDict:responseDict];
        
        if(self.rootFeedProxyDelegate && [self.rootFeedProxyDelegate conformsToProtocol:@protocol(RootFeedProxyDelegate)]) {
            [self.rootFeedProxyDelegate getRootFssMenuDictionary:menuDict];
        }
    }
    
    
}


+ (NSMutableDictionary *) parseFSSMenuDict : (NSDictionary *)responseDict {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    int currentYear = [[NSString stringWithFormat:@"%@",yearString] intValue];
    
    //Welcome to FSS
    MenuModel *rootMenuModel = nil;
    for(NSDictionary *breadcrumbDict in [responseDict objectForKey:@"breadcrumbs"]) {
        NSString *root = [NSString stringWithFormat:@"%@",[breadcrumbDict valueForKey:@"root"]];
        if( [root isEqualToString:@"true"]) {
            rootMenuModel = [MenuModel menuModelFromDictionary:breadcrumbDict];
            break;
        }
    }
    
    //find roorMenuModel id is parent_Id in items. FSS 2015 from items
    MenuModel *fssMenuModel = nil;
    for(NSDictionary *fssMenuDict in [responseDict objectForKey:@"items"]) {
        if([rootMenuModel.itemId isEqualToString:[fssMenuDict valueForKey:@"parent"]]){
            int fssYear = [[[[fssMenuDict valueForKey:@"title"] componentsSeparatedByString:@" "] lastObject] intValue];
            //if(fssYear == currentYear-1) {
                fssMenuModel = [MenuModel menuModelFromDictionary:fssMenuDict];
                [Cache cache].fssHeader = [NSString stringWithFormat:@"%@",fssMenuModel.title];
                break;
            //}
        }
    }
    
    NSMutableArray *displayRootMenuArray = [[NSMutableArray alloc] init];
    for(NSDictionary *fssMenuDict in [responseDict objectForKey:@"items"])
    {
        //Get FSS-sub menu list. People, Business, Cleint ect
        if([fssMenuModel.itemId isEqualToString:[NSString stringWithFormat:@"%@",[fssMenuDict valueForKey:@"parent"]]]) {
            MenuModel *parentMenu = [MenuModel menuModelFromDictionary:fssMenuDict];
            [displayRootMenuArray addObject:parentMenu];
        }
    }
    
    NSMutableDictionary *menuDict = [[NSMutableDictionary alloc] init];
    
    for(MenuModel *displayRootMenuModel in displayRootMenuArray) {
        NSLog(@"Root : %@",displayRootMenuModel.title);
        NSMutableArray *displaySubMenuArray = [[NSMutableArray alloc] init];
        for(NSDictionary *fssMenuDict in [responseDict objectForKey:@"items"])
        {
            if([displayRootMenuModel.itemId isEqualToString:[NSString stringWithFormat:@"%@",[fssMenuDict valueForKey:@"parent"]]]) {
                MenuModel *displaySubMenuModel = [MenuModel menuModelFromDictionary:fssMenuDict];
                [displaySubMenuArray addObject:displaySubMenuModel.title];
                 NSLog(@"Child : %@",displaySubMenuModel.title);
            }
        }
        [menuDict setObject:displaySubMenuArray
                     forKey:[NSString stringWithFormat:@"%@",displayRootMenuModel.title]];
    }
    
    return menuDict;
}

@end
