//
//  SocialLogin.h
//  iPhoneStructure
//
//  Created by Mehul on 03/01/14.
//  Copyright (c) 2014 Mehul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define kFacebookAppID                    @"1762525840641142"
//Demo : @"489958317818050"
//Live : @"1762525840641142"

#define msgFacebookErrorMsg               @"Please configure your Facebook account from Settings."
#define msgFacebookAccessDeniedMsg        @"Facebook Access denied."

#define msgTwitterErrorMsg                @"Please configure your Twitter account from Settings."
#define msgTwitterAccessDeniedMsg         @"Twitter Access denied."

#define msgFacebookPostSuccessMsg         @"Message successfully posted on Facebook."
#define msgFacebookPostFailureMsg         @"Unable to post message on Facebook."

#define msgTwitterPostSuccessMsg          @"Message successfully posted on Twitter."
#define msgTwitterPostFailureMsg          @"Unalble to post message on Twitter."

typedef enum {
    kLoginTypeFacebook = 0,
    kLoginTypeTwitter = 1
} LoginType;

//Social Callback typedef
typedef void(^SocialLoginCallback)(NSDictionary *dictionary,NSError *error);

@interface SocialLogin : NSObject

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;

@property (nonatomic, assign) LoginType loginType;

+ (id)sharedLogin;

-(void)loginUsingFacebook:(SocialLoginCallback)completion;
-(void)loginUsingTwitter:(SocialLoginCallback)completion;

-(void)loginUsingFacebook:(void(^)(NSDictionary *dictionary))dict error:(void(^)(NSError *error))fbError;
-(void)loginUsingTwitter:(void(^)(NSDictionary *dictionary))dict error:(void(^)(NSError *error))twitterError;

-(void)shareViaFacebook:(UIViewController *)controller parameters:(NSDictionary *)parameters success:(void(^)(NSString *message))success error:(void(^)(NSError *error))fbError;
-(void)shareViaTwitter:(UIViewController *)controller parameters:(NSDictionary *)parameters success:(void (^)(NSString *))success error:(void (^)(NSError *))twitterError;

-(void)isLoginInFacebook:(void (^)(BOOL isLogin))login error:(void(^)(NSError *error))fbError;

@end
