//
//  AllCountryCell.m
//  Vetted-Intl
//
//  Created by Manish Dudharejia on 25/02/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "AllCategoryCell.h"

@implementation AllCategoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

- (void)setAllCategory:(Cat *)allCategory{
    _allCategory = allCategory;
    _lblCategoryName.text = allCategory.strCatName;
    _btnCheck.selected = _allCategory.isSelected = NO;
}

- (IBAction)btnCheckTapped:(UIButton*)sender{
    sender.selected = !sender.selected;
    _allCategory.isSelected = sender.selected;
}

@end
