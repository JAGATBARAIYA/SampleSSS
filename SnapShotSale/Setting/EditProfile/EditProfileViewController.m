//
//  EditProfileViewController.m
//  SnapShotSale
//
//  Created by Manish on 11/08/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "EditProfileViewController.h"
#import "MSTextField.h"
#import "User.h"
#import "Helper.h"
#import "AdMobViewController.h"
#import "ChangePasswordViewController.h"
#import "WebClient.h"
#import "TKAlertCenter.h"
#import "MBProgressHUD.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface EditProfileViewController ()

@property (strong, nonatomic) IBOutlet MSTextField *txtFullname;
@property (strong, nonatomic) IBOutlet MSTextField *txtEmail;
@property (strong, nonatomic) IBOutlet MSTextField *txtZipcode;
@property (strong, nonatomic) IBOutlet MSTextField *txtPhoneno;
@property (strong, nonatomic) IBOutlet MSTextField *txtPayPalID;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation EditProfileViewController

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

#pragma CommonInit

- (void)commonInit{
    _txtEmail.text = [User sharedUser].strEmail;
    _txtEmail.textColor = [UIColor grayColor];
    _txtEmail.userInteractionEnabled = NO;
    _txtFullname.text = [User sharedUser].strFullName;
    _txtZipcode.text = [NSString stringWithFormat:@"%ld",(long)[User sharedUser].intZipCode];
    _txtPhoneno.text = [User sharedUser].strPhoneNo;
    _txtPayPalID.text = [User sharedUser].strPayPalID;

    if (IPHONE4 || IPHONE5) {
        _scrollView.contentSize = CGSizeMake(0, 500);
    }

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

- (IBAction)btnSubmitTapped:(id)sender{
    [self resignFields];
    if ([self isValidLoginDetails]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WebClient sharedClient] editProfile:@{@"userid":[NSNumber numberWithInteger:[User sharedUser].intSellerId], @"fullname":_txtFullname.text,@"email": _txtEmail.text,@"zip_code":_txtZipcode.text,@"phone":_txtPhoneno.text,@"device_type":@2,@"devicetoken":@"1234",@"paypal_id":_txtPayPalID.text} success:^(NSDictionary *dictionary) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            if ([dictionary[@"success"] boolValue]) {
                [User sharedUser].strFullName = _txtFullname.text;
                [User sharedUser].strEmail = _txtEmail.text;
                [User sharedUser].intZipCode = [_txtZipcode.text integerValue];
                [User sharedUser].strPhoneNo = _txtPhoneno.text;
                [User sharedUser].strPayPalID = _txtPayPalID.text;

                [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];

                if ([User sharedUser].rememberMe) {
                    [User sharedUser].strEmail = _txtEmail.text;
                    if(![_txtEmail.text isEmptyString]  && [User sharedUser].rememberMe){
                        [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
            }else{
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
            }

        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
        }];
    }
}

- (IBAction)btnChangePasswordTapped:(id)sender{
    ChangePasswordViewController *changePasswordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    [self.navigationController pushViewController:changePasswordViewController animated:YES];
}

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    _scrollView.contentOffset = CGPointMake(0, 0);
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textField.inputAccessoryView = keyboardDoneButtonView;

    if (IPHONE4 || IPHONE5) {
        if (textField == _txtZipcode) {
            _scrollView.contentOffset = CGPointMake(0, 60);
        }
        if (textField == _txtPhoneno || textField == _txtPayPalID) {
            _scrollView.contentOffset = CGPointMake(0, 90);
        }
    }
}

- (IBAction)doneClicked:(id)sender{
    _scrollView.contentOffset = CGPointMake(0, 0);
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _txtFullname) {
        if ([textField.text length] > 0)
        {
            textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[textField.text substringToIndex:1] uppercaseString]];
        }
    }
    if (textField == _txtPhoneno) {
        NSInteger length = [self getLength:textField.text];
        
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"%@-",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            
            textField.text = [NSString stringWithFormat:@"%@-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@-%@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    if (textField == _txtZipcode) {
        NSInteger length = [_txtZipcode.text length];

        if(length == 5)
        {
            if(range.length == 0)
                return NO;
        }
    }

    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber {
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    NSInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    
    return mobileNumber;
}

-(NSInteger)getLength:(NSString*)mobileNumber {
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSInteger length = [mobileNumber length];
    
    return length;
}

#pragma mark - Validate login Information

- (BOOL)isValidLoginDetails{
    if ([_txtFullname.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterFullName image:kErrorImage];
        return NO;
    }else if ([_txtEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterEmail image:kErrorImage];
        return NO;
    }else if ([_txtZipcode.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterZipcode image:kErrorImage];
        return NO;
    }
//    else if ([_txtPhoneno.text isEmptyString]){
//        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterPhoneNo image:kErrorImage];
//        return NO;
//    }
//    if (_txtPhoneno.text.length < 8 || _txtPhoneno.text.length > 15) {
//        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPhoneNo image:kErrorImage];
//        return NO;
//    }
    if(![_txtEmail.text isValidEmail]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
        return NO;
    }
    return YES;
}

- (void)resignFields{
    _scrollView.contentOffset = CGPointMake(0, 0);
    [_txtFullname resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtZipcode resignFirstResponder];
    [_txtPhoneno resignFirstResponder];
    [_txtPayPalID resignFirstResponder];
}

@end
