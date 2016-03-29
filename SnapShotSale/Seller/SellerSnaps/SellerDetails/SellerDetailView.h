//
//  SellerDetailView.h
//  SnapShotSale
//
//  Created by Manish Dudharejia on 30/07/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetail.h"

@class SellerDetailView;

@protocol SellerDetailViewDelegate <NSObject>
- (void)sellerDetailView:(SellerDetailView *)view;
@end

@interface SellerDetailView : UIView

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblMemberSince;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;
@property (strong, nonatomic) IBOutlet UIView *viewRound;

@property (strong, nonatomic) ProductDetail *productDetail;

@property (assign, nonatomic) id<SellerDetailViewDelegate> delegate;

@end
