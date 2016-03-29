//
//  RemoveAdsViewController.m
//  SnapShotSale
//
//  Created by Manish on 25/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "RemoveAdsViewController.h"
#import "REFrostedViewController.h"
#import "Helper.h"
#import "Common.h"
#import "SIAlertView.h"
#import <StoreKit/StoreKit.h>
#import "AdMobViewController.h"
#import "ProductListViewController.h"
#import "SettingViewController.h"
#import "NSObject+Extras.h"
#import "MBProgressHUD.h"
#import "RMStore.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface RemoveAdsViewController ()

@property (strong, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) IBOutlet UIView *popupView_iPhone4;
@property (strong, nonatomic) IBOutlet UIButton *btnRemove;
@property (strong, nonatomic) IBOutlet UIButton *btnRestore;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDesc;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation RemoveAdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)commonInit{
    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
        self.bannerView.hidden = YES;
    }else{
        self.bannerView.adUnitID = kAdUnitIDFilal;
        self.bannerView.rootViewController = self;

        GADRequest *request = [GADRequest request];
        request.testDevices = @[kTestDevice];
        [self.bannerView loadRequest:request];
    }

    if ([_strType isEqualToString:@"ads"]) {
        [_btnRemove setTitle:@"Remove Ads - $0.99" forState:UIControlStateNormal];
        [_btnRestore setTitle:@"Restore Purchases" forState:UIControlStateNormal];
        _lblTitle.text = @"Remove Ads";
        _lblDesc.text = @"Upgrade your app to remove advertisements.";

    }else if ([_strType isEqualToString:@"sub"]){
        [_btnRemove setTitle:@"SUBSCRIBE" forState:UIControlStateNormal];
        [_btnRestore setTitle:@"RESTORE PURCHASES" forState:UIControlStateNormal];
        _lblTitle.text = @"Subscribe";
        _lblDesc.text = @"Subscribe to add more products.";
    }
    [self addPopUpView];
}

- (void)addPopUpView{
    if (IPHONE6PLUS) {
        _popupView_iPhone4.hidden = YES;
        [UIView animateWithDuration:0.7 animations:^{
            CGRect newframe=_popupView.frame;
            newframe.origin.y=200;
            _popupView.frame=newframe;
        } completion:^(BOOL finished) {

        }];
    }else if(IPHONE6){
        _popupView_iPhone4.hidden = YES;
        [UIView animateWithDuration:0.7 animations:^{
            CGRect newframe=_popupView.frame;
            newframe.origin.y=150;
            _popupView.frame=newframe;
        } completion:^(BOOL finished) {

        }];

    }else if(IPHONE5) {
        _popupView_iPhone4.hidden = YES;
        [UIView animateWithDuration:0.7 animations:^{
            CGRect newframe=_popupView.frame;
            newframe.origin.y=100;
            _popupView.frame=newframe;
        } completion:^(BOOL finished) {

        }];
    }else{
        _popupView.hidden = YES;
        [UIView animateWithDuration:0.7 animations:^{
            CGRect newframe=_popupView_iPhone4.frame;
            newframe.origin.y=95;
            _popupView_iPhone4.frame=newframe;
        } completion:^(BOOL finished) {

        }];
    }
}

#pragma mark - Button Click event

- (IBAction)btnMenuTapped:(id)sender{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)btnRemoveAdsTapped:(id)sender {
    NSString *productIdentifier = @"";
    productIdentifier = REMOVE_ADS;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:@[REMOVE_ADS]] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {

        [[RMStore defaultStore] addPayment:productIdentifier success:^(SKPaymentTransaction *transaction)
         {
             NSLog(@"Transection:%@",transaction);
             [Helper addIntToUserDefaults:1 forKey:kRemove_BannerAds];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [self btnNoThanksTapped:nil];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         } failure:^(SKPaymentTransaction *transaction, NSError *error)
         {
             [self performBlock:^{
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
             } afterDelay:1.0];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
             [alerView show];
             [self commonInit];
         }];

    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (IBAction)btnRestoreTapped:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
        NSLog(@"Transactions restored");
        [Helper addIntToUserDefaults:1 forKey:kRemove_BannerAds];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self btnNoThanksTapped:nil];
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

- (IBAction)btnNoThanksTapped:(id)sender{

    if ([_strType isEqualToString:@"sub"]) {
        SettingViewController *sett = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
        [self.navigationController pushViewController:sett animated:NO];
    }else {
        ProductListViewController *productListViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ProductListViewController"];
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
}

#pragma mark - InApp Purchase notification

- (void)productPurchased:(NSNotification *)notification {
    if(notification.object) {
        [self commonInit];
    }
    else {
        NSLog(@"Error in Purchasing");
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)productRestored:(NSNotification *)notification {
    if(notification.object) {
        NSArray *productIdentifiers = notification.object;
        NSLog(@"Restored Products %@",productIdentifiers);
    }
    else {
        NSLog(@"Restore Product Failed");
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self commonInit];
}

@end
