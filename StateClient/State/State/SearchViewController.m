//
//  SearchViewController.m
//  SearchViewController
//
//  Created by keke on 2013/08/25.
//  Copyright (c) 2013年 keke. All rights reserved.
//

#import "SearchViewController.h"
#import "BButton.h"

@interface SearchViewController ()

@end

@implementation SearchViewController{
    StateServerConnection *stateServerConnection;
    
    __weak IBOutlet BButton *searchButton;
    __weak IBOutlet UITextField *searchText;
    __weak IBOutlet UIView *friendProfileView;
    __weak IBOutlet UIView *notFoundView;
    __weak IBOutlet UIButton *friendRequestButton;
    __weak IBOutlet UILabel *friendID;
    __weak IBOutlet UILabel *friendName;
    __weak IBOutlet UIImageView *profileIcon;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"友達を検索";
        self.tabBarItem.image = [UIImage imageNamed:@"search"];
    }
    return self;
}

- (void)initUserID:(NSString*)user Password:(NSString*)pass
{
    stateServerConnection = [[StateServerConnection alloc] initWithUser:user Password:pass Delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [searchButton initWithFrame:CGRectMake(32.0f + (1 * 144.0f), 20.0f + (1 * 60.0f), 112.0f, 40.0f) color:[UIColor colorWithRed:1.20f green:0.40f blue:0.00f alpha:1.00f]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectionDidFinishFindAccount:(NSDictionary*)result Error:(NSError*)error{
    
    if ([[result objectForKey:@"result"] intValue] == 0) {
        notFoundView.hidden = NO;
        friendProfileView.hidden = YES;
        return;
    }
    else if ([[result objectForKey:@"user_id"] isEqualToString:stateServerConnection.userID]){
        friendRequestButton.hidden = YES;
    }
    else if ([[result objectForKey:@"relation"] intValue] == 1){
        [friendRequestButton setTitle:@"申請を解除" forState:UIControlStateNormal];
        friendRequestButton.enabled = YES;
        friendRequestButton.hidden = NO;
    }
    else if ([[result objectForKey:@"relation"] intValue] == 2){
        [friendRequestButton setTitle:@"友達です" forState:UIControlStateNormal];
        [friendRequestButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        friendRequestButton.enabled = NO;
        friendRequestButton.hidden = NO;
    }
    else{
        [friendRequestButton setTitle:@"友達になる" forState:UIControlStateNormal];
        friendRequestButton.enabled = YES;
        friendRequestButton.hidden = NO;
    }
    
    friendName.text = [result objectForKey:@"name"];
    friendID.text = [result objectForKey:@"user_id"];
    [stateServerConnection getIcon:[result objectForKey:@"user_id"]];
    notFoundView.hidden = YES;
    friendProfileView.hidden = NO;
}

- (void)connectionDidFinishGetIcon:(UIImage*)iconImage UserID:(NSString*)user Error:(NSError*)error{
    profileIcon.image = iconImage;
    profileIcon.hidden = NO;
}

- (void)connectionDidFinishCreateFriendRelation:(BOOL)result Error:(NSError *)error{
    if(error != nil){
        return;
    }
    
    [self beginSearch:nil];
}

- (void)connectionDidFinishDeleteFriendRelation:(BOOL)result Error:(NSError *)error{
    if (error != nil) {
        return;
    }
    
    [self beginSearch:nil];
}


- (IBAction)beginSearch:(UIButton *)sender {
    
    [searchText resignFirstResponder];
    friendProfileView.hidden = YES;
    notFoundView.hidden = YES;
    profileIcon.hidden = YES;
    [stateServerConnection findAccount:searchText.text];
}


- (IBAction)editingEnd:(UITextField *)sender{
    [sender resignFirstResponder];
}

- (IBAction)friendRequest:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"友達になる"]){
        [stateServerConnection createFriendRelation:friendID.text];
    }
    else if ([sender.currentTitle isEqualToString:@"申請を解除"]){
        [stateServerConnection deleteFriendRelation:friendID.text];
    }
    
}




@end
