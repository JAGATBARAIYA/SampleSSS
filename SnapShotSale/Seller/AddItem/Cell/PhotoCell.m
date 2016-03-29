//
//  PhotoCell.m
//  SnapShotSale
//
//  Created by Manish on 09/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (void)awakeFromNib {
    [self popUpZoomIn];
}

- (void)popUpZoomIn{
    _btnPhoto.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7001, 0.7001);
    [UIView animateWithDuration:1.0
                     animations:^{
                         _btnPhoto.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     } completion:^(BOOL finished) {
                         [self popZoomOut];
                     }];
}

- (void)popZoomOut{
    [UIView animateWithDuration:1.0
                     animations:^{
                         _btnPhoto.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7001, 0.7001);
                     } completion:^(BOOL finished) {
                         [self popUpZoomIn];
                     }];
}
@end
