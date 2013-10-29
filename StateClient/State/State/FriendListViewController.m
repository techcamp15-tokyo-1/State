//
//  FriendListViewController.m
//  State
//
//  Created by keke on 2013/08/26.
//  Copyright (c) 2013年 techcamp. All rights reserved.
//

#import "FriendListViewController.h"
#import "AppDelegate.h"
#import "STSpacingSampleViewController.h"

@interface FriendListViewController ()

@end

@implementation FriendListViewController{
    NSUserDefaults *ud;
    NSArray *listNameArray;
    NSArray *friendListArray;
    
    __weak IBOutlet UITableView *friendListTableView;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"友達リスト";
        self.tabBarItem.image = [UIImage imageNamed:@"users"];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ud = appDelegate.ud;
    
    
    //今回の発表のためのベタ打ちリストデータ
    if ([[ud stringForKey:@"USER_ID"] isEqualToString:@"member1"]) {
        listNameArray = @[@"全員", @"メンバー2と3と4"];
        friendListArray = @[@"member2", @"member3", @"member4"];
    }
    else if ([[ud stringForKey:@"USER_ID"] isEqualToString:@"member2"]) {
        listNameArray = @[@"全員", @"メンバー3と4と5"];
        friendListArray = @[@"member3", @"member4", @"member5"];
    }
    else if ([[ud stringForKey:@"USER_ID"] isEqualToString:@"member3"]) {
        listNameArray = @[@"全員", @"メンバー4と5と6"];
        friendListArray = @[@"member4", @"member5", @"member6"];
    }
    else if ([[ud stringForKey:@"USER_ID"] isEqualToString:@"member4"]) {
        listNameArray = @[@"全員", @"メンバー5と6と7"];
        friendListArray = @[@"member5", @"member6", @"member7"];
    }
    else if ([[ud stringForKey:@"USER_ID"] isEqualToString:@"member5"]) {
        listNameArray = @[@"全員", @"メンバー6と7と1"];
        friendListArray = @[@"member6", @"member7", @"member1"];
    }
    else if ([[ud stringForKey:@"USER_ID"] isEqualToString:@"member6"]) {
        listNameArray = @[@"全員", @"メンバー7と1と2"];
        friendListArray = @[@"member7", @"member1", @"member2"];
    }
    else if ([[ud stringForKey:@"USER_ID"] isEqualToString:@"member7"]) {
        listNameArray = @[@"全員", @"メンバー1と2と3"];
        friendListArray = @[@"member1", @"member2", @"member3"];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listNameArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [listNameArray objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%d", indexPath.row);
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (indexPath.row == 0) {
        STSpacingSampleViewController *stSpacingSampleViewController = [[STSpacingSampleViewController alloc] initWithNibName:@"STSpacingSampleViewController" bundle:nil];
        stSpacingSampleViewController.friendList = nil;
        
        appDelegate.currentSTS = stSpacingSampleViewController;
        
        NSArray *tempArray = self.tabBarController.viewControllers;
        
        self.tabBarController.viewControllers = @[stSpacingSampleViewController, [tempArray objectAtIndex:1], [tempArray objectAtIndex:2]];
        
        [self.tabBarController setSelectedIndex:0];
        
    }
    else if (indexPath.row == 1) {
        STSpacingSampleViewController *stSpacingSampleViewController = [[STSpacingSampleViewController alloc] initWithNibName:@"STSpacingSampleViewController" bundle:nil];
        stSpacingSampleViewController.friendList = friendListArray;
        stSpacingSampleViewController.title = [listNameArray objectAtIndex:1];
        
        appDelegate.currentSTS = stSpacingSampleViewController;
        
        NSArray *tempArray = self.tabBarController.viewControllers;
        
        self.tabBarController.viewControllers = @[stSpacingSampleViewController, [tempArray objectAtIndex:1], [tempArray objectAtIndex:2]];
        
        [self.tabBarController setSelectedIndex:0];
        
    }
}





@end
