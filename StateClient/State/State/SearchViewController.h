//
//  SearchViewController.h
//  SearchViewController
//
//  Created by keke on 2013/08/25.
//  Copyright (c) 2013年 keke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateServerConnection.h"


@interface SearchViewController : UIViewController<StateServerConnectionDelegate>
- (IBAction)beginSearch:(UIButton *)sender;
- (IBAction)editingEnd:(UITextField *)sender;
- (IBAction)friendRequest:(UIButton *)sender;

- (void)initUserID:(NSString*)user Password:(NSString*)pass;

@end
