//
//  LoginViewController.m
//  IBMFSSReader
//
//  Created by Rohit on 15/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "LoginViewController.h"
#import "MenuViewController.h"
#import "MenuDetailViewController.h"

#import "NewsReaderViewController.h"
#import "SubMenuViewController.h"

static NSString *const kHeaderTitle = @"IBM FSS\nNEWS LETTER";
static NSString *const kInvalidLogin = @"Please enter w3 interanet id and password.";
static NSString *const kInvalidAccess = @"Please enter correct w3 interanet id and password.";

@interface LoginViewController ()

- (void) configureView;
- (void) processUserLogin;
- (void) checkNetworkAndValidateLogin;
- (void) rememberUserLogin : (id)sender;
- (void) getUserAccess;
- (void) saveUserAccess;
- (void) clearUserAccess;
- (void) resignTextFieldResponder;
- (void) callFSSRootMenuProxy;
- (void) clearLoginHistory;
- (void) loadAppropriateView;
- (void) loadNewUIAfterSuccessfullLogin;
- (NSMutableArray *) updateMenuModelDict :(NSDictionary *) paramDict;

@property (nonatomic, weak) IBOutlet UITextField *userIdTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIView *loginView;
@property (nonatomic, weak) IBOutlet UILabel *rememberMeLabel;
@property (nonatomic, weak) IBOutlet UILabel *loginFailedLabel;
@property (nonatomic, weak) IBOutlet UIButton *rememberMeButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSString *rememberUserAccessStatus;
@property (nonatomic, strong) NSMutableDictionary *menuDict;
@property (nonatomic, strong) RootFeedProxy *rootFeedProxy;
@property (nonatomic, assign) int invalidLoginAttemptCounter;

@end

@implementation LoginViewController
@synthesize navigationController = _navigationController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureView];
    //[self clearUserAccess];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.invalidLoginAttemptCounter = 0;
    [self getUserAccess];
}

#pragma mark
#pragma mark Private Method

- (void) configureView {
//    [self.headerLabel setText:kHeaderTitle];
//    [self.headerLabel setFont:[UIFont fontWithName:HeaderFont size:27]];
   
    self.loginView.layer.cornerRadius = 3.0f;
    self.loginButton.layer.cornerRadius = 3.0f;
    [self.rememberMeLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *rememberMeGesture = [[UITapGestureRecognizer alloc] init];
    rememberMeGesture.numberOfTouchesRequired = 1;
    [rememberMeGesture addTarget:self
                          action:@selector(rememberUserAccessGesture:)];
    [self.rememberMeLabel addGestureRecognizer:rememberMeGesture];
    
    UITapGestureRecognizer *viewGesture = [[UITapGestureRecognizer alloc] init];
    viewGesture.numberOfTapsRequired = 1;
    [viewGesture addTarget:self
                    action:@selector(viewGestureFired:)];
    [self.view addGestureRecognizer:viewGesture];
}

- (void) processUserLogin {
    if( [Cache isValidEmail:[NSString stringWithFormat:@"%@",self.userIdTextField.text]] &&
        [self.passwordTextField.text length] > 6) {

        [Cache cache].w3UserId = self.userIdTextField.text;
        [Cache cache].w3Password = self.passwordTextField.text;
        [Cache cache].loginStatus = YES;
        //Save user-access
        [self saveUserAccess];


        //valid processing
        [self loadAppropriateView];
        
        /*Dont call this method, as per discussion with Vijay and Manoj, Reveal view controller is not being used any more.
         //User New method to load newsletter on view
         //[self loadNewUIAfterSuccessfullLogin];
        //
        */
        
    }else {
        [UIUtils alertView:kInvalidLogin
                 withTitle:@"Error"];
    }
}

- (void) checkNetworkAndValidateLogin {
    [Cache cache].w3UserId = self.userIdTextField.text;
    [Cache cache].w3Password = self.passwordTextField.text;
    [self callFSSRootMenuProxy];
}

- (void) rememberUserLogin : (id)sender {
    if([[sender backgroundImageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"checkbox.png"]])
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"checkbox_selected.png"]
                          forState:UIControlStateNormal];
        self.rememberUserAccessStatus = @"1";
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"checkbox.png"]
                          forState:UIControlStateNormal];
        self.rememberUserAccessStatus = @"0";
    }
}

