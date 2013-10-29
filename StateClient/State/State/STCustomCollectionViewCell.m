//
//  STCustomCollectionViewCell.m
//  UICollectionViewSample
//
//  Created by EIMEI on 2013/06/20.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import "STCustomCollectionViewCell.h"

@implementation STCustomCollectionViewCell

//
// readonly property still need to define synthesize.
//
//@synthesize numberLabel = _numberLabel;
//@synthesize captionLabel = _captionLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}



- (void)awakeFromNib
{
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [UIColor grayColor];
        _timeLabel.transform = CGAffineTransformRotate(_timeLabel.transform, -M_PI/6);
        //_timeLabel.backgroundColor = [UIColor whiteColor];
}


@end
