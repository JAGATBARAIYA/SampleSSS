//
//  SubView.h
//  SnapShotSale
//
//  Created by Manish Dudharejia on 16/07/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubscribeView;

@protocol SubscribeViewDelegate <NSObject>
- (void)subView:(SubscribeView *)view;
@end

@interface SubscribeView : UIView

@property (strong, nonatomic) IBOutlet UIView *popupView;

@property (strong, nonatomic) IBOutlet UIButton *btnRestore;
@property (strong, nonatomic) IBOutlet UIButton *btnThanks1;
@property (strong, nonatomic) IBOutlet UIButton *btnThanks2;

@property (assign, nonatomic) id<SubscribeViewDelegate> delegate;

@end