- (void) getUserAccess {
    //Get data from userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userEmail = [defaults objectForKey:@"userEmail"];
    NSString *password = [defaults objectForKey:@"password"];
    BOOL loginStatus = [[defaults objectForKey:@"loginStatus"] boolValue];
    
    if([userEmail length] > 0 && [password length] > 0 && ![userEmail isEqualToString:@"(null)"])
    {
        self.userIdTextField.text = [NSString stringWithFormat:@"%@",userEmail];
        self.passwordTextField.text = [NSString stringWithFormat:@"%@",password];
        [self.rememberMeButton setBackgroundImage:[UIImage imageNamed:@"checkbox_selected.png"]
                                         forState:UIControlStateNormal];
        self.rememberUserAccessStatus = @"1";
        
        [self checkNetworkAndValidateLogin];
    }
    
    if(loginStatus == NO)
    {
        [self clearLoginHistory];
        
    }
}

- (void) clearLoginHistory {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userEmail"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"loginStatus"];
    [defaults synchronize];
    
    self.userIdTextField.text = @"";
    self.passwordTextField.text = @"";
    [self.rememberMeButton setBackgroundImage:[UIImage imageNamed:@"checkbox.png"]
                                     forState:UIControlStateNormal];
    self.rememberUserAccessStatus = @"0";
    
    [Cache cache].w3UserId = nil;
    [Cache cache].w3Password = nil;
    [Cache cache].loginStatus = NO;
    
    [Cache clearCookie];
    
}

- (void) saveUserAccess {
    if([self.rememberUserAccessStatus isEqualToString:@"1"])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%@",self.userIdTextField.text] forKey:@"userEmail"];
        [defaults setObject:[NSString stringWithFormat:@"%@",self.passwordTextField.text] forKey:@"password"];
        [defaults setObject:[NSString stringWithFormat:@"%d",[Cache cache].loginStatus] forKey:@"loginStatus"];
        [defaults synchronize];
    }
}

