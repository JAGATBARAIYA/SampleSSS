//
//  SignUpViewController.m
//  SnapShotSale
//
//  Created by Manish on 08/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "SignUpViewController.h"
#import "ItemListViewController.h"
#import "AdMobViewController.h"
#import "AddItemViewController.h"
#import "MSTextField.h"
#import "TKAlertCenter.h"
#import "WebClient.h"
#import "Common.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "SocialMedia.h"
#import "SIAlertView.h"
#import "MBProgressHUD.h"
#import "TandCViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#define sharingMsg             @"Hey guys! Check out this amazing app for buying and selling products of your choice. Get started by downloading Snapshotsale on your device at the earliest!"

@class GADBannerView;

@import GoogleMobileAds;

@interface SignUpViewController ()
{
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet MSTextField *txtFullname;
@property (strong, nonatomic) IBOutlet MSTextField *txtEmail;
@property (strong, nonatomic) IBOutlet MSTextField *txtPassword;
@property (strong, nonatomic) IBOutlet MSTextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet MSTextField *txtZipcode;
@property (strong, nonatomic) IBOutlet MSTextField *txtPhoneno;
@property (strong, nonatomic) IBOutlet MSTextField *txtPayPalID;

@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutlet UIButton *btnTnadC;
@property (strong, nonatomic) IBOutlet UIView *line;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation SignUpViewController

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

#pragma mark - CommonInit

- (void)commonInit{
    _lblTitle.text = _strTitle;
    
    if ([_lblTitle.text isEqualToString:@"Registration"]) {
        _txtEmail.userInteractionEnabled = YES;
        _btnTnadC.hidden = NO;
        _line.hidden = NO;
        
    }else {
        _txtEmail.text = [User sharedUser].strEmail;
        _txtEmail.textColor = [UIColor grayColor];
        _txtEmail.userInteractionEnabled = NO;
        _txtFullname.text = [User sharedUser].strFullName;
        _txtZipcode.text = [NSString stringWithFormat:@"%ld",(long)[User sharedUser].intZipCode];
        _txtPhoneno.text = [User sharedUser].strPhoneNo;
        _btnTnadC.hidden = YES;
        _line.hidden = YES;
        if (IPHONE4 || IPHONE5) {
            _btnSignIn.frame = CGRectMake(8, 310, 304, 38);
        }else if (IPHONE6){
            _btnSignIn.frame = CGRectMake(8, 370, 358, 45);
        }else if (IPHONE6PLUS){
            _btnSignIn.frame = CGRectMake(8, 415, 396, 51);
        }
    }
    
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!app.isSignIn) {
        _lblTitle.text = @"Registration";
        _txtZipcode.text = @"";
        _txtEmail.text = _emailID;
        _txtPhoneno.text = @"";
        _txtEmail.userInteractionEnabled = YES;
        _txtFullname.text = [_userName capitalizedString];
        _txtEmail.textColor = [UIColor blackColor];
        _txtPassword.hidden = YES;
        _txtConfirmPassword.hidden = YES;
        _line.hidden = NO;
        _btnTnadC.hidden = NO;
        if (IPHONE5 || IPHONE4) {
            _btnTnadC.frame = CGRectMake(85, 262, 150, 32);
            _line.frame = CGRectMake(85, 286, 150, 1);
            _btnSignIn.frame = CGRectMake(8, 303, 304, 38);
        }else if (IPHONE6){
            _btnTnadC.frame = CGRectMake(85, 309, 205, 38);
            _line.frame = CGRectMake(115, 338, 150, 1);
            _btnSignIn.frame = CGRectMake(9, 365, 358, 45);
        }else if (IPHONE6PLUS){
            _btnTnadC.frame = CGRectMake(85, 342, 244, 43);
            _line.frame = CGRectMake(132, 374, 150, 1);
            _btnSignIn.frame = CGRectMake(10, 405, 396, 51);
        }
    }else{
        _txtPassword.hidden = NO;
        _txtConfirmPassword.hidden = NO;
    }
    [Helper registerKeyboardNotification:self];

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

#pragma mark - Button Click event

-(IBAction)btnTermsANdConditiopntapped:(id)sender{
    [_txtFullname resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtPassword resignFirstResponder];
    [_txtPhoneno resignFirstResponder];
    [_txtZipcode resignFirstResponder];
    [_txtConfirmPassword resignFirstResponder];
    
    TandCViewController *tandcViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"TandCViewController"];
    [self.navigationController pushViewController:tandcViewController animated:YES];
}

