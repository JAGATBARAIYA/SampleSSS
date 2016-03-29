//
//  SubView.m
//  SnapShotSale
//
//  Created by Manish Dudharejia on 16/07/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "SubscribeView.h"
#import "Helper.h"
#import "Common.h"
#import "SIAlertView.h"
#import <StoreKit/StoreKit.h>
#import "User.h"
#import "AddItemViewController.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "RMStore.h"
#import "NSObject+Extras.h"

@interface SubscribeView ()<RMStoreObserver>
{
    NSArray *_products;
    BOOL _productsRequestFinished;
}

@end

@implementation SubscribeView

- (void)awakeFromNib{
    self.alpha = 0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         [MBProgressHUD showHUDAddedTo:self animated:YES];
                     }];

    _products = @[TenSnaps,FiftySnaps];
    [[RMStore defaultStore] addStoreObserver:self];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:_products] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        [self performBlock:^{
            [MBProgressHUD hideAllHUDsForView:self animated:YES];
        } afterDelay:1.0];

        _productsRequestFinished = YES;

    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }];

    if ([Helper getIntFromNSUserDefaults:@"subscribe"] == 1) {
        _btnRestore.hidden = _btnThanks2.hidden = YES;
        _btnThanks1.hidden = NO;
    }else{
        _btnRestore.hidden = _btnThanks2.hidden = NO;
        _btnThanks1.hidden = YES;
    }
    [self addPopUpView];
}

- (void)addPopUpView{
    [UIView animateWithDuration:0.7 animations:^{
        CGRect newframe=_popupView.frame;
        newframe.origin.y=0;
        _popupView.frame=newframe;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)btnSubscribeTapped:(UIButton *)sender {
    if (_productsRequestFinished == YES) {
        NSString *productIdentifier = @"";
        if (sender.tag == 1) {
            productIdentifier = TenSnaps;
        }else if (sender.tag == 2){
            productIdentifier = FiftySnaps;
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        [[RMStore defaultStore] addPayment:productIdentifier success:^(SKPaymentTransaction *transaction)
         {
             NSLog(@"Transection:%@",transaction);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if ([productIdentifier isEqualToString:TenSnaps]) {
                 [Helper addIntToUserDefaults:[Helper getIntFromNSUserDefaults:@"TotalQty"] + 10 forKey:@"TotalQty"];
                 [self addQty:10];
             }else if([productIdentifier isEqualToString:FiftySnaps]){
                 [Helper addIntToUserDefaults:[Helper getIntFromNSUserDefaults:@"TotalQty"] + 50 forKey:@"TotalQty"];
                 [self addQty:50];
             }
             [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
             [MBProgressHUD hideHUDForView:self animated:YES];

         } failure:^(SKPaymentTransaction *transaction, NSError *error)
         {
             [self performBlock:^{
                 [MBProgressHUD hideHUDForView:self animated:YES];
             } afterDelay:1.0];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
             [alerView show];
         }];

    }else {
        [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    [Helper addIntToUserDefaults:0 forKey:@"subscribe"];
}

- (IBAction)btnRestoreTapped:(id)sender{
    [Helper addIntToUserDefaults:0 forKey:@"subscribe"];
}

- (IBAction)btnNoThanksTapped:(id)sender{
    [self removeFromSuperview];
    [Helper addIntToUserDefaults:0 forKey:@"subscribe"];
    if([_delegate respondsToSelector:@selector(subView:)]){
        [_delegate subView:self];
    };

}

#pragma mark - InApp Purchase notification

- (void)productPurchased:(NSNotification *)notification {
    if(notification.object) {
//        if ([notification.object isEqualToString:TenSnaps]) {
//            [Helper addIntToUserDefaults:[Helper getIntFromNSUserDefaults:@"TotalQty"] + 10 forKey:@"TotalQty"];
//            [self addQty:10];
//        }else if([notification.object isEqualToString:FiftySnaps]){
//            [Helper addIntToUserDefaults:[Helper getIntFromNSUserDefaults:@"TotalQty"] + 50 forKey:@"TotalQty"];
//            [self addQty:50];
//        }
//        [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
    }
    else {
        NSLog(@"Error in Purchasing");
    }
    [MBProgressHUD hideHUDForView:self animated:YES];
}

- (void)productRestored:(NSNotification *)notification {
    if(notification.object) {
        NSArray *productIdentifiers = notification.object;
        NSLog(@"Restored Products %@",productIdentifiers);
    }
    else {
        NSLog(@"Restore Product Failed");
    }
    [MBProgressHUD hideHUDForView:self animated:YES];
}

- (void)addQty:(NSInteger)totalQty{
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    [[WebClient sharedClient]updateQty:@{@"selleraccountid":[NSNumber numberWithInteger:[User sharedUser].intSellerId],@"quantityofsnapshots":[NSNumber numberWithInteger:totalQty]} success:^(NSDictionary *dictionary) {
        [MBProgressHUD hideHUDForView:self animated:YES];
        if(dictionary){
            if([dictionary[@"success"] boolValue]){
                [self btnNoThanksTapped:nil];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

#pragma mark - RMStore Delegate Method

- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProductPurchasedSuccess" object:nil];
    [self removeFromSuperview];
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification
{

}

@end