- (void) clearUserAccess {
    [self.rememberMeButton setBackgroundImage:[UIImage imageNamed:@"checkbox.png"]
                                 forState:UIControlStateNormal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for(id key in [defaults dictionaryRepresentation])
    {
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
    self.rememberUserAccessStatus = @"0";
    
}

- (void) resignTextFieldResponder {
    [self.userIdTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

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

- (void) loadAppropriateView {
    
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    //Added new UI as per discussion with Vijay and Manoj @ 22nd July 15. No need of RevealViewController as per development prespective.
    
    MenuViewController *menuViewController = [rootStoryboard instantiateViewControllerWithIdentifier:MenuViewControllerIdentifier];
    menuViewController.rootMenuDict = self.menuDict;
    
    MenuDetailViewController *menuDetailViewController = (MenuDetailViewController *)[rootStoryboard instantiateViewControllerWithIdentifier:MenuDetailViewControllerIdentifier];
    [Cache cache].menuDataModelArray = [self updateMenuModelDict:self.menuDict];
    
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:menuDetailViewController];
    _navigationController.delegate = self;
    [_navigationController setNavigationBarHidden:YES];
    
    //APPDELEGATE.navigationController = nil;
    APPDELEGATE.navigationController = _navigationController;
    
    ZUUIRevealController *revealViewController = [[ZUUIRevealController alloc] initWithFrontViewController:APPDELEGATE.navigationController
                                                                                        rearViewController:menuViewController];
    
    revealViewController.delegate = menuViewController;
    
    APPDELEGATE.window.rootViewController = revealViewController;
    [APPDELEGATE.window makeKeyAndVisible];

}

- (void) loadNewUIAfterSuccessfullLogin {
        
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    
    SubMenuViewController *subMenuViewController = [rootStoryboard instantiateViewControllerWithIdentifier:SubMenuViewControllerIdentifer];
    subMenuViewController.rootMenuDict = self.menuDict;
    
    /*
     //No need to load newsReaderViewController as default View. We have to load new subMenu as the default menu. 
    NewsReaderViewController *newsReaderViewController = [rootStoryboard instantiateViewControllerWithIdentifier:NewsReaderViewControllerIdentifier];
    newsReaderViewController.rootMenuDict = self.menuDict;
    [APPDELEGATE.navigationController pushViewController:newsReaderViewController
                                         animated:NO];
    */
    [APPDELEGATE.navigationController pushViewController:subMenuViewController
                                                animated:NO];
    
}

- (NSMutableArray *) updateMenuModelDict :(NSDictionary *) paramDict {
    
    NSMutableArray *menuDataModelArray = [NSMutableArray array];
    int count = 0;
    for(id key in paramDict) {
        
        //Sub Menu
        int subMenuCount = 0;
        NSMutableArray *subMenuArray = [[NSMutableArray alloc] init];
        for(NSString *subMenuTitle in [paramDict objectForKey:key]){
            SubMenuModel *subMenuModel = [[SubMenuModel alloc] initWithSubMenuModel:[NSString stringWithFormat:@"%d",count] andSubMenuId:[NSString stringWithFormat:@"%d",subMenuCount]
                                                                     andSubMenuName:[NSString stringWithFormat:@"%@",subMenuTitle]
                                                              andSubMenuDisplayName:[NSString stringWithFormat:@"%@",subMenuTitle]];
            
            [subMenuArray addObject:subMenuModel];
            subMenuCount++;
        }
        NSDictionary *subMenuDict = [NSDictionary dictionaryWithObjectsAndKeys:subMenuArray,key, nil];
        
        [menuDataModelArray addObject:subMenuDict];
        
        count++;
    }
    return menuDataModelArray;
}

#pragma mark
#pragma mark ROOTFeedProxy Delegate Method

- (void) getRootFssMenuDictionary : (NSMutableDictionary *)rootFssDict {
    
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if([[rootFssDict allKeys] count] > 0 && [[rootFssDict allValues] count] > 0){
        
        [self.loginFailedLabel setHidden:YES];
        
        self.menuDict = rootFssDict;
        [self processUserLogin];
        
    }else {
        
        [UIUtils alertView:kInvalidAccess
                 withTitle:@""];
        [self clearLoginHistory];
        
        //handle failed login/ incorrect login
        if(self.invalidLoginAttemptCounter == 2) {
            [self.loginFailedLabel setHidden:NO];
        }
        self.invalidLoginAttemptCounter++;
    }
    
}

- (void) rootFssFail : (NSString *)error {

    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [UIUtils alertView:error
             withTitle:@""];
    [self clearLoginHistory];
    
}

#pragma mark
#pragma mark RememberMeLabel Selector
- (void) rememberUserAccessGesture : (UITapGestureRecognizer *)gesture {
    [self loginButtonTapped:self.rememberMeButton];
}

- (void) viewGestureFired : (UITapGestureRecognizer *)gesture {
    [self resignTextFieldResponder];
}

#pragma mark
#pragma mark Button Tapped Method

-(IBAction)loginButtonTapped:(id)sender {
    if([sender isKindOfClass:[UIButton class]] && [sender isEqual:self.loginButton]) {
        if( [Cache isValidEmail:[NSString stringWithFormat:@"%@",self.userIdTextField.text]] &&
           [self.passwordTextField.text length] > 6) {
            [self checkNetworkAndValidateLogin];
            [self resignTextFieldResponder];
        }else {
            [UIUtils alertView:kInvalidLogin
                     withTitle:@"Error"];
        }
        
        
    }else if ([sender isKindOfClass:[UIButton class]] && [sender isEqual:self.rememberMeButton]) {
        [self rememberUserLogin:sender];
    }
}

#pragma mark
#pragma mark TextFieldDelegate Method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end