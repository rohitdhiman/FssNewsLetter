//
//  MenuModel.m
//  IBMFSSReader
//
//  Created by Rohit on 06/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "MenuModel.h"

@implementation MenuModel
@synthesize menuId = _menuId;
@synthesize menuName = _menuName;
@synthesize menuDisplayName = _menuDisplayName;

@synthesize parElem;
@synthesize root;
@synthesize label;
@synthesize title;
@synthesize type;
@synthesize parent;
@synthesize itemId;
@synthesize childSize;
@synthesize children;

- (id)initWithMenu : (NSString *)menuId
       andMenuName : (NSString *)menuName
andMenuDisplayName : (NSString *)menuDisplayName {
    self = [super init];
    if(self) {
        _menuId = menuId;
        _menuName = menuName;
        _menuDisplayName = menuDisplayName;
    }
    return self;
}

-(NSDictionary *)jsonMapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"parElem",@"parElem",
            @"root",@"root",
            @"label",@"label",
            @"title",@"title",
            @"type",@"type",
            @"parent",@"parent",
            @"itemId",@"id",
            @"childSize",@"childSize",
            @"children",@"children",
            nil];
}
+(MenuModel *)menuModelFromDictionary:(NSDictionary *)dictionary {
    MenuModel *menuModel = [[MenuModel alloc] init];
    NSDictionary *mapping = [menuModel jsonMapping];
    for(NSString *attribute in [mapping allKeys])
    {
        NSString *classProperty = [mapping objectForKey:attribute];
        NSString *attributeValue = [dictionary objectForKey:attribute];
        if(attributeValue != nil && !([attributeValue isKindOfClass:[NSNull class]]))
        {
            [menuModel setValue:attributeValue forKey:classProperty];
        }
    }
    return menuModel;
}

+(NSDictionary *)dictionaryFromMenuModel:(MenuModel *)menuModel {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSDictionary *mapping = [menuModel jsonMapping];
    for(NSString *attribute in [mapping allKeys])
    {
        NSString *classProperty = [mapping objectForKey:attribute];
        if([menuModel valueForKeyPath:attribute] == nil)
        {
            [dict setValue:[NSNull null] forKey:classProperty];
        }
        else
        {
            NSString *attributeValue = [menuModel valueForKeyPath:attribute];
            if(attributeValue != nil && !([attributeValue isKindOfClass:[NSNull class]]))
            {
                [dict setValue:attributeValue forKey:classProperty];
            }
        }
    }
    return dict;
}


@end
