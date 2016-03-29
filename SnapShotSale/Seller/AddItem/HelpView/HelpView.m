//
//  GuideViewController.m
//  eWeather
//
//  Created by Manish on 08/01/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "HelpView.h"
#import "common.h"

@interface HelpView ()

@end

@implementation HelpView

- (void)awakeFromNib{
    self.alpha = 0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [self popUpZoomIn];
//    _viewRound.layer.cornerRadius = _viewRound.layer.frame.size.width/2;
//    _viewRound.layer.masksToBounds = YES;
    _roundView.layer.cornerRadius = _roundView.layer.frame.size.width/2;
    _roundView.layer.masksToBounds = YES;
}

- (void)popUpZoomIn{
    _viewRound.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7001, 0.7001);
    [UIView animateWithDuration:1.0
                     animations:^{
                         _viewRound.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     } completion:^(BOOL finished) {
                         [self popZoomOut];
                     }];
}

- (void)popZoomOut{
    [UIView animateWithDuration:1.0
                     animations:^{
                         _viewRound.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7001, 0.7001);
                     } completion:^(BOOL finished) {
                         //_viewRound.hidden = TRUE;
                         [self popUpZoomIn];
                     }];
}

- (IBAction)btnMenuTapped:(id)sender{
    self.alpha = 1;
    [UIView animateWithDuration:1.0
                  animations:^{
                      self.alpha = 0;
                  }
                  completion:^(BOOL finished){
                      if([_delegate respondsToSelector:@selector(helpView:)]){
                          [_delegate helpView:self];
                      };
    }];
}

@end
