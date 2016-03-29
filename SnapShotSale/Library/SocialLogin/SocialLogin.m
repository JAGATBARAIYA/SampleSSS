//
//  SocialLogin.m
//  iPhoneStructure
//
//  Created by Mehul on 03/01/14.
//  Copyright (c) 2014 Mehul. All rights reserved.
//

#import "SocialLogin.h"

@implementation SocialLogin

#pragma mark - Share Login

+ (id)sharedLogin {
    static SocialLogin *sharedMyLogin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyLogin = [[self alloc] init];
    });
    return sharedMyLogin;
}

- (id)init {
    if (self = [super init]) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

-(void)setLoginType:(LoginType)loginType{
    _loginType = loginType;
    _accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
}

#pragma mark - Single Block argument

-(void)loginUsingFacebook:(SocialLoginCallback)completion{
    self.loginType = kLoginTypeFacebook;
    [_accountStore requestAccessToAccountsWithType:_accountType
                                           options:@{ACFacebookAppIdKey:kFacebookAppID,
                                                     ACFacebookPermissionsKey:@[@"email",@"basic_info"]} completion:^(BOOL granted, NSError *error) {
                                                         if(granted){
                                                             NSArray *accounts = [_accountStore accountsWithAccountType:_accountType];
                                                             ACAccount *fbAccount = [accounts lastObject];
                                                             NSDictionary *dict = [fbAccount dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]];
                                                             NSDictionary *properties = dict[@"properties"];
                                                             NSDictionary *returnDict = @{@"FaceBookID":properties[@"uid"],@"DisplayName":properties[@"ACUIAccountSimpleDisplayName"]};
                                                             completion(returnDict,nil);
                                                         }else {
                                                             NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                                             if(error.code == ACErrorAccountNotFound){
                                                                 [details setValue:msgFacebookErrorMsg forKey:NSLocalizedDescriptionKey];
                                                             }else if(error.code == ACErrorPermissionDenied || error.code == ACErrorAccessDeniedByProtectionPolicy) {
                                                                 [details setValue:msgFacebookAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
                                                             }else {
                                                                 [details setValue:msgFacebookAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
                                                             }
                                                             error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
                                                             completion(nil,error);
                                                         }
                                                     }];
}

-(void)loginUsingTwitter:(SocialLoginCallback)completion{
    self.loginType = kLoginTypeTwitter;
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [_accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted){
            NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0){
                ACAccount *twitterAccount = [accounts lastObject];
                NSDictionary *dict = [twitterAccount dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]];
                NSDictionary *properties = dict[@"properties"];
                NSDictionary *returnDict = @{@"TwitterID":properties[@"user_id"],@"UserName":twitterAccount.username};
                completion(returnDict,nil);
            }
            else{
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:msgTwitterErrorMsg forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
                completion(nil,error);
            }
        } else {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            if(error.code == ACErrorAccountNotFound){
                [details setValue:msgTwitterErrorMsg forKey:NSLocalizedDescriptionKey];
            }else if(error.code == ACErrorPermissionDenied || error.code == ACErrorAccessDeniedByProtectionPolicy) {
                [details setValue:msgTwitterAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
            }else {
                [details setValue:msgTwitterErrorMsg forKey:NSLocalizedDescriptionKey];
            }
            error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
            completion(nil,error);
        }
    }];
}

#pragma mark - Two parameters as arguments

-(void)loginUsingFacebook:(void(^)(NSDictionary *dictionary))dict error:(void(^)(NSError *error))fbError{
    self.loginType = kLoginTypeFacebook;
    NSDictionary *dictFB = @{ACFacebookAppIdKey:kFacebookAppID,
                             ACFacebookPermissionsKey : @[@"email"],
                             ACFacebookAudienceKey : ACFacebookAudienceEveryone
                             };

    [_accountStore requestAccessToAccountsWithType:_accountType
                                           options:dictFB
                                        completion:^(BOOL granted, NSError *error) {
                                                         if(granted){
                                                             NSArray *accounts = [_accountStore accountsWithAccountType:_accountType];
                                                             ACAccount *fbAccount = [accounts lastObject];
                                                             /*
                                                             NSDictionary *dict1 = [fbAccount dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]];
                                                             NSDictionary *properties = dict1[@"properties"];
                                                             NSDictionary *returnDict = @{@"FaceBookID":properties[@"uid"],@"DisplayName":properties[@"ACUIAccountSimpleDisplayName"]};
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 dict(returnDict);
                                                             });*/
                                                             
                                                             NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
                                                             NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:@"email,id,name",@"fields", nil];

                                                             SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                                       requestMethod:SLRequestMethodGET
                                                                                                                 URL:meurl
                                                                                                          parameters:param];
                                                             merequest.account = fbAccount;
                                                             [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                 NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     dict(jsonResponse);
                                                                 });
                                                             }];
                                                         }else {
                                                             [self facebookErrorMsg:error error:^(NSError *error) {
                                                                 fbError(error);
                                                             }];
                                                         }
                                                     }];
}

