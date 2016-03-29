//
//  ItemDetailViewController.h
//  SnapShotSale
//
//  Created by Manish on 09/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetail.h"
#import "Product.h"

@interface ItemDetailViewController : UIViewController

@property (strong, nonatomic) ProductDetail *productDetail;
@property (strong, nonatomic) Product *sellerItem;

@end
