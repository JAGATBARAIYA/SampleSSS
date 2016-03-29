//
//  User.m
//  TravellingApp
//
//  Created by Manish Dudharejia on 15/10/14.
//  Copyright (c) 2014 Marvin. All rights reserved.
//

#define kIsRememberMe           @"RememberMe"
#define kUserID                 @"UserID"
#define kSellerID               @"SellerID"
#define kUserName               @"UserName"
#define kFullName               @"FullName"
#define kUserEmail              @"UserEmail"
#define kPhoneNo                @"PhoneNo"
#define kPassword               @"Password"
#define kIsLogin                @"IsLogin"
#define kDeviceToken            @"DeviceToken"
#define kZipCode                @"ZipCode"
#define kTotalCount             @"TotalCount"
#define kTotalQuantity          @"TotalQuantity"
#define kFBID                   @"FBID"
#define kPayPalID               @"PayPalID"

#import "User.h"
#import "Common.h"
#import "Helper.h"

@implementation User

+ (User*)sharedUser{
    static User *sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        User *user = [Helper getCustomObjectToUserDefaults:kUserInformation];
        if(!user){
            sharedUser = [[User alloc] init];
        }else {
            sharedUser = user;
        }
    });
    return sharedUser;
}

- (instancetype)initWithDict:(NSDictionary*)dict{
    self = [super init];
    if (self) {

    }
    return self;
}

+ (User *)dataWithInfo:(NSDictionary*)dict{
    return [[self alloc] initWithDict:dict];
}

- (void)initWithDictionary:(NSDictionary*)dict{
    User *user = [User sharedUser];
    if(dict[@"userid"]!=[NSNull null])
        user.strUserID = dict[@"userid"];
    
    if(dict[@"email"]!=[NSNull null])
        user.strEmail = dict[@"email"];
    
    if(dict[@"fullname"]!=[NSNull null])
        user.strFullName = dict[@"fullname"];
    
    if(dict[@"password"]!=[NSNull null])
        user.strPassword = dict[@"password"];

    if(dict[@"selleraccountid"]!=[NSNull null])
        user.intSellerId = [dict[@"selleraccountid"] integerValue];
    
    if(dict[@"zip_code"]!=[NSNull null])
        user.intZipCode = [dict[@"zip_code"] integerValue];
    
    if(dict[@"totalcount"]!=[NSNull null])
        user.intTotalCount = [dict[@"totalcount"] integerValue];
    
    if(dict[@"quantityofsnapshots"]!=[NSNull null])
        user.intTotalQuantity = [dict[@"quantityofsnapshots"] integerValue];

    if(dict[@"phone"]!=[NSNull null])
        user.strPhoneNo = dict[@"phone"];
    
    if(dict[@"fbid"]!=[NSNull null])
        user.strFBID = dict[@"fbid"];

    if(dict[@"paypal_id"]!=[NSNull null])
        user.strPayPalID = dict[@"paypal_id"];

}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.rememberMe forKey:kIsRememberMe];
    [encoder encodeBool:self.login forKey:kIsLogin];
    [encoder encodeObject:self.strUserID forKey:kUserID];
    [encoder encodeInteger:self.intSellerId forKey:kSellerID];
    [encoder encodeInteger:self.intZipCode forKey:kZipCode];
    [encoder encodeObject:self.strEmail forKey:kUserEmail];
    [encoder encodeObject:self.strPhoneNo forKey:kPhoneNo];
    [encoder encodeObject:self.strFullName forKey:kFullName];
    [encoder encodeObject:self.strDeviceToken forKey:kDeviceToken];
    [encoder encodeInteger:self.intTotalCount forKey:kTotalCount];
    [encoder encodeInteger:self.intTotalQuantity forKey:kTotalQuantity];
    [encoder encodeObject:self.strFBID forKey:kFBID];
    [encoder encodeObject:self.strPayPalID forKey:kPayPalID];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if( self != nil ) {
        self.rememberMe = [decoder decodeBoolForKey:kIsRememberMe];
        self.login = [decoder decodeBoolForKey:kIsLogin];
        self.strUserID = [decoder decodeObjectForKey:kUserID];
        self.intSellerId = [decoder decodeIntegerForKey:kSellerID];
        self.intZipCode = [decoder decodeIntegerForKey:kZipCode];
        self.strFullName = [decoder decodeObjectForKey:kFullName];
        self.strEmail = [decoder decodeObjectForKey:kUserEmail];
        self.strPhoneNo = [decoder decodeObjectForKey:kPhoneNo];
        self.strDeviceToken = [decoder decodeObjectForKey:kDeviceToken];
        self.intTotalCount = [decoder decodeIntegerForKey:kTotalCount];
        self.intTotalQuantity = [decoder decodeIntegerForKey:kTotalQuantity];
        self.strFBID = [decoder decodeObjectForKey:kFBID];
        self.strPayPalID = [decoder decodeObjectForKey:kPayPalID];
    }
    return self;
}

+ (BOOL)saveCredentials:(NSDictionary*)json{
    BOOL success = [json[@"success"] boolValue];
    if (success) {
        [[User sharedUser] initWithDictionary:json[@"userdata"]];
    }else {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:json[@"message"] image:kErrorImage];
    }
    return success;
}

@end
