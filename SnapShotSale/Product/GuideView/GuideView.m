//
//  GuideViewController.m
//  eWeather
//
//  Created by Manish on 08/01/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "GuideView.h"
#import "common.h"

@interface GuideView ()

@end

@implementation GuideView

- (void)awakeFromNib{
    self.alpha = 0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
//    [self popUpZoomIn];
    _imgView.layer.cornerRadius = 10.0;
    _imgView.layer.masksToBounds = YES;
    
    _viewRound.layer.cornerRadius = 5.0;
    _viewRound.layer.masksToBounds = YES;

    _btnStart.layer.cornerRadius = 5.0;
    _btnStart.layer.borderColor = [UIColor colorWithRed:131.0/255.0 green:25.0/255.0 blue:12.0/255.0 alpha:1.0].CGColor;
    _btnStart.layer.borderWidth = 1.0;
    
    _btnStart.layer.masksToBounds = YES;

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
                      if([_delegate respondsToSelector:@selector(guideView:)]){
                          [_delegate guideView:self];
                      };
    }];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect{
    return 25;
}

@end
