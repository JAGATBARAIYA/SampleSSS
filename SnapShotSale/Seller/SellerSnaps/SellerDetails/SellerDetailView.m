//
//  SellerDetailView.m
//  SnapShotSale
//
//  Created by Manish Dudharejia on 30/07/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "SellerDetailView.h"

@interface SellerDetailView ()

@end

@implementation SellerDetailView

- (void)awakeFromNib{
    self.alpha = 0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    _imgProfile.layer.cornerRadius = _imgProfile.layer.frame.size.width/2;
    _imgProfile.layer.masksToBounds = YES;
    
    _viewRound.layer.cornerRadius = _viewRound.layer.frame.size.width/2;
    _viewRound.layer.masksToBounds = YES;
    _viewRound.layer.shadowColor = [UIColor blackColor].CGColor;
    _viewRound.layer.shadowOffset = CGSizeMake(0, 1);
    _viewRound.layer.shadowOpacity = 1;
    _viewRound.layer.shadowRadius = 10.0;
    _viewRound.clipsToBounds = NO;
}

- (IBAction)btnCancelTapped:(id)sender{
    self.alpha = 1;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if([_delegate respondsToSelector:@selector(sellerDetailView:)]){
                             [_delegate sellerDetailView:self];
                         };
                     }];
}

@end
