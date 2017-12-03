//
//  SubMenuViewController.m
//  IBMFSSNewsLetter
//
//  Created by Rohit on 24/07/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "SubMenuViewController.h"
#import "NewsReaderViewController.h"

@interface SubMenuViewController ()

- (void) configureSubMenuView;
- (void) loadDefaultWelcomePage;
- (void) presentMenuViewController;
- (void) handelViewTitleWithTitleString : (NSString *)paramTitleIdentifier;
- (void) callPeopleNewsFSSReaderServiceWithPageIdentifier : (NSString *)paramPageLabelIdentifier;
- (void) callFSSSubMenuProxyWithParentIdentifier : (NSString *) paramParentIdentifier;

@property (nonatomic, weak) IBOutlet UITableView *subMenuTableView;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIWebView *fssDefaultWebiew;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSMutableArray *subMenuArray;
@property (nonatomic, strong) NSMutableArray *subMenuHTMLDescriptionArray;
@property (nonatomic, strong) NSMutableArray *tempSubMenuArray;
@property (nonatomic, strong) PeopleProxy *peopleProxy;
@property (nonatomic, strong) SubMenuProxy *subMenuProxy;
@property (nonatomic, strong) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;


@end

@implementation SubMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureSubMenuView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Method

- (void) configureSubMenuView {
 
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
            _navigationBarPanGestureRecognizer = panGestureRecognizer;
            
            [self.view addGestureRecognizer:_navigationBarPanGestureRecognizer];
        }
    }
    
    [self.subMenuTableView registerNib:[UINib nibWithNibName:@"MenuTableCustomHeader" bundle:nil]forHeaderFooterViewReuseIdentifier:@"MenuTableHeaderIdentifier"];
    [self.subMenuTableView setBackgroundColor:[UIColor clearColor]];
    //[self.subMenuTableView setBackgroundColor:[UIColor colorWithRed:39.0/255.0 green:38.0/255.0 blue:39.0/255.0 alpha:1.0]];

    [self loadDefaultWelcomePage];

}

- (void) loadDefaultWelcomePage {
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    [self.fssDefaultWebiew loadHTMLString:htmlString baseURL:nil];
    
}

- (void) presentMenuViewController {
    
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    MenuViewController *menuViewController = [rootStoryboard instantiateViewControllerWithIdentifier:MenuViewControllerIdentifier];
    menuViewController.rootMenuDict = self.rootMenuDict;
    menuViewController.menuViewControllerDelegate = self;
    
    [self presentModalViewController:menuViewController
                   withPushDirection:kCATransitionFromBottom];
    
   /*
    [APPDELEGATE.window addSubview:menuViewController.view];
    CGRect menuViewFrame = menuViewController.view.frame;
    menuViewFrame.origin.y -= [UIScreen mainScreen].bounds.size.height;
    menuViewController.view.frame = menuViewFrame;
    
    [UIView animateWithDuration:0.9f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect menuViewFrame = menuViewController.view.frame;
                         menuViewFrame.origin.y += menuViewFrame.size.height;
                         menuViewController.view.frame = menuViewFrame;

                     } completion:^(BOOL finished){
                         NSLog(@"completed");
                     }];
    */
    
}

- (void) handelViewTitleWithTitleString : (NSString *)paramTitleIdentifier {
    
    NSString *headerTitle = [NSString stringWithFormat:@"%@",([paramTitleIdentifier length] > 0)? paramTitleIdentifier : @""];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"-"
                                                         withString:@" "];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"Q1"
                                                         withString:@""];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"2015"
                                                         withString:@""];
    [self.headerLabel setText:[NSString stringWithFormat:@"%@",([headerTitle length] > 0)? headerTitle : @""]];
}

