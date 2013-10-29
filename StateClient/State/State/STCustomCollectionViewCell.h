//
//  STCustomCollectionViewCell.h
//  UICollectionViewSample
//
//  Created by EIMEI on 2013/06/20.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCustomCollectionViewCell : UICollectionViewCell

//@property (weak, nonatomic, readonly) IBOutlet UILabel *numberLabel;
//@property (weak, nonatomic, readonly) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *greenButton;
//@property (weak, nonatomic) IBOutlet UIImageView *redButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;



@end
