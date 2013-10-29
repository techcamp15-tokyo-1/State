//
//  ViewController.h
//  State
//
//  Created by techcamp on 2013/08/26.
//  Copyright (c) 2013年 techcamp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StateServerConnection.h"
#import "SearchViewController.h"
#import "FriendListViewController.h"

@interface LoginViewController : UIViewController<StateServerConnectionDelegate>

- (IBAction)login:(UIButton *)sender;
- (IBAction)createAccount:(UIButton *)sender;
- (IBAction)userIDReturn:(UITextField *)sender;
- (IBAction)passwordReturn:(UITextField *)sender;
- (IBAction)viewTouch:(UIControl *)sender;

@end
