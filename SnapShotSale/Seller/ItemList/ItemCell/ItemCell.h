//
//  ItemCell.h
//  SnapShotSale
//
//  Created by Manish on 11/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ItemCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *soldView;

@property (strong, nonatomic) Product *sellerItem;

@end
