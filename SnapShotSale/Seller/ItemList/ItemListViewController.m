//
//  ItemListViewController.m
//  SnapShotSale
//
//  Created by Manish on 11/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ItemListViewController.h"
#import "REFrostedViewController.h"
#import "AddItemViewController.h"
#import "ItemDetailViewController.h"
#import "AdMobViewController.h"
#import "TKAlertCenter.h"
#import "WebClient.h"
#import "ItemCell.h"
#import "Common.h"
#import "SIAlertView.h"
#import "User.h"
#import "Helper.h"
#import "SocialMedia.h"
#import "UIActionSheet+BlockExtensions.h"
#import "SIAlertView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#define sharingMsg             @"Take a look at all my items for sale on Snapshotsale.com \r\n\n%@\r\n\nDownload our App today and start selling on Snapshotsale.com!"

#define TWSharingMsg           @"Take a look at all my items for sale on Snapshotsale.com \r\n\n%@"

#define appName                @"SnapShotSale"

@class GADBannerView;

@import GoogleMobileAds;

@interface ItemListViewController ()<UIActionSheetDelegate>
{
    UIRefreshControl *refreshControll;
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
@property (strong, nonatomic) IBOutlet UILabel *lblLink;
@property (strong, nonatomic) NSMutableArray *arrItems;
@property (strong, nonatomic) NSMutableArray *arrFilteredItems;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UIView *blackView;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;

@property (assign, nonatomic) BOOL isTextfieldLoded;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation ItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated{
    app.pullRefresh = NO;
    [self getItemList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _arrItems = [[NSMutableArray alloc]init];
    [_collectionView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellWithReuseIdentifier:@"ItemCell"];
    if(IPHONE4 || IPHONE5){
        EdgeInsets =   30;
    }else if(IPHONE6 || IPHONE6PLUS){
        EdgeInsets = 30;
    }
    
    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
        self.bannerView.hidden = YES;
    }else{
        self.bannerView.adUnitID = kAdUnitIDFilal;
        self.bannerView.rootViewController = self;

        GADRequest *request = [GADRequest request];
        request.testDevices = @[kTestDevice];
        [self.bannerView loadRequest:request];
        CGRect newframe=_collectionView.frame;
        newframe.size.height = [UIScreen mainScreen].bounds.size.height-116;
        _collectionView.frame=newframe;
    }

    CGRect newframe=_shareView.frame;
    newframe.origin.y = [UIScreen mainScreen].bounds.size.height;
    _shareView.frame=newframe;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.blackView addGestureRecognizer:tapGestureRecognizer];
    
    refreshControll = [[UIRefreshControl alloc]init];
    [_collectionView addSubview:refreshControll];
    [refreshControll addTarget:self action:@selector(refreshCollectionView) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Pull To Refresh

- (void)refreshCollectionView {
    app.pullRefresh = YES;
    double delayInSeconds = 1.0;
    [self getItemList];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControll endRefreshing];
        [_collectionView reloadData];
    });
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer{
    [self btnCancelTapped:nil];
}

#pragma mark - Get Product List

