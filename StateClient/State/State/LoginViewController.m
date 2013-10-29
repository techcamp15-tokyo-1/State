//
//  ViewController.m
//  State
//
//  Created by techcamp on 2013/08/26.
//  Copyright (c) 2013年 techcamp. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CreateAccountViewController.h"
#import "STSpacingSampleViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController{
    
    __weak IBOutlet BButton *loginButton;
    __weak IBOutlet BButton *accountCreateButton;
    __weak IBOutlet UITextField *userIDField;
    __weak IBOutlet UITextField *passwordField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [loginButton initWithFrame:CGRectMake(32.0f + (1 * 144.0f), 20.0f + (1 * 60.0f), 112.0f, 40.0f) color:[UIColor colorWithRed:1.20f green:0.40f blue:0.00f alpha:1.00f]];
    [accountCreateButton initWithFrame:CGRectMake(32.0f + (1 * 144.0f), 20.0f + (1 * 60.0f), 112.0f, 40.0f) color:[UIColor colorWithRed:1.20f green:0.40f blue:0.00f alpha:1.00f]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(UIButton *)sender {
    
    StateServerConnection *stateServerConnection = [[StateServerConnection alloc] initWithUser:userIDField.text
                                                                                      Password:passwordField.text Delegate:self];
    
    [stateServerConnection authentication];
}

- (IBAction)createAccount:(UIButton *)sender {
    CreateAccountViewController *cavc = [[CreateAccountViewController alloc] initWithNibName:@"CreateAccountViewController" bundle:nil];
    cavc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cavc animated:YES completion:^ {
        
    }];
}


- (IBAction)userIDReturn:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (IBAction)passwordReturn:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (IBAction)viewTouch:(UIControl *)sender {
    [userIDField resignFirstResponder];
    [passwordField resignFirstResponder];
}

- (void)connectionDidFinishAuthentication:(BOOL)result Error:(NSError*)error{
    if (error != nil) {
        NSLog(@"error");
    }
    else if (result){
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSUserDefaults *ud = appDelegate.ud;
        [ud setObject:userIDField.text forKey:@"USER_ID"];
        [ud setObject:passwordField.text forKey:@"PASSWORD"];
        [ud synchronize];
        
        NSLog(@"%@",appDelegate.devToken);
        
        if (appDelegate.devToken != nil) {
            [[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                                Password:[ud stringForKey:@"PASSWORD"] Delegate:self]
             updateDeviceToken:appDelegate.devToken];
        }
        
        
        SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        [searchViewController initUserID:[ud stringForKey:@"USER_ID"] Password:[ud stringForKey:@"PASSWORD"]];
        
        FriendListViewController *friendListViewController = [[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
        
        STSpacingSampleViewController *stSpacingSampleViewController = [[STSpacingSampleViewController alloc] initWithNibName:@"STSpacingSampleViewController" bundle:nil];

        appDelegate.currentSTS = stSpacingSampleViewController;
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.viewControllers = @[stSpacingSampleViewController, friendListViewController, searchViewController];
        tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:tabBarController animated:YES completion:^ {

        }];
    }
}

- (void)connectionDidFinishUpdateDeviceToken:(BOOL)result Error:(NSError *)error{
    if (error != nil) {
        NSLog(@"updateDevToken error");
    }
    else{
        NSLog(@"updateDevToken ok");
    }
}


@end
