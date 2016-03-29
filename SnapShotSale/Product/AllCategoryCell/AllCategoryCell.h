//
//  AllCountryCell.h
//  Vetted-Intl
//
//  Created by Manish Dudharejia on 25/02/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cat.h"

@interface AllCategoryCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblCategoryName;
@property (strong, nonatomic) IBOutlet UIButton *btnCheck;

@property (strong, nonatomic) Cat *allCategory;

@end
