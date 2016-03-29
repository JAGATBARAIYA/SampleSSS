//
//  ViewController.m
//  SnapShotSale
//
//  Created by Manish on 08/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ViewController.h"
#import "SignUpViewController.h"
#import "ItemListViewController.h"
#import "ProductListViewController.h"
#import "REFrostedViewController.h"
#import "SFHFKeychainUtils.h"
#import "MSTextField.h"
#import "Helper.h"
#import "SocialLogin.h"
#import "AdMobViewController.h"
#import "AddItemViewController.h"
#import "AppDelegate.h"
#import "ForgotPasswordViewController.h"
#import "SIAlertView.h"
#import "UtilityManager.h"
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@class GADBannerView;

@import GoogleMobileAds;

@interface ViewController ()
{
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet MSTextField *txtEmail;
@property (strong, nonatomic) IBOutlet MSTextField *txtPassword;

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIButton *btnRememberMe;
@property (strong, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutlet UIButton *btnNewUser;

@property (strong, nonatomic) IBOutlet UIImageView *imgLogo;
@property (strong, nonatomic) IBOutlet UILabel *lblLogin;
@property (strong, nonatomic) IBOutlet NSString *loginType;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation ViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self rememberMeInformation];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isSignIn = YES;
    _lblLogin.text = @"Login";
   
    [self rememberMeInformation];
    
  /*  if(IPHONE4){
        _loginView.frame = CGRectMake(0, CGRectGetMaxY(_imgLogo.frame), _loginView.frame.size.width, _loginView.frame.size.height);
        
        _lblLogin.frame = CGRectMake(_lblLogin.frame.origin.x, 5, _lblLogin.frame.size.width, _lblLogin.frame.size.height);
        _txtEmail.frame = CGRectMake(_txtEmail.frame.origin.x, CGRectGetMaxY(_lblLogin.frame)+5, _txtEmail.frame.size.width, _txtEmail.frame.size.height);
        _txtPassword.frame = CGRectMake(_txtPassword.frame.origin.x, CGRectGetMaxY(_txtEmail.frame)+5, _txtPassword.frame.size.width, _txtPassword.frame.size.height);
        _btnRememberMe.frame = CGRectMake(_btnRememberMe.frame.origin.x, CGRectGetMaxY(_txtPassword.frame)+5, _btnRememberMe.frame.size.width, _btnRememberMe.frame.size.height);
        _btnForgotPassword.frame = CGRectMake(_btnForgotPassword.frame.origin.x, CGRectGetMaxY(_txtPassword.frame)+5, _btnForgotPassword.frame.size.width, _btnForgotPassword.frame.size.height);
        _btnSignIn.frame = CGRectMake(_btnSignIn.frame.origin.x, CGRectGetMaxY(_btnRememberMe.frame)+5, _btnSignIn.frame.size.width, _btnSignIn.frame.size.height);
        _btnNewUser.frame = CGRectMake(_btnNewUser.frame.origin.x, CGRectGetMaxY(_btnSignIn.frame)+5, _btnNewUser.frame.size.width, _btnNewUser.frame.size.height);
    }*/

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

- (void)rememberMeInformation{
    app.isSignIn = YES;
    User *user = [Helper getCustomObjectToUserDefaults:kUserInformation];
    if(user){
        if(user.login){
            [UIApplication sharedApplication].statusBarHidden = NO;
            if (app.flag) {
                ItemListViewController *itemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ItemListViewController"];
                [self.navigationController pushViewController:itemViewController animated:YES];
            }else{
                AddItemViewController *addItemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
                [self.navigationController pushViewController:addItemViewController animated:YES];
            }
        }else if(user.rememberMe){
            _txtEmail.text = user.strEmail;
            _txtPassword.text = [SFHFKeychainUtils getPasswordForUsername:user.strEmail andServiceName:user.strEmail error:nil];
            _btnRememberMe.selected = YES;
        }
    }else {
        _txtEmail.text = @"";
        _txtPassword.text = @"";
        _btnRememberMe.selected = NO;
    }
}

#pragma mark - Button Click event

- (IBAction)btnMenuTapped:(id)sender{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)btnRememberMeTapped:(UIButton*)sender {
    sender.selected = !sender.selected;
    [User sharedUser].rememberMe = sender.selected;
}

- (IBAction)btnForgotPasswordTapped:(id)sender {
    [self resignFields];
    ForgotPasswordViewController *forgotPasswordViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
}

- (IBAction)btnLoginTapped:(id)sender {
    [self resignFields];
    if([self isValidLoginDetails]){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WebClient sharedClient] loginIntoApplication:@{@"email": _txtEmail.text,@"password":_txtPassword.text,@"devicetype":@2,@"devicetoken":kDeviceToken} success:^(NSDictionary *dictionary) {
            NSLog(@"%@",dictionary);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(dictionary!=nil){
                if([User saveCredentials:dictionary]) {
                    app.isSignIn = YES;
                    [User sharedUser].login = YES;
                    [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                    [Helper addIntToUserDefaults:[User sharedUser].intTotalQuantity forKey:@"TotalQty"];
                    [Helper addIntToUserDefaults:[User sharedUser].intTotalCount forKey:@"TotalCount"];

                    if(_btnRememberMe.selected){
                        [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                        [User sharedUser].strEmail= _txtEmail.text;
                        [SFHFKeychainUtils storeUsername:[User sharedUser].strEmail andPassword:_txtPassword.text forServiceName:[User sharedUser].strEmail updateExisting:YES error:nil];
                    }
                    if (app.flag) {
                        ItemListViewController *itemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ItemListViewController"];
                        [self.navigationController pushViewController:itemViewController animated:YES];
                    }else{
                        AddItemViewController *addItemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
                        [self.navigationController pushViewController:addItemViewController animated:YES];
                    }
                }
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
        }];
    }
}

- (IBAction)btnLoginFacebookTapped:(id)sender{
    if ([UtilityManager isConnectedToNetwork] == NO || [UtilityManager isDataSourceAvailable] == NO) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:@"Internet is not available."];
        alertView.buttonsListStyle = SIAlertViewButtonsListStyleRows;
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alert) {
                                  
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }else{
        _loginType = @"facebook";
        [self FacebookAuthentication];
        
//        [[SocialLogin sharedLogin] loginUsingFacebook:^(NSDictionary *dictionary) {
//            NSLog(@"facebook save here....%@",dictionary);
//            [self saveData:dictionary];
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        } error:^(NSError *error) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [Helper showAlertView:titleFail withMessage:error.localizedDescription delegate:nil];
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        }];
    }
}

