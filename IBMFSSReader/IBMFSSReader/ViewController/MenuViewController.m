    //
//  MenuViewController.m
//  IBMFSSReader
//
//  Created by Rohit on 06/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuModel.h"
#import "SubMenuModel.h"
#import "NewsReaderViewController.h"
#import "MenuDetailViewController.h"

static NSString *const kDefaultListTitle = @"IBM FSS News Letter";

@interface MenuViewController ()

- (void) configureMenuModel;
- (void) callFSSRootMenuProxy;
- (void) loadViewController : (UIViewController *)viewController andAnimate : (BOOL)paramAnimate;
- (NSArray*) indexPathsForSection:(int)section
                 withNumberOfRows:(int)numberOfRows;
- (void) logoutUser;
- (void) customLogoutMenu : (int) menuIndex;
- (void) loadSubMenuOfSelectedMenu : (MenuModel *) paramMenuModel;
- (void) controlExpandCollapseBehaviorWithMenuModel : (MenuModel *) paramMenuModel;

@property (nonatomic, strong) NSMutableArray *menuModelArray;
@property (nonatomic, strong) NSMutableArray *menuDataArray;
@property (nonatomic, strong) NSMutableSet *collapsedSections;
@property (nonatomic, strong) RootFeedProxy *rootFeedProxy;
@property (nonatomic, assign) int tappedSection;
@property (nonatomic, assign) int totalRowInSection;
@property (nonatomic, assign) BOOL tableState;
@property (nonatomic, weak) IBOutlet UITableView *menuTableView;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation MenuViewController
@synthesize menuModelArray = _menuModelArray;
@synthesize menuDataArray = _menuDataArray;
@synthesize menuTableView = _menuTableView;
@synthesize collapsedSections = _collapsedSections;
@synthesize rootFeedProxy = _rootFeedProxy;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureMenuModel];
    
    /**
     callFSSRootMenuProxy is not calling, it is already called at LoginViewController for LoginAuthentication.
    
     [self callFSSRootMenuProxy];
     */
    [self getRootFssMenuDictionary:self.rootMenuDict];
    self.tableState = YES;
    
    NSLog(@"viewdidload @ menu");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private Method
- (void) configureMenuModel {
    
    //[self.menuTableView setBackgroundColor:[UIColor colorWithRed:39.0/255.0 green:38.0/255.0 blue:39.0/255.0 alpha:1.0]];
    //_menuTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [_menuTableView registerNib:[UINib nibWithNibName:@"MenuTableCustomHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"MenuCustomHeader"];
    
    /*
    [self.headerLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *headerLabelGesture = [[UITapGestureRecognizer alloc] init];
    headerLabelGesture.numberOfTapsRequired = 1;
    [headerLabelGesture addTarget:self
                    action:@selector(headerLabelGestureFired:)];
    [self.headerLabel addGestureRecognizer:headerLabelGesture];
    */
}

/*
- (void) headerLabelGestureFired :(UITapGestureRecognizer *)gestureRecognizer {
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromTop];
}
*/

