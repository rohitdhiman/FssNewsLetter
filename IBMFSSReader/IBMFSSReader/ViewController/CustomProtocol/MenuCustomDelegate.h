//
//  MenuCustomDelegate.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MenuModel.h"
#import "SubMenuModel.h"

@protocol MenuCustomDelegate <NSObject>

@optional
/**
    Method to get SubMenuModel
 */
-(void)getSubMenuModel : (SubMenuModel *)subMenuModel;
/**
    Method to getMenudModel sectionHeader
 */
-(void)getMenuModel : (MenuModel *)menuModel;

@end