- (IBAction)btnSignUpTapped:(id)sender{
    app.isSignIn = YES;
    SignUpViewController *signupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    signupViewController.strTitle = @"Registration";
    [self.navigationController pushViewController:signupViewController animated:YES];
}

- (void)saveData:(NSDictionary*)dictionary{
    NSDictionary *param = [[NSDictionary alloc]init];
    NSString *strUserName = dictionary[@"name"];
    NSString *strEmail = dictionary[@"email"];
    NSString *strfbid = dictionary[@"id"];
    if ([_loginType isEqualToString:@"facebook"]) {
        param = @{@"email":strEmail,@"fbid":dictionary[@"id"],@"device_type":@2,@"device_id":kDeviceToken,@"first_name":dictionary[@"name"],@"socialmedia_id":dictionary[@"id"],@"socialmedia_type":_loginType};
    }
    [[WebClient sharedClient] loginIntoApplication:param success:^(NSDictionary *dictionary) {
        NSLog(@"Login:%@",dictionary);
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if ([dictionary[@"success"] boolValue] == NO) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
        }else if ([dictionary[@"success"] isEqualToNumber:[NSNumber numberWithInteger:2]]){
            app.isSignIn = NO;
            if([User saveCredentials:dictionary]) {
                [Helper addIntToUserDefaults:[User sharedUser].intTotalQuantity forKey:@"TotalQty"];
                [Helper addIntToUserDefaults:[User sharedUser].intTotalCount forKey:@"TotalCount"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",[User sharedUser].strFBID]];
                UIImage *fbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
                app.appFBImg = fbImage;
                
                SignUpViewController *signupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
                signupViewController.userName = strUserName;
                signupViewController.fbid = strfbid;
                signupViewController.emailID = strEmail;
                [self.navigationController pushViewController:signupViewController animated:YES];
            }
        }else {
            if(dictionary!=nil){
                if([User saveCredentials:dictionary]) {
                    [Helper addIntToUserDefaults:[User sharedUser].intTotalQuantity forKey:@"TotalQty"];
                    [Helper addIntToUserDefaults:[User sharedUser].intTotalCount forKey:@"TotalCount"];
                    [User sharedUser].login = YES;
                    [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",[User sharedUser].strFBID]];
                    UIImage *fbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
                    app.appFBImg = fbImage;
                    if (app.flag) {
                        ItemListViewController *itemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ItemListViewController"];
                        [self.navigationController pushViewController:itemViewController animated:YES];
                    }else{
                        AddItemViewController *addItemViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
                        [self.navigationController pushViewController:addItemViewController animated:YES];
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

#pragma mark - Validate login Information

- (BOOL)isValidLoginDetails{
    if(!_txtEmail.text || [_txtEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterEmail image:kErrorImage];
        return NO;
    }
    if(![_txtEmail.text isValidEmail]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
        return NO;
    }
    if(!_txtPassword.text || [_txtPassword.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPassword image:kErrorImage];
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
    [_txtEmail resignFirstResponder];
    [_txtPassword resignFirstResponder];
}

#pragma mark - FaceBook SDK Method

- (void)FacebookAuthentication
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager setLoginBehavior:FBSDKLoginBehaviorSystemAccount];
    [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
    {
        if (error)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [loginManager logOut];
        }
        else if (result.isCancelled)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
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
                [self FacebookUserInfo];
            }
            else
            {
                [loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
                {
                    if (error)
                    {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [loginManager logOut];
                    }
                    else if (result.isCancelled)
                    {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [loginManager logOut];
                    }
                    else
                    {
                        NSTimeInterval addTimeInterval = 60*60*24*365*50;
                        NSDate *expireDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];
                        NSDate *refreshDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];

                        FBSDKAccessToken *newAccessToken = [[FBSDKAccessToken alloc] initWithTokenString:[[FBSDKAccessToken currentAccessToken] tokenString] permissions:nil declinedPermissions:nil appID:FACEBOOK_ID userID:[[FBSDKAccessToken currentAccessToken] userID] expirationDate:expireDate refreshDate:refreshDate];
                        [FBSDKAccessToken setCurrentAccessToken:newAccessToken];
                        [self FacebookUserInfo];
                    }
                }];
            }
        }
    }];
}

- (void)FacebookUserInfo
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"name,email,first_name,last_name"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (!error)
         {
             NSDictionary *dict = @{@"id":result[@"id"],
                                          @"name":result[@"first_name"],
                                          @"email":result[@"email"]
                                          };
             [self saveData:dict];
         }
         else
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }
     }];
}

@end