//Not calling this webservice, can be removed this method after full verification
- (void) callFSSRootMenuProxy {
    
    if(![NetworkUtils hasNetworkConnection]) {
        [self.activityIndicatorView stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [UIUtils alertView:NETWORKERROR
                 withTitle:NETWORKTITLE];
    }
    else {
        [self.activityIndicatorView startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        _rootFeedProxy = [[RootFeedProxy alloc] init];
        _rootFeedProxy.rootFeedProxyDelegate = self;
        [_rootFeedProxy getFSSRootFeed];
    }
}

- (void) loadViewController : (UIViewController *)viewController
                 andAnimate : (BOOL)paramAnimate {
    
    ZUUIRevealController *revealController = [self.parentViewController isKindOfClass:[ZUUIRevealController class]] ?
    (ZUUIRevealController *)self.parentViewController : nil;
    
    UINavigationController *currentNavigationController = (UINavigationController *)revealController.frontViewController;
    
    [currentNavigationController popToRootViewControllerAnimated:NO];
    [currentNavigationController pushViewController:viewController animated:paramAnimate];
    
    revealController.currentFrontViewPosition = FrontViewPositionRight;
    [revealController revealToggle:self];
}

-(NSArray*) indexPathsForSection:(int)section withNumberOfRows:(int)numberOfRows {
    
    NSMutableArray* indexPaths = [NSMutableArray new];
    for (int i = 0; i < numberOfRows; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

- (void) logoutUser {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userEmail"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"loginStatus"];
    [defaults synchronize];
    
    [Cache cache].w3UserId = nil;
    [Cache cache].w3Password = nil;
    [Cache cache].loginStatus = NO;
    
    APPDELEGATE.window.rootViewController = [Cache cache].rootViewController;
    [APPDELEGATE.window makeKeyAndVisible];
    
    [Cache clearCookie];

}

- (void) customLogoutMenu : (int) menuIndex {
    //Logout Menu
    MenuModel *logoutMenuModel = [[MenuModel alloc] initWithMenu:[NSString stringWithFormat:@"%d",menuIndex]
                                                     andMenuName:@"zLogout"
                                              andMenuDisplayName:@"Logout"];
    
    [_menuModelArray addObject:logoutMenuModel];
    [_collapsedSections addObject:@([[NSString stringWithFormat:@"%@",logoutMenuModel.menuId] intValue])];
    
    NSDictionary *subMenuDict = [NSDictionary dictionaryWithObjectsAndKeys:@[],@"Logout", nil];
    
    [_menuDataArray addObject:subMenuDict];
}

/**
 Method would be called when loading Menu from Top. not from Left.
 */
- (void) loadSubMenuOfSelectedMenu : (MenuModel *) paramMenuModel {
    
    NSString *key = [NSString stringWithFormat:@"%@",paramMenuModel.menuDisplayName];
    //NSDictionary *menuDict = [_menuDataArray objectAtIndex:[[NSString stringWithFormat:@"%@",paramMenuModel.menuId] intValue]];
//    NSArray *subMenuArray = [menuDict objectForKey:key];
    
//    [self dismissModalViewControllerWithPushDirection:kCATransitionFromTop];
//    if(self.menuViewControllerDelegate && [self.menuViewControllerDelegate conformsToProtocol:@protocol(MenuViewControllerDelegate)]) {
//        [self.menuViewControllerDelegate loadSelectedFSSNewsLetter:paramMenuModel.menuDisplayName
//                                                   andSubMenuArray:subMenuArray];
//    }
    
    
    if([paramMenuModel.menuDisplayName isEqualToString:@"Logout"]) {
        [self logoutUser];
    } else{
        UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                                 bundle:nil];
        MenuDetailViewController *menuDetailViewController = (MenuDetailViewController *)[rootStoryboard instantiateViewControllerWithIdentifier:MenuDetailViewControllerIdentifier];
        
        menuDetailViewController.viewIdentifier = key;
        //newsReaderViewController.viewIdentifier = subMenuModel.subMenuDisplayName;
        [self loadViewController:menuDetailViewController andAnimate:YES];
    }
}

/*
 Method would be called to control expand and collapse behavior of MenuTable
 */
- (void) controlExpandCollapseBehaviorWithMenuModel : (MenuModel *) paramMenuModel {
    
    [_menuTableView beginUpdates];
    
    int section = [[NSString stringWithFormat:@"%@",paramMenuModel.menuId] intValue];
    int numOfRows = 0;
    BOOL shouldCollapse = ![_collapsedSections containsObject:@(section)];
    
    //collapse the table, previously expanded section
    if(self.tableState == NO ) {
        shouldCollapse = YES;
    }
    
    if(shouldCollapse) {
        numOfRows = (int)[_menuTableView numberOfRowsInSection:section];//2;
        NSArray *indexPath = [self indexPathsForSection:section
                                       withNumberOfRows:numOfRows];
        [_menuTableView deleteRowsAtIndexPaths:indexPath
                              withRowAnimation:UITableViewRowAnimationTop];
        [_collapsedSections addObject:@(section)];
        
    } else {
        
        for(id key in [_menuDataArray objectAtIndex:section]){
            numOfRows = (int)[[[_menuDataArray objectAtIndex:section] objectForKey:key] count];
        }
        
        NSArray *indexPath = [self indexPathsForSection:section
                                       withNumberOfRows:numOfRows];
        [_menuTableView insertRowsAtIndexPaths:indexPath
                              withRowAnimation:UITableViewRowAnimationTop];
        [_collapsedSections removeObject:@(section)];
        
        self.tappedSection = section;
        self.totalRowInSection = numOfRows;
        self.tableState = shouldCollapse;
        
    }
    
    [_menuTableView endUpdates];
    [_menuTableView reloadData];
    
    if(numOfRows == 0) {
        MenuModel *menuModel = (MenuModel *)[_menuModelArray objectAtIndex:section];
        SubMenuModel *subMenuModel = [[SubMenuModel alloc] init];
        subMenuModel.subMenuDisplayName = [NSString stringWithFormat:@"%@",menuModel.menuDisplayName];
        if([menuModel.menuDisplayName isEqualToString:@"Logout"])
            //logout
            [self logoutUser];
        else
            [self getSubMenuModel:subMenuModel];
        
    }
}

#pragma mark
#pragma mark RootFeedProxy Delegate Method

- (void) getRootFssMenuDictionary : (NSMutableDictionary *)rootFssDict {
        
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    int count = 0;
    _menuModelArray = [[NSMutableArray alloc] init];
    _menuDataArray = [[NSMutableArray alloc] init];
    _collapsedSections = [NSMutableSet new];
    
    [self.headerLabel setText:[NSString stringWithFormat:@"%@",[[rootFssDict allKeys] count] > 0 ? [Cache cache].fssHeader : kDefaultListTitle]];
    
    for(id key in rootFssDict) {
        //Menu Model
        MenuModel *menuModel = [[MenuModel alloc] initWithMenu:[NSString stringWithFormat:@"%d",count]
                                                   andMenuName:[NSString stringWithFormat:@"%@",key]
                                            andMenuDisplayName:[NSString stringWithFormat:@"%@",key]];
        
        [_menuModelArray addObject:menuModel];
        [_collapsedSections addObject:@([[NSString stringWithFormat:@"%@",menuModel.menuId] intValue])];
        
        //Sub Menu
        int subMenuCount = 0;
        NSMutableArray *subMenuArray = [[NSMutableArray alloc] init];
        for(NSString *subMenuTitle in [rootFssDict objectForKey:key]){
            SubMenuModel *subMenuModel = [[SubMenuModel alloc] initWithSubMenuModel:[NSString stringWithFormat:@"%d",count] andSubMenuId:[NSString stringWithFormat:@"%d",subMenuCount]
                                            andSubMenuName:[NSString stringWithFormat:@"%@",subMenuTitle]
                                    andSubMenuDisplayName:[NSString stringWithFormat:@"%@",subMenuTitle]];
            
            [subMenuArray addObject:subMenuModel];
            subMenuCount++;
        }
        NSDictionary *subMenuDict = [NSDictionary dictionaryWithObjectsAndKeys:subMenuArray,key, nil];
        
        [_menuDataArray addObject:subMenuDict];
        
        count++;
    }
    [self customLogoutMenu:count];
    [_menuTableView reloadData];
    
    //navigate on 1st menu detail.
    /*
    if([_menuModelArray count] > 1) {
        MenuModel *firstIndexMenuModel = (MenuModel *)[_menuModelArray objectAtIndex:0];
       
        UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                                 bundle:nil];
        NewsReaderViewController *newsReaderViewController = [rootStoryboard instantiateViewControllerWithIdentifier:NewsReaderViewControllerIdentifier];
        newsReaderViewController.viewIdentifier = firstIndexMenuModel.menuDisplayName;
        
        [self loadViewController:newsReaderViewController andAnimate:NO];

    }
    */
    
}

//remove this method, not using any proxy
- (void) rootFssFail : (NSString *)error {
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [UIUtils alertView:error
             withTitle:@""];
    [self logoutUser];
}

#pragma mark
#pragma mark TableView DataSource Method

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_menuDataArray count];
}
*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //Expand collapse behavior is not required as per new UI. Disable this code and return 0 row for each section.
    /*
    NSDictionary *subMenuDict = [_menuDataArray objectAtIndex:section];
    NSString *key = [NSString stringWithFormat:@"%@",[[subMenuDict allKeys] objectAtIndex:0]];
    NSInteger rowCount  = [[subMenuDict objectForKey:key] count];
    
    return [_collapsedSections containsObject:@(section)] ? 0 : rowCount;
    */
    return [_menuDataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0;
}
*/

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MenuTableCustomHeader *menuCustomHeader = [tableView dequeueReusableCellWithIdentifier:@"MenuCustomHeader"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"menuDisplayName" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedMenuArray = [_menuModelArray sortedArrayUsingDescriptors:descriptors];
    _menuModelArray = (NSMutableArray *) sortedMenuArray;
   
    
    MenuModel *menuModel = [_menuModelArray objectAtIndex:section];
    
    NSString *rootMenuString = [NSString stringWithFormat:@"%@",menuModel.menuDisplayName];
    
    @try {
        rootMenuString = [rootMenuString stringByReplacingOccurrencesOfString:@"-"
                                                                   withString:@" "];
        rootMenuString = [rootMenuString stringByReplacingOccurrencesOfString:@"Q1"
                                                                   withString:@""];
        rootMenuString = [rootMenuString stringByReplacingOccurrencesOfString:@"2015"
                                                                   withString:@""];
        
        if([rootMenuString containsString:@"Business"]){
            [menuCustomHeader.headerImageView setImage:[UIImage imageNamed:@"business"]];
        }else if([rootMenuString containsString:@"Clients"]){
            [menuCustomHeader.headerImageView setImage:[UIImage imageNamed:@"client"]];
        }else if ([rootMenuString containsString:@"Industry Leaders"]){
            [menuCustomHeader.headerImageView setImage:[UIImage imageNamed:@"leader"]];
        }else if ([rootMenuString containsString:@"People"]){
            [menuCustomHeader.headerImageView setImage:[UIImage imageNamed:@"people"]];
        }
        
        [menuCustomHeader setHeaderText:[NSString stringWithFormat:@"%@",rootMenuString]];
        
    }
    @catch (NSException *exception) {
        [menuCustomHeader setHeaderText:[NSString stringWithFormat:@"%@",menuModel.menuDisplayName]];
    }
    @finally {
        
    }
    
    menuCustomHeader.menuModel = menuModel;
    menuCustomHeader.menuCustomDelegate = self;
    
    return menuCustomHeader;

}
*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    NSString *cellIdentifier = @"MenuCustomCell";
    MenuCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                           forIndexPath:indexPath];

    NSDictionary *menuDict = [_menuDataArray objectAtIndex:[indexPath section]];
    MenuModel *menuModel = (MenuModel *)[_menuModelArray objectAtIndex:[indexPath section]];
    NSString *key = [NSString stringWithFormat:@"%@",menuModel.menuDisplayName];
    NSArray *menuArray = [menuDict objectForKey:key];
    
    SubMenuModel *subMenuModel = (SubMenuModel *)[menuArray objectAtIndex:indexPath.row];
    
    NSString *subMenuString = [NSString stringWithFormat:@"%@",subMenuModel.subMenuDisplayName];
    
    @try {
        
        
        subMenuString = [subMenuString stringByReplacingOccurrencesOfString:@"-"
                                                                   withString:@" "];
        subMenuString = [subMenuString stringByReplacingOccurrencesOfString:@"Q1"
                                                                   withString:@""];
        subMenuString = [subMenuString stringByReplacingOccurrencesOfString:@"2015"
                                                                   withString:@""];
        
        cell.menuLabel.text = [NSString stringWithFormat:@"%@",subMenuString];
        
    }
    @catch (NSException *exception) {
        cell.menuLabel.text = [NSString stringWithFormat:@"%@",subMenuModel.subMenuDisplayName];
    }
    @finally {    }
    
    cell.subMenuModel = subMenuModel;
    cell.menuCustomDelegate = self;
    [cell setBackgroundColor:[UIColor clearColor]];

    return cell;
    */
    
    MenuTableCustomHeader *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCustomHeader"
                                                                  forIndexPath:indexPath];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"menuName"
                                                                     ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedMenuArray = [_menuModelArray sortedArrayUsingDescriptors:descriptors];
    _menuModelArray = (NSMutableArray *) sortedMenuArray;
    
    
    MenuModel *menuModel = [_menuModelArray objectAtIndex:indexPath.row];
    
    NSString *rootMenuString = [NSString stringWithFormat:@"%@",menuModel.menuDisplayName];
    
    @try {
        rootMenuString = [rootMenuString stringByReplacingOccurrencesOfString:@"-"
                                                                   withString:@" "];
        rootMenuString = [rootMenuString stringByReplacingOccurrencesOfString:@"Q1"
                                                                   withString:@""];
        rootMenuString = [rootMenuString stringByReplacingOccurrencesOfString:@"2015"
                                                                   withString:@""];
        
        
        if([Cache checkDeviceOSVersion] < 8.0){
            
            if([rootMenuString rangeOfString:@"Business"].location != NSNotFound) {
                [cell.headerImageView setImage:[UIImage imageNamed:@"business"]];
            } else if([rootMenuString rangeOfString:@"Clients"].location != NSNotFound) {
                [cell.headerImageView setImage:[UIImage imageNamed:@"client"]];
            } else if([rootMenuString rangeOfString:@"Industry"].location != NSNotFound) {
                [cell.headerImageView setImage:[UIImage imageNamed:@"leader"]];
            } else if([rootMenuString rangeOfString:@"People"].location != NSNotFound) {
                [cell.headerImageView setImage:[UIImage imageNamed:@"people"]];
            } else if([rootMenuString rangeOfString:@"Logout"].location != NSNotFound) {
                [cell.headerImageView setImage:[UIImage imageNamed:@"logout"]];
            } else {
                [cell.headerImageView setImage:[UIImage imageNamed:@"defaultMenu"]];
            }
        }else {
            if([rootMenuString containsString:@"Business"]){
                [cell.headerImageView setImage:[UIImage imageNamed:@"business"]];
            } else if([rootMenuString containsString:@"Clients"]){
                [cell.headerImageView setImage:[UIImage imageNamed:@"client"]];
            } else if ([rootMenuString containsString:@"Industry Leaders"]){
                [cell.headerImageView setImage:[UIImage imageNamed:@"leader"]];
            } else if ([rootMenuString containsString:@"People"]){
                [cell.headerImageView setImage:[UIImage imageNamed:@"people"]];
            } else if ([rootMenuString containsString:@"Logout"]){
                [cell.headerImageView setImage:[UIImage imageNamed:@"logout"]];
            } else {
                [cell.headerImageView setImage:[UIImage imageNamed:@"defaultMenu"]];
            }
        }
        
        [cell setHeaderText:[NSString stringWithFormat:@"%@",rootMenuString]];
        
    }
    @catch (NSException *exception) {
        [cell setHeaderText:[NSString stringWithFormat:@"%@",menuModel.menuDisplayName]];
    }
    @finally {
        
    }
    
    cell.menuModel = menuModel;
    cell.menuCustomDelegate = self;
    
    return cell;
}

