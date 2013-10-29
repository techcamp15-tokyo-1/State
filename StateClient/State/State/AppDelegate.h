//
//  AppDelegate.h
//  State
//
//  Created by techcamp on 2013/08/26.
//  Copyright (c) 2013年 techcamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateServerConnection.h"
#import "LoginViewController.h"
#import "SearchViewController.h"
#import "FriendListViewController.h"
#import "STSpacingSampleViewController.h"





@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, StateServerConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSUserDefaults *ud;
#warning 
@property (strong, nonatomic) NSString *devToken;

@property (strong, nonatomic) STSpacingSampleViewController *currentSTS;
/////



@end
