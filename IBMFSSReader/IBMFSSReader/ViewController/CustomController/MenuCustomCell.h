//
//  MenuCustomCell.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuModel.h"
#import "SubMenuModel.h"
#import "MenuCustomDelegate.h"

@interface MenuCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *menuLabel;
@property (nonatomic, weak) IBOutlet UILabel *menuDetailLabel;
@property (nonatomic, strong) MenuModel *menuModel;
@property (nonatomic, strong) SubMenuModel *subMenuModel;
@property (nonatomic, weak) id<MenuCustomDelegate> menuCustomDelegate;

@end
