//
//  SubMenuModel.h
//  IBMFSSReader
//
//  Created by Rohit on 10/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubMenuModel : NSObject

@property (nonatomic, strong) NSString *menuId;
@property (nonatomic, strong) NSString *subMenuId;
@property (nonatomic, strong) NSString *subMenuName;
@property (nonatomic, strong) NSString *subMenuDisplayName;

@property (nonatomic, strong) NSString *subMenuHTMLTitle;
@property (nonatomic, strong) NSString *subMenuHTMLDisplayTitle;


- (id) initWithSubMenuModel : (NSString *)menuId
               andSubMenuId : (NSString *)subMenuId
             andSubMenuName : (NSString *)subMenuName
      andSubMenuDisplayName : (NSString *)subMenuDisplayName;

- (id) initWithSubMenuModelWithHTML : (NSString *) paramSubMenuHTMLTitle
         andSubMenuHTMLDisplayTitle : (NSString *) paramSubMenuHTMLDisplayTitle;

@end
