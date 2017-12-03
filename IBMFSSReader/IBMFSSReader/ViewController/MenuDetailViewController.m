//
//  MenuDetailViewController.m
//  IBMFSSNewsLetter
//
//  Created by Rohit on 30/07/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "MenuDetailViewController.h"
#import "NewsReaderViewController.h"
#import "SubMenuModel.h"
#import "DeviceUtility.h"

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface MenuDetailViewController ()

- (void) configureViewGesture;
- (void) slideNewsReaderViewController;
- (void) conigureMenuDataView;
- (NSMutableArray *) sortMenuArrayWithAscendingOrder : (NSMutableArray *) paramArray;
- (NSString *) modifyMenuTitleForDisplay : (NSString *) paramMenuTitle;
- (UIColor *) darkerColorForColor : (UIColor *)paramColor
                          andDiff : (float) paramColorDiff;
- (NSMutableString *) setSelectedMenuTitle : (NSString *) paramMenuTitle;
- (void) setSubMenuScrollViewFrame;
- (int) genericSubMenuWidthOfSelectedMenu : (NSMutableArray *) paramSubMenuModelArray;

@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UILabel *leaderInfoLabel;
@property (nonatomic, weak) IBOutlet UIView *menuModelView;
@property (nonatomic, weak) IBOutlet UILabel *selectedMenuLabel;
@property (nonatomic, weak) IBOutlet UIImageView *leaderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedMenuIdentifierImageViewLeadingConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *sepraterImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *menuScrollView;
@property (nonatomic, weak) IBOutlet UIScrollView *subMenuScrollView;
@property (nonatomic, weak) IBOutlet UIImageView *selectedMenuIdentifierImageView;

@property (nonatomic, weak) IBOutlet UILabel *thoughtLabel;
@property (nonatomic, weak) IBOutlet UILabel *quotesLabel;
@property (nonatomic, weak) IBOutlet UILabel *autherLabel;
@property (nonatomic, weak) IBOutlet UILabel *defaultHTMLTitleLabel;

@property (nonatomic, strong) NSMutableArray *menuDataModelArray;
@property (nonatomic, strong) NSMutableArray *subMenuModelArray;
@property (nonatomic, strong) NSMutableArray *sortedMenuArray;
@property (nonatomic, strong) NSMutableArray *tempMenuModelButtonArray;
@property (nonatomic, strong) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
@property (nonatomic, assign) BOOL isButtonTappedEventMannualyCalled;



@end

