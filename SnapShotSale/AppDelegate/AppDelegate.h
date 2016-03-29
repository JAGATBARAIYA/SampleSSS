//
//  AppDelegate.h
//  SnapShotSale
//
//  Created by Manish on 08/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL flag;
@property (assign, nonatomic) BOOL isSignIn;
@property (assign, nonatomic) BOOL isDetail;
@property (assign, nonatomic) BOOL isShowMember;
@property (assign, nonatomic) BOOL pullRefresh;
@property (strong, nonatomic) UIImage *appFBImg;

@end

