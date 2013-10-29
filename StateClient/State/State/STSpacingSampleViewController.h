//
//  STSpacingSampleViewController.h
//  UICollectionViewSample
//
//  Created by EIMEI on 2013/06/20.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateServerConnection.h"
#import "BButton.h"



@interface STSpacingSampleViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate, StateServerConnectionDelegate>{
    int count;
    NSString *val0;
    NSString *val1;
    NSDate *date;
    NSCalendar *calendar;
    NSDateComponents *dateComps;

}
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIImageView *myIcon;
@property (weak, nonatomic) IBOutlet UITableView *stateTable;
@property (weak, nonatomic) IBOutlet UIButton *freeButton;
@property (weak, nonatomic) IBOutlet UILabel *selectedStringLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *miniStateCollectionview;
@property (weak, nonatomic) IBOutlet UILabel *freeBusyLabel;
@property (weak, nonatomic) IBOutlet UILabel *myName;

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
- (IBAction)hiddenUI:(UIControl *)sender;
- (IBAction)pushStateButton:(id)sender;
- (IBAction)pushFreeButton:(id)sender;
- (IBAction)touchTextField:(id)sender;
- (IBAction)touchSegmentedControl:(UISegmentedControl *)sender;
- (IBAction)textFieldreturn:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UILabel *myStateLabel;
@property (strong, nonatomic) NSArray *friendList;


- (void)pushPing:(NSString*)pingUser;



@end