- (IBAction)btnCancelTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSignUpTapped:(id)sender {
    [self resignFields];
    if([self isValidLoginDetails]){
        if ([_lblTitle.text isEqualToString:@"Registration"]) {
            if (_fbid == nil) {
                _fbid = @"";
            }
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[WebClient sharedClient] signUp:@{@"fullname":_txtFullname.text,@"email": _txtEmail.text,@"password":_txtPassword.text,@"zip_code":_txtZipcode.text,@"phone":_txtPhoneno.text,@"device_type":@2,@"devicetoken":@"1234",@"fbid":_fbid,@"paypal_id":_txtPayPalID.text} success:^(NSDictionary *dictionary) {
                NSLog(@"dict : %@",dictionary);
                [MBProgressHUD hideHUDForView:self.view animated:YES];

                if ([dictionary[@"success"] boolValue] == YES) {
                    if (dictionary) {
                        [User sharedUser].login = YES;
                        [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                        [Helper addIntToUserDefaults:[User sharedUser].intTotalQuantity forKey:@"TotalQty"];
                        [Helper addIntToUserDefaults:[User sharedUser].intTotalCount forKey:@"TotalCount"];
                    }
                    if (!app.isSignIn) {
                        app.isSignIn = YES;
                        [self shareOnFaceBook];
//                        [[SocialMedia sharedInstance] shareViaFacebook:self params:@{@"Message":sharingMsg} callback:^(BOOL success, NSError *error) {
//                            if(error){
//                                [Helper siAlertView:titleFail msg:error.localizedDescription];
//                            }else if (success) {
//                                NSLog(@"Success");
//                                [self displaySuccessAlertView:kFacebookPostSuccessMsg];
//                            }else{
//                                AddItemViewController *addItemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
//                                [self.navigationController pushViewController:addItemViewController animated:YES];
//                            }
//                        }];
                    }else{
                            AddItemViewController *addItemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
                            [self.navigationController pushViewController:addItemViewController animated:YES];
                    }
                if([User saveCredentials:dictionary]){
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                    [User sharedUser].login = YES;
                    [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                    [Helper addIntToUserDefaults:[User sharedUser].intTotalQuantity forKey:@"TotalQty"];
                    [Helper addIntToUserDefaults:[User sharedUser].intTotalCount forKey:@"TotalCount"];

                }

                }
                else{
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
                }
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
            }];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[WebClient sharedClient] editProfile:@{@"userid":[NSNumber numberWithInteger:[User sharedUser].intSellerId], @"fullname":_txtFullname.text,@"email": _txtEmail.text,@"password":_txtPassword.text,@"zip_code":_txtZipcode.text,@"phone":_txtPhoneno.text,@"device_type":@2,@"devicetoken":@"1234",@"paypal_id":_txtPayPalID.text} success:^(NSDictionary *dictionary) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if([User saveCredentials:dictionary]){
                    [User sharedUser].login = YES;
                    [User sharedUser].strFullName = _txtFullname.text;
                    [User sharedUser].strEmail = _txtEmail.text;
                    [User sharedUser].intZipCode = [_txtZipcode.text integerValue];
                    [User sharedUser].strPhoneNo = _txtPhoneno.text;
                    
                    [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                    
                    if ([User sharedUser].rememberMe) {
                        [User sharedUser].strEmail = _txtEmail.text;
                        if(![_txtEmail.text isEmptyString]  && [User sharedUser].rememberMe){
                            [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                        }
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                }
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
            }];
        }
    }
}

- (void)displaySuccessAlertView:(NSString *)msgSuccess{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:msgSuccess];
    alertView.buttonsListStyle = SIAlertViewButtonsListStyleRows;
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              AddItemViewController *addItemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
                              [self.navigationController pushViewController:addItemViewController animated:YES];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

#pragma mark - Validate login Information

- (BOOL)isValidLoginDetails{
    if ([_lblTitle.text isEqualToString:@"Registration"]){
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
//        else if ([_txtPhoneno.text isEmptyString]){
//            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterPhoneNo image:kErrorImage];
//            return NO;
//        }
        if (app.isSignIn) {
            if ([_txtPassword.text isEmptyString]){
                [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPassword image:kErrorImage];
                return NO;
            }
            if(![_txtPassword.text isEqualToString:_txtConfirmPassword.text]){
                [[TKAlertCenter defaultCenter] postAlertWithMessage:msgPasswordNotMatch image:kErrorImage];
                return NO;
            }
        }
//        if (_txtPhoneno.text.length < 8 || _txtPhoneno.text.length > 15) {
//            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPhoneNo image:kErrorImage];
//            return NO;
//        }
        if(![_txtEmail.text isValidEmail]){
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
            return NO;
        }
    }else{
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
//        else if ([_txtPhoneno.text isEmptyString]){
//            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterPhoneNo image:kErrorImage];
//            return NO;
//        }
//        if (_txtPhoneno.text.length < 8 || _txtPhoneno.text.length > 15) {
//            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPhoneNo image:kErrorImage];
//            return NO;
//        }
        if(![_txtEmail.text isValidEmail]){
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
            return NO;
        }
        if(![_txtPassword.text isEqualToString:_txtConfirmPassword.text]){
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgPasswordNotMatch image:kErrorImage];
            return NO;
        }
    }
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
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textField.inputAccessoryView = keyboardDoneButtonView;

    CGRect frame = _detailView.frame;

    if (textField == _txtZipcode){
        frame.origin.y = -10;
    }else if (textField == _txtPhoneno) {
        frame.origin.y = -20;
    }else if (textField == _txtPayPalID) {
        frame.origin.y = -60;
    }else if (textField == _txtPassword){
        frame.origin.y = -70;
    }else if (textField == _txtConfirmPassword){
        frame.origin.y = -80;
    }

    [UIView animateWithDuration:0.4 animations:^{
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
}

- (IBAction)doneClicked:(id)sender{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = 64;
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
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

- (void)resignFields{
    [_txtFullname resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtZipcode resignFirstResponder];
    [_txtPhoneno resignFirstResponder];
    [_txtPassword resignFirstResponder];
    [_txtConfirmPassword resignFirstResponder];
}

#pragma mark - Keyboard Notifications

- (void)sfkeyboardWillHide:(NSNotification*)notification{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = 64;
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
}

- (void)sfkeyboardWillShow:(NSNotification*)notification{

}

- (void)shareOnFaceBook{

    if ([FBSDKAccessToken currentAccessToken] != nil)
    {
        NSDictionary *dict = @{@"message":sharingMsg};
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (error != nil) {
                 NSLog(@"%@",error.localizedDescription);
                 [Helper siAlertView:titleFail msg:error.localizedDescription];
             }else
             {
                 [self displaySuccessAlertView:kFacebookPostSuccessMsg];
             }
         }];
    }
    else
    {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager setLoginBehavior:FBSDKLoginBehaviorSystemAccount];
        [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             if (error)
             {
                 [loginManager logOut];
             }
             else if (result.isCancelled)
             {
                 [loginManager logOut];
             }
             else
             {
                 if ([result.grantedPermissions containsObject:@"publish_actions"])
                 {
                     NSTimeInterval addTimeInterval = 60*60*24*365*50;
                     NSDate *expireDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];
                     NSDate *refreshDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];

                     FBSDKAccessToken *newAccessToken = [[FBSDKAccessToken alloc] initWithTokenString:[[FBSDKAccessToken currentAccessToken] tokenString] permissions:nil declinedPermissions:nil appID:FACEBOOK_ID userID:[[FBSDKAccessToken currentAccessToken] userID] expirationDate:expireDate refreshDate:refreshDate];
                     [FBSDKAccessToken setCurrentAccessToken:newAccessToken];

                     NSDictionary *dict = @{@"message":sharingMsg};
                     FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
                     [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                      {
                          if (error != nil) {
                              NSLog(@"%@",error.localizedDescription);
                              [Helper siAlertView:titleFail msg:error.localizedDescription];
                          }else
                          {
                              [self displaySuccessAlertView:kFacebookPostSuccessMsg];
                          }
                      }];
                 }
                 else
                 {
                     [loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
                      {
                          if (error)
                          {
                              [loginManager logOut];
                          }
                          else if (result.isCancelled)
                          {
                              [loginManager logOut];
                          }
                          else
                          {
                              NSTimeInterval addTimeInterval = 60*60*24*365*50;
                              NSDate *expireDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];
                              NSDate *refreshDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];

                              FBSDKAccessToken *newAccessToken = [[FBSDKAccessToken alloc] initWithTokenString:[[FBSDKAccessToken currentAccessToken] tokenString] permissions:nil declinedPermissions:nil appID:FACEBOOK_ID userID:[[FBSDKAccessToken currentAccessToken] userID] expirationDate:expireDate refreshDate:refreshDate];
                              [FBSDKAccessToken setCurrentAccessToken:newAccessToken];

                              NSDictionary *dict = @{@"message":sharingMsg};
                              FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
                              [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                               {
                                   if (error != nil) {
                                       NSLog(@"%@",error.localizedDescription);
                                       [Helper siAlertView:titleFail msg:error.localizedDescription];
                                   }else
                                   {
                                       [self displaySuccessAlertView:kFacebookPostSuccessMsg];
                                   }
                               }];
                          }
                      }];
                 }
             }
         }];
    }
}

@end