-(void)isLoginInFacebook:(void (^)(BOOL isLogin))login error:(void(^)(NSError *error))fbError{
    self.loginType = kLoginTypeFacebook;
    if([_accountStore accountsWithAccountType:_accountType]){
        [_accountStore requestAccessToAccountsWithType:_accountType options:@{ACFacebookAppIdKey:kFacebookAppID,ACFacebookPermissionsKey:@[@"email"]}
                                            completion:^(BOOL granted, NSError *error) {
                                                if(granted){
                                                    login(YES);
                                                }else {
                                                    [self facebookErrorMsg:error error:^(NSError *error) {
                                                        fbError(error);
                                                    }];
                                                }
                                            }];
    }else {
        NSError *error = [[NSError alloc] initWithDomain:@"Domain" code:ACErrorAccountNotFound userInfo:@{NSLocalizedDescriptionKey:msgFacebookErrorMsg}];
        fbError(error);
    }
}

- (void)facebookErrorMsg:(NSError *)error error:(void(^)(NSError *error))fbError{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    NSLog(@"%@",error.localizedDescription);
    if(error.code == ACErrorAccountNotFound){
        [details setValue:msgFacebookErrorMsg forKey:NSLocalizedDescriptionKey];
    }else if(error.code == ACErrorPermissionDenied || error.code == ACErrorAccessDeniedByProtectionPolicy) {
        [details setValue:msgFacebookAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
    }else {
        [details setValue:msgFacebookAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
    }
    error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
    dispatch_async(dispatch_get_main_queue(), ^{
        fbError(error);
    });
}

-(void)loginUsingTwitter:(void(^)(NSDictionary *dictionary))dict error:(void(^)(NSError *error))twitterError{
    self.loginType = kLoginTypeTwitter;
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [_accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted){
            NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0){
                ACAccount *twitterAccount = [accounts lastObject];
                NSDictionary *dict1 = [twitterAccount dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]];
                NSDictionary *properties = dict1[@"properties"];
                NSDictionary *returnDict = @{@"TwitterID":properties[@"user_id"],@"UserName":twitterAccount.username};
                dispatch_async(dispatch_get_main_queue(), ^{
                    dict(returnDict);
                });
            }else{
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:msgTwitterErrorMsg forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
                dispatch_async(dispatch_get_main_queue(), ^{
                    twitterError(error);
                });
            }
        } else {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            if(error.code == ACErrorAccountNotFound){
                [details setValue:msgTwitterErrorMsg forKey:NSLocalizedDescriptionKey];
            }else if(error.code == ACErrorPermissionDenied || error.code == ACErrorAccessDeniedByProtectionPolicy) {
                [details setValue:msgTwitterAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
            }else {
                [details setValue:msgTwitterAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
            }
            error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                twitterError(error);
            });
        }
    }];
}

#pragma mark - Share Via Facebook

-(void)shareViaFacebook:(UIViewController *)controller parameters:(NSDictionary *)parameters success:(void(^)(NSString *message))success error:(void(^)(NSError *error))fbError{
    NSError *error;
    NSMutableDictionary* details = [NSMutableDictionary dictionary];

    NSString *message = [parameters objectForKey:@"Message"];
    UIImage *image = [parameters objectForKey:@"Image"];

    SLComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result) {
        [controller dismissViewControllerAnimated:YES completion:^{
            switch(result){
                case SLComposeViewControllerResultCancelled:
                    break;
                case SLComposeViewControllerResultDone:
                    success(msgFacebookPostSuccessMsg);
                    break;
            }
        }];
    };
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        SLComposeViewController *composeViewController  = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:(message)?message:@""];
        [composeViewController addImage:(image)?image:nil];
        [controller presentViewController:composeViewController animated:YES completion:nil];
        composeViewController.completionHandler = completionHandler;
    }
    else{
        [details setValue:msgFacebookErrorMsg forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
        fbError(error);
    }
}

#pragma mark - Share Via Twitter

-(void)shareViaTwitter:(UIViewController *)controller parameters:(NSDictionary *)parameters success:(void (^)(NSString *))success error:(void (^)(NSError *))twitterError{
    NSError *error;
    NSMutableDictionary* details = [NSMutableDictionary dictionary];

    NSString *message = [parameters objectForKey:@"Message"];
    UIImage *image = [parameters objectForKey:@"Image"];

    SLComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result) {
        [controller dismissViewControllerAnimated:YES completion:^{
            switch(result){
                case SLComposeViewControllerResultCancelled:
                    break;
                case SLComposeViewControllerResultDone:
                    success(msgTwitterPostSuccessMsg);
                    break;
            }
        }];
    };

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        SLComposeViewController *composeViewController  = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:(message)?message:@""];
        [composeViewController addImage:(image)?image:nil];
        [controller presentViewController:composeViewController animated:YES completion:nil];
        composeViewController.completionHandler = completionHandler;
    }
    else{
        [details setValue:msgTwitterErrorMsg forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Domain" code:error.code userInfo:details];
        twitterError(error);
    }
}

@end
