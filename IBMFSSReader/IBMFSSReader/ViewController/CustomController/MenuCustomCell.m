//
//  MenuCustomCell.m
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "MenuCustomCell.h"

@interface MenuCustomCell ()

@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIImageView *cellBackgroundImageView;

@end

@implementation MenuCustomCell
@synthesize menuModel = _menuModel;
@synthesize subMenuModel = _subMenuModel;
@synthesize menuCustomDelegate = _menuCustomDelegate;

- (void)awakeFromNib {
    // Initialization code
    self.cellBackgroundImageView.layer.cornerRadius = 10.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)menuButtonTapped:(UIButton *)sender {
    if(_menuCustomDelegate && [_menuCustomDelegate conformsToProtocol:@protocol(MenuCustomDelegate)]) {
        [_menuCustomDelegate getSubMenuModel:_subMenuModel];
    }
}

@end
