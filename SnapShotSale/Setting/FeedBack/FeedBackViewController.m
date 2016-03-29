//
//  FeedBackViewController.m
//  SnapShotSale
//
//  Created by Manish on 23/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "FeedBackViewController.h"
#import "WebClient.h"
#import "MSTextField.h"
#import "TKAlertCenter.h"
#import "Common.h"
#import "Helper.h"
#import "AdMobViewController.h"
#import "LPlaceholderTextView.h"
#import "MBProgressHUD.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface FeedBackViewController ()

@property (strong, nonatomic) IBOutlet MSTextField *txtFullname;
@property (strong, nonatomic) IBOutlet MSTextField *txtEmail;
@property (strong, nonatomic) IBOutlet LPlaceholderTextView *txtRemark;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation FeedBackViewController

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

#pragma mark - Common Init

- (void)commonInit{
    _txtRemark.placeholderText = @"Remarks";
    _txtRemark.placeholderColor = [UIColor lightGrayColor];

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

#pragma mark - Button Click Event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneClicked:(id)sender{
    [self.view endEditing:YES];
}

- (IBAction)btnDoneTapped:(id)sender{
    [_txtRemark resignFirstResponder];
}

- (IBAction)btnFeedBackTapped:(id)sender{
    if([self isValidLoginDetails]){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WebClient sharedClient] feedBack:@{@"name":_txtFullname.text,@"email":_txtEmail.text,@"comments":_txtRemark.text} success:^(NSDictionary *dictionary) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            _txtFullname.text = _txtEmail.text = _txtRemark.text = @"";
            [self resignFields];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];

        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
        }];
    }
}

#pragma mark - Validate login Information

- (BOOL)isValidLoginDetails{
    if ([_txtFullname.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgName image:kErrorImage];
        return NO;
    }else if ([_txtEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterEmail image:kErrorImage];
        return NO;
    }else if ([_txtRemark.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgRemark image:kErrorImage];
        return NO;
    }
    if(![_txtEmail.text isValidEmail]){
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


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textView.inputAccessoryView = keyboardDoneButtonView;

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)resignFields{
    [_txtFullname resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtRemark resignFirstResponder];
}
@end
