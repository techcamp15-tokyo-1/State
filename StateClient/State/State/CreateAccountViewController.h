//
//  CreateAccountViewController.h
//  State
//
//  Created by keke on 2013/08/26.
//  Copyright (c) 2013年 techcamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateServerConnection.h"


@interface CreateAccountViewController : UIViewController<StateServerConnectionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (IBAction)fieldReturn:(UITextField *)sender;
- (IBAction)registerButtonTouch:(UIButton *)sender;
- (IBAction)cancelButtonTouch:(UIButton *)sender;
- (IBAction)iconEditTouch:(UIControl *)sender;

@end
