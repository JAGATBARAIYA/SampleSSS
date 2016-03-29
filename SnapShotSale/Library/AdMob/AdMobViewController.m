//
//  AdMobViewController.m
//  SnapShotSale
//
//  Created by Manish on 25/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "AdMobViewController.h"
#import "Common.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface AdMobViewController ()

@end

@implementation AdMobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

static GADBannerView *bannerView;
static UIView *senderView;
static UIView *containerView;
static UIView *bannerContainerView;
static float bannerHeight;

+ (void)createBanner:(UIViewController *)sender
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        bannerHeight = 50;
    }else{
        bannerHeight = 90;
    }
    
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:kTestDevice, nil];
    
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    bannerView.adUnitID = kAdUnitIDFilal;
    bannerView.rootViewController = (id)self;
    bannerView.delegate = (id<GADBannerViewDelegate>)self;
    
    senderView = sender.view;
    
    bannerView.frame = CGRectMake(0, 0, senderView.frame.size.width, bannerHeight);
    
    [bannerView loadRequest:request];
    
    containerView = [[UIView alloc] initWithFrame:senderView.frame];
    
    bannerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, senderView.frame.size.height, senderView.frame.size.width, bannerHeight)];
    
    for (id object in sender.view.subviews) {
        
        [object removeFromSuperview];
        [containerView addSubview:object];
    }
    
    [senderView addSubview:containerView];
    [senderView addSubview:bannerContainerView];
}

+ (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [UIView animateWithDuration:0.3 animations:^{
        containerView.frame = CGRectMake(0, 0, senderView.frame.size.width, senderView.frame.size.height - bannerHeight);
        bannerContainerView.frame = CGRectMake(0, senderView.frame.size.height - bannerHeight, senderView.frame.size.width, bannerHeight);
        [bannerContainerView addSubview:bannerView];
    }];
}

+ (void)removeBanner:(UIViewController *)sender{
    [bannerView removeFromSuperview];
    [UIView animateWithDuration:0.3 animations:^{
        containerView.frame = CGRectMake(0, 0, senderView.frame.size.width, senderView.frame.size.height + bannerHeight);
        bannerContainerView.frame = CGRectMake(0, senderView.frame.size.height + bannerHeight, senderView.frame.size.width, bannerHeight);
//        [bannerContainerView addSubview:bannerView];
    }];
}

@end
