//
//  WebClient.m
//  iPhoneStructure
//
//  Created by Marvin on 29/04/14.
//  Copyright (c) 2014 Marvin. All rights reserved.
//

#import "WebClient.h"
#import "NSString+extras.h"
#import "Common.h"
#import "TKAlertCenter.h"
#import "AppDelegate.h"

@interface WebClient()
{
    AppDelegate *app;
}

@end

@implementation WebClient

#pragma mark - Shared Client

+ (id)sharedClient {
    static WebClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

#pragma mark - Get generic Path

- (void)getAtPath:(NSString *)path withParams:(NSDictionary *)params :(void(^)(id jsonData))onComplete failure:(void (^)(NSError *error))failure {
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.pullRefresh) {

    }else{

    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error= nil;
        if(responseObject){
            NSString *json = [[[NSString alloc] initWithData:(NSData*)responseObject encoding:NSASCIIStringEncoding] trimWhiteSpace];
            NSArray *dictArray = [json componentsSeparatedByString:@"<!-- Hosting24"];
            NSData *data = [dictArray[0] dataUsingEncoding:NSUTF8StringEncoding];
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (error){
                NSLog(@"%@",error.localizedDescription);
                NSLog(@"JSON parsing error in %@", NSStringFromSelector(_cmd));
                failure(error);
            } else {
                onComplete(jsonData);
            }
        }else{
            onComplete(nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(error.code == -1005) {
            [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                onComplete(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"request failed %@ (%li)", operation.request.URL, (long)operation.response.statusCode);
                failure(error);
            }];
        }
        else {
            NSLog(@"request failed %@ (%li)", operation.request.URL, (long)operation.response.statusCode);
            failure(error);
        }
    }];
}

#pragma mark - Login Call

- (void)loginIntoApplication:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kUserLogin fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Forgot Password Call

- (void)forgotPassword:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kForgotPassword fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Sign Up

- (void)signUp:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kRegister fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Get Category List

- (void)getCategory:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kGetCategories fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Get Product List

- (void)getProductList:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kGetProductList fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getProductDetail:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kGetProductDetail fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }]; 
}

#pragma mark - Get Seller Item List

- (void)getSellerItemList:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kGetSellerItemList fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Add Item

- (void)addItem:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kAddItem fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Edit Item

- (void)editItem:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kEditItem fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Delete Item

- (void)deleteItem:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kDeleteSellerItem fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Contact Seller

- (void)contactSeller:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kContactSeller fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];    
}

#pragma mark - Edit Profile

- (void)editProfile:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[KEditProfile fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - FeddBack

- (void)feedBack:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kFeedback fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Get Nearest Seller

- (void)getNearestSeller:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kGetNearestSeller fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Advance Search

- (void)advanceSearch:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kAdvanceSearch fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];  
}

#pragma mark - Change Password

- (void)changePassword:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kChangePassword fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Spam Report

- (void)spamReport:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kSpamReport fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Update Qty

- (void)updateQty:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kUpdateQty fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Add PayPal ID

- (void)addPayPalID:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kAddPayPalID fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Place Order

- (void)placeOrder:(NSDictionary *)params success:(WebClientCallbackSuccess)success failure:(WebClientCallbackFailure)failure{
    [self getAtPath:[kPlaceOrder fullPath] withParams:params:^(id jsonData) {
        success((NSDictionary*)jsonData);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