- (void)getItemList{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WebClient sharedClient]getSellerItemList:@{@"seller_id":[NSNumber numberWithInteger:[User sharedUser].intSellerId]} success:^(NSDictionary *dictionary) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(dictionary){
            if([dictionary[@"success"] boolValue]){
                [_arrItems removeAllObjects];
                NSArray *listResult = dictionary[@"products"];
                if(listResult.count!=0){
                    [listResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Product *item = [Product dataWithInfo:obj];
                        [_arrItems addObject:item];
                    }];

                    [_collectionView reloadData];
                }else {
                    NSLog(@"Data Not Found");
                }
                _lblLink.text = [dictionary[@"producturl"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [Helper addIntToUserDefaults:_arrItems.count forKey:@"TotalCount"];

//                NSLog(@"Total Product :: %lu",(unsigned long)_arrItems.count);
//                NSLog(@"%ld",(long)[Helper getIntFromNSUserDefaults:@"TotalQty"]);
//                NSLog(@"%ld",(long)[Helper getIntFromNSUserDefaults:@"TotalCount"]);

            }else {
                _btnShare.hidden = _lblNoRecordFound.hidden = _arrItems.count!=0;
            }
            if (_arrItems.count == 0) {
                _btnShare.hidden = YES;
            }else{
                _btnShare.hidden = NO;
            }
            [_collectionView reloadData];
        }
        _lblNoRecordFound.hidden = _arrItems.count!=0;
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

#pragma mark - Collection View delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
    User *user = [Helper getCustomObjectToUserDefaults:kUserInformation];
    user.intTotalCount =  _arrItems.count;
    [Helper addCustomObjectToUserDefaults:user key:kUserInformation];
    return _arrItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCell" forIndexPath:indexPath];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ItemCell" owner:self options:nil] objectAtIndex:0];
    
    Product *item = _arrItems[indexPath.row];
    cell.sellerItem = item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Product *item = nil;
    item = _arrItems[indexPath.row];

    if (item.isSold) {
        
    }else{
        ItemDetailViewController *itemDetailViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ItemDetailViewController"];
        itemDetailViewController.sellerItem = item;
        [self.navigationController pushViewController:itemDetailViewController animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [UIScreen mainScreen].bounds.size.width-(EdgeInsets)-2;
    return CGSizeMake(width/2, width/2);
}

#pragma mark - Button Click event

- (IBAction)btnMenuTapped:(id)sender{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)btnShareTapped:(id)sender{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect newframe=_shareView.frame;
        
        if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
            newframe.origin.y =[UIScreen mainScreen].bounds.size.height - _shareView.frame.size.height; //370;
        }else{
            newframe.origin.y =[UIScreen mainScreen].bounds.size.height - _shareView.frame.size.height - 50; //370;
        }
        _shareView.frame=newframe;
    } completion:^(BOOL finished) {
        
    }];
    _blackView.hidden = NO;
    _blackView.alpha = 0;
    [UIView animateWithDuration:0.6
                     animations:^{
                         _blackView.alpha = 0.8;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (IBAction)btnFacebookTapped:(id)sender{
//    [[SocialMedia sharedInstance] shareViaFacebook:self params:@{@"Message":[NSString stringWithFormat:sharingMsg,_lblLink.text]} callback:^(BOOL success, NSError *error) {
//        if(error){
//            [Helper siAlertView:titleFail msg:error.localizedDescription];
//        }else {
//            [self displaySuccessAlertView:kFacebookPostSuccessMsg];
//        }
//    }];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if ([FBSDKAccessToken currentAccessToken] != nil)
    {
        NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_lblLink.text]};
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (error != nil) {
                 NSLog(@"%@",error.localizedDescription);
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [Helper siAlertView:titleFail msg:error.localizedDescription];
                 [self btnCancelTapped:nil];
             }else
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [Helper siAlertView:titleSuccess msg:kFacebookPostSuccessMsg];
                 [self btnCancelTapped:nil];
             }
         }];
    }
    else{

        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager setLoginBehavior:FBSDKLoginBehaviorSystemAccount];
        [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             if (error)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self btnCancelTapped:nil];
                 [loginManager logOut];
             }
             else if (result.isCancelled)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self btnCancelTapped:nil];
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

                     NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_lblLink.text]};
                     FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
                     [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                      {
                          if (error != nil) {
                              NSLog(@"%@",error.localizedDescription);
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [Helper siAlertView:titleFail msg:error.localizedDescription];
                              [self btnCancelTapped:nil];
                          }else
                          {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [Helper siAlertView:titleSuccess msg:kFacebookPostSuccessMsg];
                              [self btnCancelTapped:nil];
                          }
                      }];
                 }
                 else
                 {
                     [loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
                      {
                          if (error)
                          {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self btnCancelTapped:nil];
                              [loginManager logOut];
                          }
                          else if (result.isCancelled)
                          {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self btnCancelTapped:nil];
                              [loginManager logOut];
                          }
                          else
                          {
                              NSTimeInterval addTimeInterval = 60*60*24*365*50;
                              NSDate *expireDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];
                              NSDate *refreshDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];

                              FBSDKAccessToken *newAccessToken = [[FBSDKAccessToken alloc] initWithTokenString:[[FBSDKAccessToken currentAccessToken] tokenString] permissions:nil declinedPermissions:nil appID:FACEBOOK_ID userID:[[FBSDKAccessToken currentAccessToken] userID] expirationDate:expireDate refreshDate:refreshDate];
                              [FBSDKAccessToken setCurrentAccessToken:newAccessToken];

                              NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_lblLink.text]};
                              FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
                              [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                               {
                                   if (error != nil) {
                                       NSLog(@"%@",error.localizedDescription);
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       [Helper siAlertView:titleFail msg:error.localizedDescription];
                                       [self btnCancelTapped:nil];
                                   }else
                                   {
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       [Helper siAlertView:titleSuccess msg:kFacebookPostSuccessMsg];
                                       [self btnCancelTapped:nil];
                                   }
                               }];
                          }
                      }];
                 }
             }
         }];
    }
}

