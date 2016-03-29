//
//  User.h
//  TravellingApp
//
//  Created by Manish Dudharejia on 15/10/14.
//  Copyright (c) 2014 Marvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (assign, nonatomic) NSInteger intSellerId;
@property (assign, nonatomic) NSInteger intTotalCount;
@property (assign, nonatomic) NSInteger intTotalQuantity;
@property (assign, nonatomic) NSInteger intZipCode;

@property (strong, nonatomic) NSString *strUserId;
@property (strong, nonatomic) NSString *strUserID;
@property (strong, nonatomic) NSString *strFullName;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strPassword;
@property (strong, nonatomic) NSString *strDeviceToken;
@property (strong, nonatomic) NSString *strPhoneNo;
@property (strong, nonatomic) NSString *strFBID;
@property (strong, nonatomic) NSString *strPayPalID;

@property (strong, nonatomic) NSString *strAccType;

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@property (assign, nonatomic) NSInteger bookmarkCount;

@property (assign, nonatomic) BOOL allowContactByEmail;
@property (assign, nonatomic) BOOL allowContactByText;

@property (assign, nonatomic, getter=isRememberMe) BOOL rememberMe;
@property (assign, nonatomic, getter=isLogin) BOOL login;
@property (assign, nonatomic, getter=isPushNotification) BOOL pushNotification;


+ (User*)sharedUser;

+ (User *)dataWithInfo:(NSDictionary*)dict;
- (void)initWithDictionary:(NSDictionary*)dict;

+ (BOOL)saveCredentials:(NSDictionary*)json;

@end