- (void) callPeopleNewsFSSReaderServiceWithPageIdentifier : (NSString *)paramPageLabelIdentifier {

    if(![NetworkUtils hasNetworkConnection]) {
        [self.activityIndicatorView stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [UIUtils alertView:NETWORKERROR
                 withTitle:NETWORKTITLE];
    }
    else {
        [self.activityIndicatorView startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.peopleProxy = [[PeopleProxy alloc] init];
        self.peopleProxy.peopleProxyDelegate = self;
        [self.peopleProxy getNewsFSSDataWithPageIdentifer:[NSString stringWithFormat:@"%@",paramPageLabelIdentifier]];
    }
    
}

- (void) callFSSSubMenuProxyWithParentIdentifier : (NSString *) paramParentIdentifier {
    
    if(![NetworkUtils hasNetworkConnection]) {
        [self.activityIndicatorView stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [UIUtils alertView:NETWORKERROR
                 withTitle:NETWORKTITLE];
    }
    else {
        [self.activityIndicatorView startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.subMenuProxy = [[SubMenuProxy alloc] init];
        self.subMenuProxy.subMenuProxyDelegate = self;
        [self.subMenuProxy getNewsFSSSubMenuWithPageIdentifier:[NSString stringWithFormat:@"%@",paramParentIdentifier]];
    }

}

#pragma mark
#pragma mark MenuViewController Delegate Method

- (void) loadSelectedFSSNewsLetter : (NSString *)paramFSSNewsLetterIdentifier
                   andSubMenuArray : (NSArray *) paramSubMenuArray; {

    if([paramFSSNewsLetterIdentifier isEqualToString:[Cache cache].fssHeader]) {
        [self.fssDefaultWebiew setHidden:NO];
        [self loadDefaultWelcomePage];
    }else {
        [self handelViewTitleWithTitleString:paramFSSNewsLetterIdentifier];
        //self.subMenuArray = (NSMutableArray *) paramSubMenuArray;
        self.tempSubMenuArray = (NSMutableArray *) paramSubMenuArray;

        if([paramSubMenuArray count] == 0) {
            [self.fssDefaultWebiew setHidden:NO];
            [self.fssDefaultWebiew loadHTMLString:@""
                                          baseURL:nil];
            [self callPeopleNewsFSSReaderServiceWithPageIdentifier:paramFSSNewsLetterIdentifier];
        }else {
            self.subMenuArray = nil;
            [self.subMenuTableView reloadData];
            [self.fssDefaultWebiew setHidden:YES];
            [self callFSSSubMenuProxyWithParentIdentifier:paramFSSNewsLetterIdentifier];
        }

    }
}

#pragma mark
#pragma mark PeoppleProxy Delegate Method

-(void) getPeopleFSSReader : (PeopleModel *)peopleModel {
    
    [self.activityIndicatorView stopAnimating];
    
    [self.fssDefaultWebiew loadHTMLString:peopleModel.peopleSummery
                            baseURL:nil];
    [self.fssDefaultWebiew setScalesPageToFit:YES];
    [self.fssDefaultWebiew setDataDetectorTypes:UIDataDetectorTypeNone];
    
}

- (void) peopleDidFail : (NSString *)errorMessage {
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [UIUtils alertView:errorMessage
             withTitle:@""];
}

#pragma mark
#pragma mark SubMenuProxy Delegate Method
- (void) loadSubMenuFromParent : (NSMutableArray *)paramSubMenuArray {
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.subMenuArray = self.tempSubMenuArray;

    
    //Design SubMenuModel based on <p>
    self.subMenuHTMLDescriptionArray = [NSMutableArray array];
    NSMutableArray *tempSubMenuArray = [NSMutableArray array];
    for(NSMutableArray *subMenuTagArray in  paramSubMenuArray) {
        
        if([subMenuTagArray count] == 1 || [subMenuTagArray count] == 2 || [subMenuTagArray count] == 3){
            SubMenuModel *subMenuModel = [[SubMenuModel alloc] initWithSubMenuModelWithHTML:[subMenuTagArray firstObject]
                                                                 andSubMenuHTMLDisplayTitle:[subMenuTagArray lastObject]];
 
            [self.subMenuHTMLDescriptionArray addObject:subMenuModel];
        }else if( [subMenuTagArray count] > 1 ){
            self.subMenuHTMLDescriptionArray = subMenuTagArray;
        }
    }
    
    //make subMenuHTML
    NSString *className = NSStringFromClass([[self.subMenuHTMLDescriptionArray firstObject] class]);
    NSLog(@"class : %@",className);
    if([[self.subMenuHTMLDescriptionArray firstObject] class] != [SubMenuModel class] && className != nil)
    {
        for(SubMenuModel *subMenuModel in self.subMenuArray) {
        
            int tagIndex = 0;
            for(NSString *tagsValue in self.subMenuHTMLDescriptionArray) {
                NSArray *tagsStringArray = [tagsValue componentsSeparatedByString:@". "];
                
                if([tagsStringArray count] > 1)
                {
                    BOOL tagMatched = NO;
                    NSString *subMenuTagString= [tagsStringArray lastObject];
                    if([subMenuModel.subMenuDisplayName containsString:subMenuTagString]) {
                        NSLog(@"Matched");
                        tagMatched = YES;
                    }
                    if(tagMatched)
                    {
                        //Add next index data to the array when matched.
                        int tempIndex = tagIndex;
                        NSString *nextTagString = [self.subMenuHTMLDescriptionArray objectAtIndex:tempIndex+1];
                        SubMenuModel *subMenuModel = [[SubMenuModel alloc] initWithSubMenuModelWithHTML:nextTagString
                                                                             andSubMenuHTMLDisplayTitle:nextTagString];
                        
                        [tempSubMenuArray addObject:subMenuModel];
                        tagMatched = NO;
                        break;
                    }
                }
                tagIndex++;
            }
        }
        self.subMenuHTMLDescriptionArray = tempSubMenuArray;
    }
    
   // if([tempSubMenuArray count] != 0){
   // }
    
    for(SubMenuModel *submenumodel in self.subMenuHTMLDescriptionArray){
        NSLog(@"submenu Title : %@",submenumodel.subMenuHTMLTitle);
        NSLog(@"SubMenu Descr : %@",submenumodel.subMenuHTMLDisplayTitle);
    }
    
    [self.subMenuTableView reloadData];
}

- (void) subMenuDidFail : (NSString *) paramError {
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [UIUtils alertView:paramError withTitle:@""];

}

#pragma mark
#pragma mark UIWebView Delegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType: (UIWebViewNavigationType)navigationType {
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        return false;
    }
    return !(navigationType == UIWebViewNavigationTypeLinkClicked);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '270%'"];
    [webView setDataDetectorTypes:UIDataDetectorTypeNone];
}

#pragma mark
#pragma mark UITableView DataSource Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 106.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.subMenuArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"MenuCustomCell";
    MenuCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                           forIndexPath:indexPath];
    
    SubMenuModel *subMenuModel = (SubMenuModel *)[self.subMenuArray objectAtIndex:indexPath.row];
    
    NSString *subMenuString = [NSString stringWithFormat:@"%@",subMenuModel.subMenuDisplayName];
    NSString *subMenuHTML = @"";
    @try {
        SubMenuModel *subMenuHTMLDescriptionModel = (SubMenuModel *)[self.subMenuHTMLDescriptionArray objectAtIndex:indexPath.row];
        subMenuHTML = [NSString stringWithFormat:@"%@",subMenuHTMLDescriptionModel.subMenuHTMLDisplayTitle];

    }
    @catch (NSException *exception) {
        [UIUtils alertView:@"Error occured. Try again."
                 withTitle:@"Error"];
    }
    @finally { }
    
    @try {
        
        subMenuString = [subMenuString stringByReplacingOccurrencesOfString:@"-"
                                                                 withString:@" "];
        subMenuString = [subMenuString stringByReplacingOccurrencesOfString:@"Q1"
                                                                 withString:@""];
        subMenuString = [subMenuString stringByReplacingOccurrencesOfString:@"2015"
                                                                 withString:@""];
        subMenuHTML = [subMenuHTML stringByReplacingOccurrencesOfString:@"&nbsp;"
                                                             withString:@" "];
        
        cell.menuLabel.text = [NSString stringWithFormat:@"%@",subMenuString];
        cell.menuDetailLabel.text = [NSString stringWithFormat:@"%@",subMenuHTML];
        
    }
    @catch (NSException *exception) {
        cell.menuLabel.text = [NSString stringWithFormat:@"%@",subMenuModel.subMenuDisplayName];
    }
    @finally {    }
    
    cell.subMenuModel = subMenuModel;
    cell.menuCustomDelegate = self;
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

#pragma mark
#pragma mark TableView Delegate method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { }

#pragma mark
#pragma mark SubMenuCustom Delegate Method

-(void)getSubMenuModel : (SubMenuModel *)subMenuModel {
    //Navigate to the detail View on newsReaderViewController
    
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    NewsReaderViewController *newsReaderViewController = [rootStoryboard instantiateViewControllerWithIdentifier:NewsReaderViewControllerIdentifier];
    newsReaderViewController.viewIdentifier = subMenuModel.subMenuDisplayName;
    [APPDELEGATE.navigationController pushViewController:newsReaderViewController
                                                animated:YES];
}

#pragma mark
#pragma mark Button Tappped Method

- (IBAction)subMenuButtonTapped:(id)sender {
    if([sender isEqual:self.menuButton]) {
        //[self presentMenuViewController];
        [self slideNewsReaderViewController];
    }
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
@end
