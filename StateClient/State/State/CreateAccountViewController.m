//
//  CreateAccountViewController.m
//  State
//
//  Created by keke on 2013/08/26.
//  Copyright (c) 2013年 techcamp. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "FriendListViewController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "STSpacingSampleViewController.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController{
    
    __weak IBOutlet UIImageView *iconImage;
    __weak IBOutlet UITextField *userIDField;
    __weak IBOutlet UITextField *passwordField;
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet BButton *registerButton;
    __weak IBOutlet BButton *cancelButton;
    
    StateServerConnection *stateServerConnection;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [registerButton initWithFrame:CGRectMake(32.0f + (1 * 144.0f), 20.0f + (1 * 60.0f), 112.0f, 40.0f) color:[UIColor colorWithRed:1.20f green:0.40f blue:0.00f alpha:1.00f]];
    [cancelButton initWithFrame:CGRectMake(32.0f + (1 * 144.0f), 20.0f + (1 * 60.0f), 112.0f, 40.0f) color:[UIColor colorWithRed:1.20f green:0.40f blue:0.00f alpha:1.00f]];

    stateServerConnection = [[StateServerConnection alloc] initWithUser:@"" Password:@"" Delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fieldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (IBAction)registerButtonTouch:(UIButton *)sender {
    [stateServerConnection createAccount:userIDField.text
                                Password:passwordField.text
                                    Name:nameField.text
                               StateText:@"暇しています"
                                   State:[NSNull null]
                                    Icon:iconImage.image];
}

- (void)connectionDidFinishCreateAccount:(BOOL)result Error:(NSError *)error{
    
    if (!result) {
        NSLog(@"createError");
        return;
    }
    else{
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


- (IBAction)cancelButtonTouch:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)iconEditTouch:(UIControl *)sender {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
		[imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		[imagePickerController setAllowsEditing:YES];
		[imagePickerController setDelegate:self];
		
		[self presentViewController:imagePickerController animated:YES completion:nil];
	}
	else
	{
		NSLog(@"photo library invalid.");
	}
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	iconImage.image = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    iconImage.image = [self resizeImage:iconImage.image rect:CGRectMake(0,0,110,110)];
#warning
    NSLog(@"%f, %f", iconImage.image.size.width, iconImage.image.size.height);
    ////
    [self dismissViewControllerAnimated:YES completion:nil];
	
}

#warning
- (UIImage*)resizeImage:(UIImage *)img rect:(CGRect)rect{
    
    UIGraphicsBeginImageContext(rect.size);
    
    [img drawInRect:rect];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}
////////

@end
