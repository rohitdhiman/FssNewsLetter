//
//  MenuModel.h
//  IBMFSSReader
//
//  Created by Rohit on 06/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuModel : NSObject

@property (nonatomic, strong) NSString *menuId;
@property (nonatomic, strong) NSString *menuName;
@property (nonatomic, strong) NSString *menuDisplayName;

@property (nonatomic, strong) NSString *parElem;
@property (nonatomic, strong) NSString *root;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *parent;
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *childSize;
@property (nonatomic, strong) NSArray *children;

/**
 Initilize MenuModel object and pass required parameter
 @menuId for id of menu
 @menuName for menu Name as code
 @menuDisplayName for display menu name
 */

- (id)initWithMenu : (NSString *)menuId
       andMenuName : (NSString *)menuName
andMenuDisplayName : (NSString *)menuDisplayName;


//Parsing method
-(NSDictionary *)jsonMapping;
+(MenuModel *)menuModelFromDictionary:(NSDictionary *)dictionary;
+(NSDictionary *)dictionaryFromMenuModel:(MenuModel *)menuModel;

@end
