//
//  NewsReaderViewController.m
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "NewsReaderViewController.h"
#import "ZUUIRevealController.h"
#import "MenuViewController.h"
#import "UIViewController+Transitions.h"

static NSString *const kDefaultTitle = @"";//@"IBM FSS News Letter";
static NSString *const kDefaultLinkTapAlertMessage = @"Hyperlink is not accessable.";
static NSString *const kDefaultLinkTapAlertTitle = @"Access Denied";


@interface NewsReaderViewController ()

- (void) configureViewGesture;
- (void) loadDefaultWelcomePage;
- (void) callPeopleNewsFSSReaderService;
- (void) presentMenuViewController;
- (void) slideNewsReaderViewController;
- (void) handelViewTitleWithTitleString : (NSString *)paramTitleIdentifier;

@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIWebView *fssWebView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) PeopleProxy *peopleProxy;
@property (nonatomic, strong) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

@end

@implementation NewsReaderViewController
@synthesize navigationBarPanGestureRecognizer = _navigationBarPanGestureRecognizer;
@synthesize viewIdentifier = _viewIdentifier;
@synthesize peopleProxy = _peopleProxy;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViewGesture];
    
    if ([_viewIdentifier length] > 0) {
        [self callPeopleNewsFSSReaderService];
    }else {
        [self loadDefaultWelcomePage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Method

- (void) loadDefaultWelcomePage {
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.fssWebView loadHTMLString:htmlString baseURL:nil];
}

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
            _navigationBarPanGestureRecognizer = panGestureRecognizer;
            
            [self.view addGestureRecognizer:_navigationBarPanGestureRecognizer];
        }
    }
    NSString *headerTitle = [NSString stringWithFormat:@"%@",([_viewIdentifier length] > 0)? _viewIdentifier : kDefaultTitle];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"-"
                                                             withString:@" "];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"Q1"
                                                             withString:@""];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"2015"
                                                             withString:@""];
    [self.headerLabel setText:[NSString stringWithFormat:@"%@",([headerTitle length] > 0)? headerTitle : kDefaultTitle]];

    //[self.menuButton setFrame:CGRectMake(8, 20, 37, 30)];
    [self.headerLabel setFont:[UIFont fontWithName:HeaderFont size:15.0]];
}

- (void) callPeopleNewsFSSReaderService {

    if(![NetworkUtils hasNetworkConnection]) {
        [self.activityIndicatorView stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [UIUtils alertView:NETWORKERROR
                 withTitle:NETWORKTITLE];
    }
    else {
        [self.activityIndicatorView startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        _peopleProxy = [[PeopleProxy alloc] init];
        _peopleProxy.peopleProxyDelegate = self;
        [_peopleProxy getNewsFSSDataWithPageIdentifer:[NSString stringWithFormat:@"%@",_viewIdentifier]];
    }
    
}

- (void) presentMenuViewController {
    
    [APPDELEGATE.navigationController popViewControllerAnimated:YES];
    
    /*
     //Not to use this code on NewReaderViewController. Its already implemented on SubMenuViewController.
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    MenuViewController *menuViewController = [rootStoryboard instantiateViewControllerWithIdentifier:MenuViewControllerIdentifier];
    menuViewController.rootMenuDict = self.rootMenuDict;
    menuViewController.menuViewControllerDelegate = self;
    
    [self presentModalViewController:menuViewController
                   withPushDirection:kCATransitionFromBottom];
    */
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

- (void) handelViewTitleWithTitleString : (NSString *)paramTitleIdentifier {

    _viewIdentifier = [NSString stringWithFormat:@"%@",paramTitleIdentifier];
    NSString *headerTitle = [NSString stringWithFormat:@"%@",([_viewIdentifier length] > 0)? _viewIdentifier : kDefaultTitle];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"-"
                                                         withString:@" "];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"Q1"
                                                         withString:@""];
    headerTitle = [headerTitle stringByReplacingOccurrencesOfString:@"2015"
                                                         withString:@""];
    [self.headerLabel setText:[NSString stringWithFormat:@"%@",([headerTitle length] > 0)? headerTitle : kDefaultTitle]];
}

#pragma mark
#pragma mark MenuViewController Delegate Method
- (void) loadSelectedFSSNewsLetter : (NSString *)paramFSSNewsLetterIdentifier {
    
    [self handelViewTitleWithTitleString:paramFSSNewsLetterIdentifier];
    [self.fssWebView loadHTMLString:@"" baseURL:nil];
    [self callPeopleNewsFSSReaderService];
}

#pragma mark
#pragma mark PeoppleProxy Delegate Method
-(void) getPeopleFSSReader : (PeopleModel *)peopleModel {
    
    [self.activityIndicatorView stopAnimating];
    
    [self.fssWebView setDelegate:self];
    [self.fssWebView loadHTMLString:peopleModel.peopleSummery
                       baseURL:nil];
    [self.fssWebView setScalesPageToFit:YES];
    [self.fssWebView setDataDetectorTypes:UIDataDetectorTypeNone];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        return false;
    }
    return !(navigationType == UIWebViewNavigationTypeLinkClicked);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView1{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [webView1 stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '250%'"];
    [webView1 setDataDetectorTypes:UIDataDetectorTypeNone];
}

- (void) peopleDidFail : (NSString *)errorMessage {
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [UIUtils alertView:errorMessage
             withTitle:@""];
}

#pragma mark
#pragma mark Event Handler method

-(IBAction)newsReaderButtonTapped:(id)sender {
    
    if([sender isEqual:self.menuButton])
    {
        /**
         //No need of this method as per new UI discussion with Vijay and Manoj.
        [self slideNewsReaderViewController];
         */
        [self presentMenuViewController];
    }
}

@end
