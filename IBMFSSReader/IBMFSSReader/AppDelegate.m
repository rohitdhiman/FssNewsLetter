//
//  AppDelegate.m
//  IBMFSSReader
//
//  Created by Rohit on 06/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "AppDelegate.h"
#import "Crittercism.h"
#import <IMFCore/IMFCore.h>
#import <IMFData/IMFData.h>
#import <IMFPush/IMFPush.h>

@interface AppDelegate ()

- (void) initilizeBulemix;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NSThread sleepForTimeInterval:2.0];
    [Crittercism enableWithAppID:@"559e04f05c69e80d008f9464"];
    
    [self initilizeBulemix];
    [self setApplicationServiceURL];
    
    UIStoryboard *rootStoryboard = [UIStoryboard storyboardWithName:RootStoryboardIdentifier
                                                             bundle:nil];
    
    self.loginViewController = [rootStoryboard instantiateViewControllerWithIdentifier:LoginViewControllerIdentifier];
    [Cache cache].rootViewController = self.loginViewController;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //notification code
    [self registerForPushNotificationService];
    if (launchOptions != nil) {
        // Launched from push notification
        NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (notification) {
            [self processNotification:notification];
        }
    }
    
    return YES;
}

- (void) setApplicationServiceURL {
    [Cache cache].baseURL = @"https://w3-connections.ibm.com/wikis/basic/api/wiki/";
    [Cache cache].userAgent = [Cache getDeviceUserAgent];
    
}

- (void) initilizeBulemix {
    IMFClient *imfClient = [IMFClient sharedInstance];
    [imfClient initializeWithBackendRoute:@"https://bluemixiospushdemo.mybluemix.net"
                              backendGUID:@"dca622ba-61f8-4b26-912f-b4b54290e1b2"];
}

#pragma mark
#pragma mark Notification Method
- (void)registerForPushNotificationService {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType userNotificationType = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:userNotificationType categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        
        UIRemoteNotificationType remoteNotificationType = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:remoteNotificationType];
    }
}

-(void) processNotification:(NSDictionary*)paramUserInfo {
    
    NSString *message = [self retrieveNotificationMessage:paramUserInfo];
    if(message) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"%@",[paramUserInfo objectForKey:@"alert"]]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"View Detail",Nil];
        alert.tag = 1001;
        [alert show];

    }
}

-(NSString*)retrieveNotificationMessage:(NSDictionary*)paramPayload {
    
    NSString *result = nil;
    
    NSDictionary *apsPayload = paramPayload[@"key"];
    id alertObject = apsPayload[@"key"];
    
    //APNS spec, the alert is either an NSString or an NSDictionary
    if ([alertObject isKindOfClass:[NSString class]])
    {
        result = (NSString *)alertObject;
    }
    else
    {
        result = ((NSDictionary *)alertObject)[@"key"];
    }
    
    return result;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *devToken = [NSString stringWithFormat:@"%@",deviceToken];
    NSArray *devTokenArray = [devToken componentsSeparatedByString:@"<"];
    devToken = [devTokenArray objectAtIndex:1];
    NSArray *seperatedDevToken = [devToken componentsSeparatedByString:@">"];
    devToken = [seperatedDevToken objectAtIndex:0];
    [Cache cache].deviceToken = [NSString stringWithFormat:@"%@",devToken];
    NSLog(@"Device Token : \n%@ \n%@",devToken,[Cache cache].deviceToken);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%@",[Cache cache].deviceToken] forKey:@"deviceToken"];
    [defaults synchronize];}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSString *errorMsg = [NSString stringWithFormat:@"Error: %@",error.localizedDescription];
    NSLog(@"Error while registering : %@",errorMsg);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    for(id key in userInfo)
    {
        NSLog(@"Key : %@, Value : %@",key,[userInfo objectForKey:key]);
    }
    NSLog(@"Userinfo : %@",userInfo);
    
    SEL applicationState = sel_registerName("applicationState");
    if (![application respondsToSelector:applicationState] ||
        application.applicationState == UIApplicationStateActive)
    {
        
        [self processNotification:userInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"alert"]]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"View Detail",Nil];
        alert.tag = 1001;
        [alert show];
        
        NSLog(@" application in active state %@",userInfo);
        
    }
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        if([[alertView buttonTitleAtIndex:1] isEqualToString:@"View Detail"])
        {
            //handel action
        }
    }
}


/*
-(void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    
}

-(void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {

}
*/
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ibm.IBMFSSReader" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IBMFSSReader" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IBMFSSReader.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
