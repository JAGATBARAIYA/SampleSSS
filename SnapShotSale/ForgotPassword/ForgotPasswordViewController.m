//
//  ForgotPasswordViewController.m
//  SnapShotSale
//
//  Created by Manish on 22/07/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "WebClient.h"
#import "MSTextField.h"
#import "TKAlertCenter.h"
#import "Common.h"
#import "Helper.h"
#import "AdMobViewController.h"
#import "MBProgressHUD.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface ForgotPasswordViewController ()

@property (strong, nonatomic) IBOutlet MSTextField *txtForgotEmail;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
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
}

- (IBAction)btnSendTapped:(id)sender {
    [_txtForgotEmail resignFirstResponder];
    if([self isValidForgotDetails]){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WebClient sharedClient] forgotPassword:@{@"email":_txtForgotEmail.text} success:^(NSDictionary *dictionary) {
            BOOL success = [dictionary[@"success"] boolValue];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                [self btnCancelTapped:nil];
            }else{
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
        }];
    }
}

- (IBAction)btnCancelTapped:(id)sender {
    [_txtForgotEmail resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isValidForgotDetails{
    if(!_txtForgotEmail.text || [_txtForgotEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterEmail image:kErrorImage];
        return NO;
    }
    if(![_txtForgotEmail.text isValidEmail]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
        return NO;
    }
    return YES;
}

#pragma mark - UITextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)resignFields{
    [_txtForgotEmail resignFirstResponder];
}

@end