#pragma mark
#pragma mark TableView Delegate method
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuDict = [_menuDataArray objectAtIndex:[indexPath section]];
    NSLog(@"MenuDict ; %@",menuDict);
}

#pragma mark
#pragma mark SubMenuCustomDelegate Method
-(void)getSubMenuModel : (SubMenuModel *)subMenuModel {

    self.tableState = YES;
    [_menuTableView beginUpdates];
    
    int numOfRows = (int)[_menuTableView numberOfRowsInSection:self.tappedSection];//2;
    NSArray *indexPath = [self indexPathsForSection:self.tappedSection
                                   withNumberOfRows:numOfRows];
    [_menuTableView deleteRowsAtIndexPaths:indexPath
                          withRowAnimation:UITableViewRowAnimationTop];
    [_collapsedSections addObject:@(self.tappedSection)];
    
    [_menuTableView endUpdates];
    [_menuTableView reloadData];
    
    //New UINavigation as per discussion with Vijay and Manoj @ 22nd July when menu is at top (top to down). Dont use this commented code. Its is based on presentionViewController
    /*
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromTop];
    if(self.menuViewControllerDelegate && [self.menuViewControllerDelegate conformsToProtocol:@protocol(MenuViewControllerDelegate)]) {
        [self.menuViewControllerDelegate loadSelectedFSSNewsLetter:subMenuModel.subMenuDisplayName];
    }
     */
    
     //call this code, it is based on reveal
     
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    NewsReaderViewController *newsReaderViewController = [rootStoryboard instantiateViewControllerWithIdentifier:NewsReaderViewControllerIdentifier];
    newsReaderViewController.viewIdentifier = subMenuModel.subMenuDisplayName;

    [self loadViewController:newsReaderViewController andAnimate:YES];
    
}