@implementation MenuDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self configureViewGesture];
    
    [self conigureMenuDataView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Method

- (void) configureViewGesture {
    //Configure PanGesture
    SEL gestureSelector = sel_registerName(REVEALGESTURE);
    SEL toggleSelector = sel_registerName(REVEALTOGGLE);
    if ([self.navigationController.parentViewController respondsToSelector:gestureSelector] && [self.navigationController.parentViewController respondsToSelector:toggleSelector])
    {
        // Check if a UIPanGestureRecognizer already sits atop our NavigationBar.
        if (![[self.view gestureRecognizers] containsObject:_navigationBarPanGestureRecognizer])
        {
            // If not, allocate one and add it.
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:gestureSelector];
            self.navigationBarPanGestureRecognizer = panGestureRecognizer;
            
            [self.view addGestureRecognizer:self.navigationBarPanGestureRecognizer];
        }
    }
    
    [self.leaderInfoLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *leaderInfoGesture = [[UITapGestureRecognizer alloc] init];
    leaderInfoGesture.numberOfTouchesRequired = 1;
    [leaderInfoGesture addTarget:self
                          action:@selector(leaderInfoOperationGesture:)];
    [self.leaderInfoLabel addGestureRecognizer:leaderInfoGesture];
    
    self.leaderImageView.layer.cornerRadius = 50.0f;
    self.leaderImageView.layer.masksToBounds = YES;
    
    //set custom font
    [self.thoughtLabel setFont:[UIFont fontWithName:HeaderFont size:15.0]];
    [self.quotesLabel setFont:[UIFont fontWithName:HeaderFont size:12.0]];
    [self.autherLabel setFont:[UIFont fontWithName:HeaderFont size:12.0]];
    [self.defaultHTMLTitleLabel setFont:[UIFont fontWithName:HeaderFont size:15.0]];
    [self.selectedMenuLabel setFont:[UIFont fontWithName:HeaderFont size:15.0]];

}

- (void) leaderInfoOperationGesture : (UITapGestureRecognizer *) paramGesture {
    [self loadSubMenuModelDetail:self.moreButton];
}

- (void) slideNewsReaderViewController {
    
    SEL gestureSelector = sel_registerName(REVEALGESTURE);
    SEL toggleSelector = sel_registerName(REVEALTOGGLE);
    if ([self.navigationController.parentViewController respondsToSelector:gestureSelector] &&
        [self.navigationController.parentViewController respondsToSelector:toggleSelector])
    {
        [self.navigationController.parentViewController performSelectorOnMainThread:toggleSelector
                                                                         withObject:nil
                                                                      waitUntilDone:NO];
    }
}

/**
 Method to load Menu
 */
- (void) conigureMenuDataView {
    
    self.tempMenuModelButtonArray = [[NSMutableArray alloc] init];
    self.menuDataModelArray = [Cache cache].menuDataModelArray;
    
    
    NSUInteger menuModelButtonTag = 0;
    
    //sort menuDataModelArray
    self.sortedMenuArray = [self sortMenuArrayWithAscendingOrder:self.menuDataModelArray];

    int availableWidth = self.menuModelView.frame.size.width - (30 * self.sortedMenuArray.count);
    int xMenuModelButton = availableWidth / (self.sortedMenuArray.count + (IsDeviceIPhone5() || IS_IPHONE_5 ? 1 : 0));
    int widthMenuButton  = xMenuModelButton;
    
    for(NSString *menuTitle in self.sortedMenuArray) {
        
        UIButton *menuModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuModelButton.frame = CGRectMake(xMenuModelButton, 20, 30, 30);
        
        menuModelButton.tag = menuModelButtonTag;
        [menuModelButton addTarget:self
                            action:@selector(menuModelButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        xMenuModelButton += widthMenuButton + 30;
        //[self.menuModelView addSubview:menuModelButton];
        [self.menuScrollView addSubview:menuModelButton];
        menuModelButtonTag++;
        
        if([menuTitle rangeOfString:@"Business"].location != NSNotFound) {
            
            [menuModelButton setBackgroundImage:[UIImage imageNamed:@"businessButton"]
                                       forState:UIControlStateNormal];
            
        } else if([menuTitle rangeOfString:@"Clients"].location != NSNotFound) {
            
            [menuModelButton setBackgroundImage:[UIImage imageNamed:@"clientButton"]
                                       forState:UIControlStateNormal];
            
        } else if([menuTitle rangeOfString:@"Industry"].location != NSNotFound) {
            
            [menuModelButton setBackgroundImage:[UIImage imageNamed:@"leaderButton"]
                                       forState:UIControlStateNormal];
            
        } else if([menuTitle rangeOfString:@"People"].location != NSNotFound) {
            
            [menuModelButton setBackgroundImage:[UIImage imageNamed:@"peopleButton"]
                                       forState:UIControlStateNormal];
        } else {
            [menuModelButton setBackgroundImage:[UIImage imageNamed:@"defaultMenu"]
                                       forState:UIControlStateNormal];
        }
        
        [self.tempMenuModelButtonArray addObject:menuModelButton];
    }
    [self.menuScrollView setContentSize:CGSizeMake(xMenuModelButton, 0)];
    
    self.isButtonTappedEventMannualyCalled = YES;
    if ([self.viewIdentifier length] > 0) {
        int tagIndex = 0;
        UIButton *tempMenuButton = nil;
        for(NSString *menuTitle in self.sortedMenuArray) {
            if ([self.viewIdentifier isEqualToString:menuTitle]) {
                tempMenuButton = (UIButton *)[self.tempMenuModelButtonArray objectAtIndex:tagIndex];
                tempMenuButton.tag = tagIndex;
                break;
            }
            tagIndex++;
        }
        
        [self menuModelButtonTapped:tempMenuButton];
    }else {
        UIButton *tempMenuButton = (UIButton *)[self.tempMenuModelButtonArray objectAtIndex:0];
        tempMenuButton.tag = 0;
        
        [self menuModelButtonTapped:tempMenuButton];
    }
    self.isButtonTappedEventMannualyCalled = NO;
}


/**
 Method to sort Array into ascending order
 @param paramArray is the array to sort.
 @return sorted array
 */
- (NSMutableArray *) sortMenuArrayWithAscendingOrder : (NSMutableArray *) paramArray {
    
    NSMutableArray *sortedMenuArray = [NSMutableArray array];
    for (NSDictionary *menuDict in paramArray) {
        [sortedMenuArray addObject:[NSString stringWithFormat:@"%@",[[menuDict allKeys] firstObject]]];
    }
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
    sortedMenuArray = (NSMutableArray *)[sortedMenuArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
    return sortedMenuArray;
}

- (NSString *) modifyMenuTitleForDisplay : (NSString *) paramMenuTitle {
    
    NSString *currentYear = [NSString stringWithFormat:@"%d",[Cache fetchCurrentYear]];
    
    if([paramMenuTitle rangeOfString:@"-"].location != NSNotFound) {
        paramMenuTitle = [paramMenuTitle stringByReplacingOccurrencesOfString:@"-"
                                                                   withString:@" "];
    }
    
    if([paramMenuTitle rangeOfString:@"Q1"].location != NSNotFound) {
        paramMenuTitle = [paramMenuTitle stringByReplacingOccurrencesOfString:@"Q1"
                                                                   withString:@""];
    }
    
    if([paramMenuTitle rangeOfString:currentYear].location != NSNotFound) {
        paramMenuTitle = [paramMenuTitle stringByReplacingOccurrencesOfString:currentYear
                                                                   withString:@""];
    }
    paramMenuTitle = [paramMenuTitle stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    return paramMenuTitle;
}

- (UIColor *) darkerColorForColor : (UIColor *)paramColor
                          andDiff : (float) paramColorDiff {
    CGFloat r, g, b, a;
    if ([paramColor getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - paramColorDiff, 0.0)
                               green:MAX(g - paramColorDiff, 0.0)
                                blue:MAX(b - paramColorDiff, 0.0)
                               alpha:a];
    return nil;
}

- (NSMutableString *) setSelectedMenuTitle : (NSString *) paramMenuTitle {
    NSArray *selecteMenuTitle = [[self modifyMenuTitleForDisplay:paramMenuTitle] componentsSeparatedByString:@" "];
    NSMutableString *menuTitleString = [[NSMutableString alloc] init];
    for(NSString *titleString in selecteMenuTitle){
        if([titleString length] > 2){
            [menuTitleString appendString:[NSString stringWithFormat:@" %@",titleString]];
        }
    }
    return menuTitleString;
}

- (void) setSubMenuScrollViewFrame {
    
    if (IsDeviceIPhone5() || IS_IPHONE_5) {
        self.subMenuScrollView.frame = CGRectMake(1, 124.5, 318, 68.5);
    }
    
    else if(IsDeviceIPhone6() || IS_IPHONE_6){
        self.subMenuScrollView.frame = CGRectMake(1, 149.5, 373, 93);
    }
    
    else if (IsDeviceIPhone6Plus() || IS_IPHONE_6_PLUS) {
        self.subMenuScrollView.frame = CGRectMake(1, 166.6, 412, 110.3);
    }
    
    else if (isDeviceFromiPhone4Series() || IS_IPHONE_4) {
        self.subMenuScrollView.frame = CGRectMake(1, 102.5, 318, 46.5);
    }
}

- (int) genericSubMenuWidthOfSelectedMenu : (NSMutableArray *) paramSubMenuModelArray {
    
    int widthSubMenuModelButton = 0;
    switch ([paramSubMenuModelArray count]) {
        case 1:
            widthSubMenuModelButton = self.subMenuScrollView.frame.size.width;
            break;
        case 2:
            widthSubMenuModelButton = self.subMenuScrollView.frame.size.width / 2;
            break;
            
        default:
            widthSubMenuModelButton = self.subMenuScrollView.frame.size.width / 3;
            break;
    }
    return widthSubMenuModelButton;
}

#pragma mark
#pragma mark MenuModelButton Selector
/**
 Method to load SubMenu of selected Menu
 */
- (void) menuModelButtonTapped : (UIButton *) paramSelectedMenuButton {
    
    if( self.isButtonTappedEventMannualyCalled == NO ) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.selectedMenuIdentifierImageViewLeadingConstraint.constant = paramSelectedMenuButton.frame.origin.x - 2 + (IsDeviceIPhone5() && IS_IPHONE_5 ? 0 : 0);
                             [self.view layoutIfNeeded];
                         } completion:nil];
    }else{
        self.selectedMenuIdentifierImageViewLeadingConstraint.constant = paramSelectedMenuButton.frame.origin.x - 2 + (IsDeviceIPhone5() && IS_IPHONE_5 ? 0 : 0);

    }
    
    //clear subMenuScrollView container
    for(UIView *subView in self.subMenuScrollView.subviews) {
        if([subView isKindOfClass:[UIButton class]]){
            [subView removeFromSuperview];
        }
    }

    //get selected Menu
    NSString *selectedMenu = [self.sortedMenuArray objectAtIndex:paramSelectedMenuButton.tag];
    for (NSDictionary *menuDict in self.menuDataModelArray) {
        NSString *key = [[menuDict allKeys] firstObject];
        if([selectedMenu isEqualToString:key]){
            self.subMenuModelArray = [menuDict objectForKey:key];
            break;
        }
    }
    
    //if there is no subMenu add menu as subMenu
    if([self.subMenuModelArray count] == 0) {
        SubMenuModel *subMenuModel = [[SubMenuModel alloc] initWithSubMenuModel:@"101"
                                                                   andSubMenuId:@"1001"
                                                                 andSubMenuName:selectedMenu
                                                          andSubMenuDisplayName:selectedMenu];
        
        [self.subMenuModelArray addObject:subMenuModel];
    }
    
    //Set title Menu name of the key
    self.selectedMenuLabel.text = [NSString stringWithFormat:@"%@'s Corner",[self setSelectedMenuTitle:selectedMenu]];
    
    [self setSubMenuScrollViewFrame];
    
    int xSubMenuModelButton = 0;
    int widthSubMenuModelButton = [self genericSubMenuWidthOfSelectedMenu:self.subMenuModelArray];
    
    NSUInteger subMenuModelButtonTag = 0;
    float paramColorDiff = 0.1;

    for(SubMenuModel *subMenuModel in self.subMenuModelArray) {

        UIButton *subMenuModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        subMenuModelButton.frame = CGRectMake(xSubMenuModelButton,0,
                                              widthSubMenuModelButton, self.subMenuScrollView.frame.size.height-1);
        subMenuModelButton.tag = subMenuModelButtonTag;
        
        [subMenuModelButton setTitle:[self modifyMenuTitleForDisplay:subMenuModel.subMenuDisplayName]
                            forState:UIControlStateNormal];
        [subMenuModelButton setTitleColor:[UIColor whiteColor]
                                 forState:UIControlStateNormal];
        [subMenuModelButton addTarget:self
                               action:@selector(loadSubMenuModelDetail:)
                     forControlEvents:UIControlEventTouchUpInside];
        [subMenuModelButton setBackgroundColor:[self darkerColorForColor:self.sepraterImageView.backgroundColor
                                                                 andDiff:paramColorDiff]];

        subMenuModelButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        subMenuModelButton.titleLabel.numberOfLines = 3;
        subMenuModelButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subMenuModelButton.titleLabel.font = [UIFont fontWithName:HeaderFont size:13.0];
        
        xSubMenuModelButton += widthSubMenuModelButton+1;
        paramColorDiff += 0.1;
        subMenuModelButtonTag++;
        [self.subMenuScrollView addSubview:subMenuModelButton];
    }
    [self.subMenuScrollView setContentSize:CGSizeMake(([self.subMenuScrollView.subviews count]*widthSubMenuModelButton - widthSubMenuModelButton), self.subMenuScrollView.frame.size.height)];
    
    float width = CGRectGetWidth(self.subMenuScrollView.frame);
    float height = CGRectGetHeight(self.subMenuScrollView.frame);
    CGRect toVisible = CGRectMake(50, 0, width, height);    
    [self.subMenuScrollView scrollRectToVisible:toVisible animated:YES];
    
}

//Navigate to the subMenuDetail ....
- (void) loadSubMenuModelDetail : (UIButton *) paramSelectedSubMenuButton {
    
    SubMenuModel *subMenuModel = (SubMenuModel *)[self.subMenuModelArray objectAtIndex:paramSelectedSubMenuButton.tag];
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    NewsReaderViewController *newsReaderViewController = [rootStoryboard instantiateViewControllerWithIdentifier:NewsReaderViewControllerIdentifier];
    
    newsReaderViewController.viewIdentifier = [paramSelectedSubMenuButton isEqual:self.moreButton] ? @"" : subMenuModel.subMenuDisplayName;
    
    [self.navigationController pushViewController:newsReaderViewController
                                         animated:YES];
    
}

#pragma mark
#pragma mark Button Tapped Method

-(IBAction)menuDetailButtonTapped:(id)sender {
    if([sender isEqual:self.menuButton]) {
        [self slideNewsReaderViewController];
    }else if ([sender isEqual:self.moreButton]) {
        //load default html in default webview. (next screen navigation)
        [self loadSubMenuModelDetail:self.moreButton];
    }
}

@end
