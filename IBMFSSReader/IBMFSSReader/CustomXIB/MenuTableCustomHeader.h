//
//  MenuTableCustomHeader.h
//  IBMFSSReader
//
//  Created by Rohit on 11/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCustomDelegate.h"

@interface MenuTableCustomHeader : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) id<MenuCustomDelegate>menuCustomDelegate;
@property (nonatomic, strong) MenuModel *menuModel;

- (void) setHeaderText :(NSString *)headerText;
@end