#pragma mark
#pragma mark MenuModelDelegate Method

-(void)getMenuModel : (MenuModel *)menuModel {
    
    //get subMenu Array of the selected Menu and pass to SubMenuViewcontroller and dismiss menuViewController
   
     //disable the expand and collpase behaviour of tableView as per new UI discussion with Vijay and Manoj.
     [self loadSubMenuOfSelectedMenu:menuModel];
    
    
    /**
     controlExpandCollapseBehaviorWithMenuModel used to enable expand and collapase behaviour of tableView
     */
    //Left side menu is confirmed from Vijay and Manoj at 27th July as per discussion
    
    //[self controlExpandCollapseBehaviorWithMenuModel:menuModel];
    
}

#pragma mark
#pragma mark ZUUIRevealControllerDelegate Protocol.
/*
 * All of the methods below are optional. You can use them to control the behavior of the ZUUIRevealController,
 * or react to certain events.
 */
- (BOOL)revealController:(ZUUIRevealController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController
{
    return YES;
}

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController
{
    return YES;
}
- (void)revealController:(ZUUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{
    if ([Cache cache].touchIntercepterView!=nil) {
        [[Cache cache].touchIntercepterView removeFromSuperview];
    }
    UIView *temptouchIntercepterView = [[UIView alloc] initWithFrame:revealController.frontViewController.view.frame];
    [Cache cache].touchIntercepterView = temptouchIntercepterView;
    //[[Cache cache].touchIntercepterView  setBackgroundColor:[UIColor redColor]];
    
    SEL gestureSelector = sel_registerName(REVEALGESTURE);
    SEL toggleSelector = sel_registerName(REVEALTOGGLE);
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:toggleSelector];
    [[Cache cache].touchIntercepterView addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:revealController action:gestureSelector];
    [[Cache cache].touchIntercepterView addGestureRecognizer:panGestureRecognizer];
    
    [revealController.frontViewController.view addSubview:[Cache cache].touchIntercepterView];
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{
    if  ([Cache cache].touchIntercepterView ==nil)
    {
        NSLog(@" because of memory leak gesture object release");
    }
    [[Cache cache].touchIntercepterView removeFromSuperview];
    
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willRevealRearViewController:(UIViewController *)rearViewController
{
    if ([Cache cache].touchIntercepterView!=nil) {
        [[Cache cache].touchIntercepterView removeFromSuperview];
    }
    UIView *temptouchIntercepterView = [[UIView alloc] initWithFrame:revealController.frontViewController.view.frame];
    [Cache cache].touchIntercepterView = temptouchIntercepterView;
    
    //    [[Cache cache].touchIntercepterView  setBackgroundColor:[UIColor redColor]];
    SEL gestureSelector = sel_registerName(REVEALGESTURE);
    SEL toggleSelector = sel_registerName(REVEALTOGGLE);
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:toggleSelector];
    [[Cache cache].touchIntercepterView addGestureRecognizer:tapGestureRecognizer];
    
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:revealController action:gestureSelector];
    [[Cache cache].touchIntercepterView addGestureRecognizer:panGestureRecognizer];
    
    [revealController.frontViewController.view addSubview:[Cache cache].touchIntercepterView];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willHideRearViewController:(UIViewController *)rearViewController
{
    if  ([Cache cache].touchIntercepterView ==nil) {
        NSLog(@" because of memory leak gesture object release");
    }
    [[Cache cache].touchIntercepterView removeFromSuperview];
    
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
@end
