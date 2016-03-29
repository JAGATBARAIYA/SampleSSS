//
//  Common.h
//  FlipIn
//
//  Created by Marvin on 20/11/13.
//  Copyright (c) 2013 Marvin. All rights reserved.
//

#ifndef iPhoneStructure_Common_h
#define iPhoneStructure_Common_h

#pragma mark - All Common Macros

#define isiPhone5                               (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define kUserDirectoryPath                      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
#define IS_IOS7_OR_GREATER                      [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f ? YES : NO
#define PLAYER                                  [MPMusicPlayerController iPodMusicPlayer]

#define IS_IPHONE                               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH                            ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT                           ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH                       (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH                       (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IPHONE4                                 (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IPHONE5                                 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IPHONE6                                 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IPHONE6PLUS                             (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define DegreesToRadians(degrees)               (degrees * M_PI / 180)
#define RadiansToDegrees(radians)               (radians * 180/M_PI)

#define SEGMENT_SELECTED_TEXT_COLOR             [UIColor blackColor]
#define SEGMENT_DESELECTED_TEXT_COLOR           [UIColor whiteColor]
#define SEGMENT_BACK_COLOR                      [UIColor colorWithRed:131.0/255.0 green:25.0/255.0 blue:12.0/255.0 alpha:1.0]

#define kDateFormat                             @"mm/dd/yyyy"

#define kErrorImage                             [UIImage imageNamed:@"error"]
#define kRightImage                             [UIImage imageNamed:@"right"]

#define kUserInformation                        @"UserInformation"

#define titleFail                               @"Fail"
#define titleSuccess                            @"Success"
#define titleAlert                              @"Alert"

#define msgLoading                              @"Loading"
#define msgPleaseWait                           @"Please wait..."

#define msgCameraNotAvailable                   @"Camera not available"           
#define msgNoDataFound                          @"No Record Found"           

#define titleFail                               @"Fail"           
#define titleSuccess                            @"Success"           

#define kAdUnitID                               @"ca-app-pub-3940256099942544/2934735716"
#define kAdUnitIDFilal                          @"ca-app-pub-6973429023750120/3304526295"

#define kTestDevice                             @"2077ef9a63d2b398840261c8221a0c9a"
#define kDeviceToken                            @"123"

#define FACEBOOK_ID                             @"1762525840641142"

#define kGuideViewDisplay                       @"GuideViewDisplay"
#define kHelpViewDisplay                        @"HelpViewDisplay"
#define kRemove_BannerAds                       @"RemoveBannerAds"

//Login
#define msgEnterFullName                        @"Please enter full name."
#define msgEnterName                            @"Please enter name."
#define msgEnterZipcode                         @"Please enter zipcode."
#define msgEnterPhoneNo                         @"Please enter phone number."
#define msgEnterRemark                          @"Please enter remark."
#define msgEnterEmail                           @"Please enter email address."
#define msgEnterValidEmail                      @"Please enter a valid email address."
#define msgEnterValidPassword                   @"Please enter password."
#define msgPasswordNotMatch                     @"Password and Retype password must be same."
#define msgEnterOldPassword                     @"Please enter old password."
#define msgOldPasswordNotMatch                  @"Old password does not match. Please try again."
#define msgPasswordAndConfirmPasswordMatch      @"Password and Confirm password must be same."
#define msgEnterValidPhoneNo                    @"Please enter valid phone number."

//Billing
#define msgEnterBFirstname                      @"Please enter billing first name."
#define msgEnterBLastname                       @"Please enter billing last name."
#define msgEnterBPhoneNo                        @"Please enter billing phone number."
#define msgEnterBEmail                          @"Please enter billing email address."
#define msgEnterBAddress                        @"Please enter billing address."
#define msgEnterBCity                           @"Please enter billing city."
#define msgEnterBCountry                        @"Plesae select billing country."
#define msgEnterBState                          @"Please select billing state."
#define msgEnterBZipCode                        @"Please enter billing zip code."

//Shipping
#define msgEnterSFirstname                      @"Please enter shipping first name."
#define msgEnterSLastname                       @"Please enter shipping last name."
#define msgEnterSPhoneNo                        @"Please enter shipping phone number."
#define msgEnterSEmail                          @"Please enter shipping email address."
#define msgEnterSAddress                        @"Please enter shipping address."
#define msgEnterSCity                           @"Please enter shipping city."
#define msgEnterSCountry                        @"Plesae select shipping country."
#define msgEnterSState                          @"Please select shipping state."
#define msgEnterSZipCode                        @"Please enter shipping zip code."

//Feedback
#define msgName                                 @"Please enter your name."
#define msgRemark                               @"Please enter remarks."

//Product
#define msgEnterProductName                     @"Please enter product name."
#define msgSelectCategory                       @"Please select category."
#define msgEnterPrice                           @"Please enter price."
#define msgEnterDesc                            @"Please enter description."
#define msgSelectImages                         @"Atleast one image required."
#define msgPriceNotZero                         @"Please enter valid price."
#define msgEnterShippingPrice                   @"Please enter shipping price."
#define msgEnterPayPalID                        @"Please enter paypal id."
#define msgEnterValidProductName                @"Special characters are not allowed in product name."

//Filter
#define msgMinaAndMaxPriceZero                  @"Minimum price and maximum price should be greater than 0."
#define msgMinIsLessThanMax                     @"Minimum price should be less than maximum price."
#define msgZipCode                              @"Please enter valid zipcode."

//Location
#define msgTimeOut                              @"Location request timed out. Current Location:\n%@"
#define msgLocationNotDetermine                 @"Location can not be determined. Please try again later."
#define msgUserDeniedPermission                 @"You have denied to access your device location."
#define msgUserRestrictedLocation               @"User is restricted using location services as per usage policy."
#define msgLocationTurnOff                      @"Location services are turned off for all apps on this device."
#define msgLocationError                        @"An unknown error occurred while retrieving current location. Please try again later."

#define REMOVE_ADS                              @"com.snapshotsale.removeads_new"
#define TenSnaps                                @"com.snapshotsale.10snap"
#define FiftySnaps                              @"com.snapshotsale.50snap"

#endif