- (IBAction)btnTwitterTapped:(id)sender{
    [[SocialMedia sharedInstance] shareViaTwitter:self params:@{@"Message":[NSString stringWithFormat:TWSharingMsg,_lblLink.text]} callback:^(BOOL success, NSError *error) {
        if(error){
            [Helper siAlertView:titleFail msg:error.localizedDescription];
        }else {
            [self displaySuccessAlertView:kTwitterPostSuccessMsg];
        }
    }];

//    ACAccountStore *account = [[ACAccountStore alloc] init];
//    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//
//    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
//        if(granted) {
//            NSArray *accountsArray = [account accountsWithAccountType:accountType];
//
//            if ([accountsArray count] > 0) {
//                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
//                SLRequest *postRequest = nil;
//
//                NSDictionary *message = @{@"message":[NSString stringWithFormat:sharingMsg,_lblLink.text]};
//
//                NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
//
//                postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:message];
//
//                postRequest.account = twitterAccount;
//
//                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//                    NSLog(@"Twitter HTTP response: %li", (long)[urlResponse statusCode]);
//
//                    if ([[NSNumber numberWithInteger:[urlResponse statusCode]] isEqual: [NSNumber numberWithInteger:200]]) {
////                        [Helper siAlertView:titleSuccess msg:kTwitterPostSuccessMsg];
//                          [self displaySuccessAlertView:kTwitterPostSuccessMsg];
//                          [self btnCancelTapped:nil];
//                    }else{
////                        [Helper siAlertView:titleSuccess msg:kTwitterPostSuccessMsg];
//                        [self displaySuccessAlertView:kTwitterPostSuccessMsg];
//                        [self btnCancelTapped:nil];
//                    }
//
//                }];
//
//            }else
//            {
//                [self displaySuccessAlertView:@"Please setup your twitter account from settings."];
////                [Helper siAlertView:titleFail msg:@"Please setup your twitter account from settings."];
//                [self btnCancelTapped:nil];
//            }
//        }
//    }];
}

- (IBAction)btnEmailTapped:(id)sender{
    [[SocialMedia sharedInstance] shareViaEmail:self params:@{@"subject":appName,@"message":[NSString stringWithFormat:sharingMsg,_lblLink.text]} callback:^(BOOL success, NSError *error) {
        if(error){
            [Helper siAlertView:titleFail msg:error.localizedDescription];
        }else {
          //  [self displaySuccessAlertView:kTwitterPostSuccessMsg];
        }
    }];
}

- (IBAction)btnCancelTapped:(id)sender{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect newframe=_shareView.frame;
        newframe.origin.y = [UIScreen mainScreen].bounds.size.height;
        _shareView.frame=newframe;
    } completion:^(BOOL finished) {
        
    }];
    _blackView.alpha = 0.8;
    [UIView animateWithDuration:0.6
                     animations:^{
                         _blackView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         _blackView.hidden = YES;
                     }];
}

- (void)displaySuccessAlertView:(NSString *)msgSuccess{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:msgSuccess];
    alertView.buttonsListStyle = SIAlertViewButtonsListStyleRows;
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [self btnCancelTapped:nil];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

@end
