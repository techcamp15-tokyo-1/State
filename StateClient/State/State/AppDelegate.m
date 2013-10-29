//
//  AppDelegate.m
//  State
//
//  Created by techcamp on 2013/08/26.
//  Copyright (c) 2013年 techcamp. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate{
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
#warning
    [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    ////////
    
    self.ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setObject:@"" forKey:@"USER_ID"];
    [defaults setObject:@"" forKey:@"PASSWORD"];
    [defaults setObject:@{} forKey:@"FRIEND_LIST"];
    [self.ud registerDefaults:defaults];
    
    StateServerConnection *stateServerConnection = [[StateServerConnection alloc] initWithUser:[self.ud stringForKey:@"USER_ID"]
                                                                                      Password:[self.ud stringForKey:@"PASSWORD"]
                                                                                      Delegate:self];
    [stateServerConnection authentication];

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    return YES;
}

#warning 
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) devToken
{
    //NSLog(@"deviceToken: %@", devToken);
    const unsigned *tokenBytes = [devToken bytes];
    self.devToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    //
    //あとでデバイストークンをサーバーに上げてくださいね
    //

}


- (void)connectionDidFinishUpdateDeviceToken:(BOOL)result Error:(NSError *)error{
    if (error != nil) {
        NSLog(@"updateDevToken error");
    }
    else{
        NSLog(@"updateDevToken ok");
    }

}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *) err
{
    NSLog(@"Errorinregistration.Error:%@", err);
    self.devToken = nil;
}
/////////////////


- (void)connectionDidFinishAuthentication:(BOOL)result Error:(NSError*)error{
    if (result) {
        //[application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];

        SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        [searchViewController initUserID:[self.ud stringForKey:@"USER_ID"] Password:[self.ud stringForKey:@"PASSWORD"]];

        FriendListViewController *friendListViewController = [[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
        
        STSpacingSampleViewController *stSpacingSampleViewController = [[STSpacingSampleViewController alloc] initWithNibName:@"STSpacingSampleViewController" bundle:nil];
        
        self.currentSTS = stSpacingSampleViewController;
        
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.viewControllers = @[stSpacingSampleViewController, friendListViewController, searchViewController];
        self.window.rootViewController = self.tabBarController;
        [self.window makeKeyAndVisible];
        
        NSLog(@"%@",self.devToken);
        StateServerConnection *stateServerConnection = [[StateServerConnection alloc] initWithUser:[self.ud stringForKey:@"USER_ID"]
                                                                                          Password:[self.ud stringForKey:@"PASSWORD"]
                                                                                          Delegate:self];

        if (self.devToken != nil) {
            [stateServerConnection updateDeviceToken:self.devToken];
        }
        
    }
    else{
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.window.rootViewController = self.loginViewController;
        [self.window makeKeyAndVisible];
    }
    
}

#warning 
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"サーバーから届いている中身一覧: %@",[userInfo description]);
    if(application.applicationState == UIApplicationStateInactive){
        //バックグラウンドにいる状態
        
    }else if(application.applicationState == UIApplicationStateActive){
        //ばりばり動いている時
        if (self.currentSTS != nil) {
            NSLog(@"%@",[userInfo objectForKey:@"user_id"]);
            [self.currentSTS pushPing:[userInfo objectForKey:@"user_id"]];

        }
    
    }
}
//////

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
