//
//  WebKit.h
//  iPhoneStructure
//
//  Created by Marvin on 29/04/14.
//  Copyright (c) 2014 Marvin. All rights reserved.
//

#ifndef iPhoneStructure_WebKit_h
#define iPhoneStructure_WebKit_h

//Live Server
//#define kWebserviceURL                          @"https://software.snapshotsale.com/webservices/"

//Demo Server
#define kWebserviceURL                          @"http://dev-imaginovation.net/snapshotsale/webservices/"

//Login
#define kUserLogin                              @"login.php"
#define kForgotPassword                         @"forgot_password.php"

//Register
#define kRegister                               @"signup.php"
#define kAddPayPalID                            @"add_paypal_id.php"

//Category
#define kGetCategories                          @"get_categories.php"

//Product
#define kGetProductList                         @"get_product_list.php"
#define kGetProductDetail                       @"get_porduct_details.php"

//Seller
#define kGetSellerItemList                     @"seller_item_list.php"
#define kDeleteSellerItem                      @"seller_item_delete.php"
#define kContactSeller                         @"contact_seller.php"
#define kAddItem                               @"add_product.php"
#define kEditItem                              @"edit_product.php"
#define KEditProfile                           @"editprofile.php"
#define kFeedback                              @"add_feedback.php"
#define kGetNearestSeller                      @"get_nearest_seller.php"
#define kAdvanceSearch                         @"advance_search.php"
#define kChangePassword                        @"changepassword.php"
#define kSpamReport                            @"product_reportas_spam.php"
#define kUpdateQty                             @"update_salers_item_quantity.php"
#define kPlaceOrder                            @"place_order.php"

#import "AFNetworking.h"
#import "WebClient.h"
#import "User.h"
#import "AppDelegate.h"

#endif
