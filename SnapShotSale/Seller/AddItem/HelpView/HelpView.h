//
//  GuideViewController.h
//  eWeather
//
//  Created by Manish on 08/01/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HelpView;

@protocol HelpViewDelegate <NSObject>
- (void)helpView:(HelpView *)view;
@end

@interface HelpView : UIView

@property (strong, nonatomic) IBOutlet UIView *viewRound;
@property (strong, nonatomic) IBOutlet UIView *roundView;

@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (assign, nonatomic) id<HelpViewDelegate> delegate;

@end
