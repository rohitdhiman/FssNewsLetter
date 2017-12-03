//
//  SubMenuModel.m
//  IBMFSSReader
//
//  Created by Rohit on 10/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "SubMenuModel.h"

@implementation SubMenuModel
@synthesize menuId = _menuId;
@synthesize subMenuId = _subMenuId;
@synthesize subMenuName = _subMenuName;
@synthesize subMenuDisplayName = _subMenuDisplayName;
@synthesize subMenuHTMLTitle = _subMenuHTMLTitle;
@synthesize subMenuHTMLDisplayTitle = _subMenuHTMLDisplayTitle;

- (id)initWithSubMenuModel : (NSString *)menuId
              andSubMenuId : (NSString *)subMenuId
            andSubMenuName : (NSString *)subMenuName
     andSubMenuDisplayName : (NSString *)subMenuDisplayName {
    
    self = [super init];
    if (self) {
        _menuId = menuId;
        _subMenuId = subMenuId;
        _subMenuName = subMenuName;
        _subMenuDisplayName = subMenuDisplayName;
    }
    return self;
}

- (id) initWithSubMenuModelWithHTML : (NSString *) paramSubMenuHTMLTitle
         andSubMenuHTMLDisplayTitle : (NSString *) paramSubMenuHTMLDisplayTitle {
    self = [super init];
    if (self)
    {
        _subMenuHTMLTitle = paramSubMenuHTMLTitle;
        _subMenuHTMLDisplayTitle = paramSubMenuHTMLDisplayTitle;
    }
    return self;
}
@end
