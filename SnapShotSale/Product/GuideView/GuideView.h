//
//  GuideViewController.h
//  eWeather
//
//  Created by Manish on 08/01/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuideView;

@protocol GuideViewDelegate <NSObject>
- (void)guideView:(GuideView *)view;
@end

@interface GuideView : UIView

@property (strong, nonatomic)IBOutlet UIView *viewRound;
@property (strong, nonatomic)IBOutlet UIImageView *imgView;
@property (strong, nonatomic)IBOutlet UIButton *btnStart;

@property (assign, nonatomic) id<GuideViewDelegate> delegate;

@end
