//
//  ProductCell.m
//  SnapShotSale
//
//  Created by Manish on 08/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ProductCell.h"

@implementation ProductCell

- (void)awakeFromNib {
    _mainView.layer.borderWidth = 1;
    _mainView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _mainView.layer.masksToBounds = NO;
}

@end
