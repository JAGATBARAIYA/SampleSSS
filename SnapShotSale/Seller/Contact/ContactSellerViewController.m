//
//  ContactSellerViewController.m
//  SnapShotSale
//
//  Created by Manish on 16/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ContactSellerViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MSTextField.h"
#import "TKAlertCenter.h"
#import "Common.h"
#import "User.h"
#import "AdMobViewController.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "LPlaceholderTextView.h"
#import "MBProgressHUD.h"
#import "JMImageCache.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface ContactSellerViewController ()
{
    AppDelegate *app;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView_iPhone4;

@property (strong, nonatomic) IBOutlet MSTextField *txtName;
@property (strong, nonatomic) IBOutlet MSTextField *txtEmail;
@property (strong, nonatomic) IBOutlet MSTextField *txtPhoneno;
@property (strong, nonatomic) IBOutlet LPlaceholderTextView *txtRemark;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation ContactSellerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{
    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
        self.bannerView.hidden = YES;
        CGRect newframe=_detailView.frame;
        newframe.size.height = [UIScreen mainScreen].bounds.size.height-64;
        _detailView.frame=newframe;
    }else{
        self.bannerView.adUnitID = kAdUnitIDFilal;
        self.bannerView.rootViewController = self;

        GADRequest *request = [GADRequest request];
        request.testDevices = @[kTestDevice];
        [self.bannerView loadRequest:request];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CommonInit

- (void)commonInit{
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.pullRefresh = NO;
    NSURL *imgURL = [NSURL URLWithString:[[[_productDetail.arrImages objectAtIndex:0]valueForKey:@"image_name"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _imgView.layer.cornerRadius = _imgView.frame.size.width/2;
    _imgView.layer.borderWidth = 1.5;
    _imgView.layer.borderColor = [UIColor blackColor].CGColor;
    _imgView.layer.masksToBounds = YES;

    NSMutableString *productName = [_productDetail.strName mutableCopy];
    [productName enumerateSubstringsInRange:NSMakeRange(0, [productName length])
                                    options:NSStringEnumerationByWords
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     [productName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                withString:[[substring substringToIndex:1] uppercaseString]];
                                 }];

//    NSString *productName = [NSString stringWithFormat:@"%@%@",[[_productDetail.strName substringToIndex:1] uppercaseString],[[_productDetail.strName substringFromIndex:1] lowercaseString] ];

    _lblTitle.text = productName;

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    indicator.center = CGPointMake(_imgView.frame.size.width / 2.0, _imgView.frame.size.height / 2.0);

    [self.imgView addSubview:indicator];
    [indicator startAnimating];

    [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        self.imgView.image = image;
    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        self.imgView.image = [UIImage imageNamed:@"no-image"];
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }];

    if (IPHONE4){
        _imgView.hidden = YES;
        _imgView_iPhone4.hidden = NO;
        _imgView_iPhone4.layer.cornerRadius = 40;
        _imgView_iPhone4.layer.borderWidth = 1.5;
        _imgView_iPhone4.layer.borderColor = [UIColor blackColor].CGColor;
        _imgView_iPhone4.layer.masksToBounds = YES;

        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        indicator.center = CGPointMake(_imgView_iPhone4.frame.size.width / 2.0, _imgView_iPhone4.frame.size.height / 2.0);

        [_imgView_iPhone4 addSubview:indicator];
        [indicator startAnimating];

        [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            _imgView_iPhone4.image = image;
        } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
            _imgView_iPhone4.image = [UIImage imageNamed:@"no-image"];
            [indicator stopAnimating];
            [indicator removeFromSuperview];
        }];
    }

//    [_imgView setImageWithURL:imgURL placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
//     {
//         if (image != nil && !error)
//             [_imgView setImage:image];
//
//     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    _txtRemark.placeholderText = @"Remarks";
    _txtRemark.placeholderColor = [UIColor lightGrayColor];
}

#pragma mark - Button Click event

- (IBAction)doneClicked:(id)sender{
    [self.view endEditing:YES];
}

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneTapped:(id)sender{
    [_txtRemark resignFirstResponder];
}

- (IBAction)btnSendTapped:(id)sender {
    [self resignFields];
    if([self isValidLoginDetails]){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WebClient sharedClient] contactSeller:@{@"selleritemid":[NSNumber numberWithInteger:_productDetail.intProductID],@"name": _txtName.text,@"email":_txtEmail.text,@"phone":_txtPhoneno.text,@"remarks":_txtRemark.text} success:^(NSDictionary *dictionary) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if([User saveCredentials:dictionary]){
                [self clearFields];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                [self btnBackTapped:nil];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
        }];
    }
}

#pragma mark - UITextView Delegate Methods

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textView.inputAccessoryView = keyboardDoneButtonView;

    CGRect frame = _detailView.frame;
    if (IPHONE4 || IPHONE5 || IPHONE6 || IPHONE6PLUS){
        frame.origin.y = -100;
    }
    [UIView animateWithDuration:0.4 animations:^{
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self hideKeyboard];
    return YES;
}

#pragma mark - UITextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = 64;
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _txtPhoneno) {
        UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
        [keyboardDoneButtonView sizeToFit];
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleBordered target:self
                                                                      action:@selector(doneButtonClicked:)];
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
        textField.inputAccessoryView = keyboardDoneButtonView;
    }
    CGRect frame = _detailView.frame;
    if (IPHONE4 || IPHONE5 || IPHONE6 || IPHONE6PLUS){
        if (textField == _txtName) {
            frame.origin.y = -30;
        }else if (textField == _txtEmail){
            frame.origin.y = -70;
        }else if (textField == _txtPhoneno){
                frame.origin.y = -90;
        }
    }
    [UIView animateWithDuration:0.4 animations:^{
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
}

- (IBAction)doneButtonClicked:(id)sender{
    [self hideKeyboard];
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
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
            textField.text = [NSString stringWithFormat:@"%@- ",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            
            textField.text = [NSString stringWithFormat:@"%@- %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@- %@",[num substringToIndex:3],[num substringFromIndex:3]];
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

#pragma mark - Keyboard Notifications

- (void)sfkeyboardWillHide:(NSNotification*)notification{
    [self hideKeyboard];
}

- (void)sfkeyboardWillShow:(NSNotification*)notification{
    
}

- (void)hideKeyboard{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = 64;
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
}

- (void)resignFields{
    [_txtName resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtPhoneno resignFirstResponder];
    [_txtRemark resignFirstResponder];
}

- (void)clearFields{
    _txtName.text = _txtEmail.text = _txtRemark.text = _txtPhoneno.text = @"";
}

#pragma mark - Validate login Information

- (BOOL)isValidLoginDetails{
    if ([_txtName.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterName image:kErrorImage];
        return NO;
    }else if ([_txtEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterEmail image:kErrorImage];
        return NO;
    }else if ([_txtPhoneno.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterPhoneNo image:kErrorImage];
        return NO;
    }else if ([_txtRemark.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterRemark image:kErrorImage];
        return NO;
    }
    if (_txtPhoneno.text.length < 8 || _txtPhoneno.text.length > 15) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPhoneNo image:kErrorImage];
        return NO;
    }
    if (![_txtEmail.text isEmptyString]) {
        if(![_txtEmail.text isValidEmail]){
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
            return NO;
        }
    }
    return YES;
}

@end
