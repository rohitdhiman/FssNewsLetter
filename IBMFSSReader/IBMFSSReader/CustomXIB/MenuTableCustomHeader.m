//
//  MenuTableCustomHeader.m
//  IBMFSSReader
//
//  Created by Rohit on 11/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "MenuTableCustomHeader.h"

@interface MenuTableCustomHeader ()

@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIButton *sectionHeaderButton;

@end

@implementation MenuTableCustomHeader
@synthesize menuModel = _menuModel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setHeaderText :(NSString *)headerText {
    self.headerLabel.text = [NSString stringWithFormat:@"%@",headerText];
}

- (IBAction)sectionHeaderButtonTapped:(id)sender {
    if(self.menuCustomDelegate && [self.menuCustomDelegate conformsToProtocol:@protocol(MenuCustomDelegate)]) {
        [self.menuCustomDelegate getMenuModel:_menuModel];
    }
}

@end
