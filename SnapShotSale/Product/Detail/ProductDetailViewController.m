//
//  ProductDetailViewController.m
//  SnapShotSale
//
//  Created by Manish on 13/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "ContactSellerViewController.h"
#import "SellerSnapsViewController.h"
#import "ConfirmOrderVC.h"
#import "WebClient.h"
#import "TKAlertCenter.h"
#import "Common.h"
#import "ProductDetail.h"
#import "ImageCell.h"
#import "AdMobViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "NSString+extras.h"
#import "SocialMedia.h"
#import "SIAlertView.h"
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "JMImageCache.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

#define sharingMsg             @"I thought you may be interested in this item on Snapshotsale.com \r\n\nProduct Name : %@ \r\nPrice : %@ \r\nFind this product useful? Buy it today! \r\n%@\r\n\nDownload our App today and start selling on Snapshotsale.com!"

#define TWSharingMsg           @"Product Name : %@ \r\nPrice : %@ \r\nFind this product useful? Buy it today! \r\n%@"

#define emailSharingMsg        @"I thought you would find the below item interesting: \r\n\nProduct Name : %@ \r\nPrice : %@ \r\nFind this product useful? Buy it today! \r\n%@\r\n\nDownload our App today and start selling on Snapshotsale.com!"

#define appName                @"SnapShotSale"
#define spamMessage            @"BadOffensive Snap"
#define sendTo                 @"feedback@snapshotsale.com."

@class GADBannerView;

@import GoogleMobileAds;

@interface ProductDetailViewController ()
{
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblLink;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UITextView *txtDesc;
@property (strong, nonatomic) IBOutlet UIButton *btnBuyNow1;
@property (strong, nonatomic) IBOutlet UIImageView *imgPayPal1;
@property (strong, nonatomic) IBOutlet UIButton *btnBuyNow;
@property (strong, nonatomic) IBOutlet UIButton *btnPayPal;
@property (strong, nonatomic) IBOutlet UIButton *btnSellerSnap;
@property (strong, nonatomic) IBOutlet UIButton *btnSellerSnap1;
@property (strong, nonatomic) IBOutlet UIImageView *imgPayPal;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UIView *blackView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIView *firstView;
@property (strong, nonatomic) IBOutlet UIView *secondView;
@property (strong, nonatomic) IBOutlet UIView *thirdView;
@property (strong, nonatomic) IBOutlet UIView *fourthView;

@property (strong, nonatomic) ProductDetail *productDetail;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@property (strong, nonatomic) NSMutableArray *arrImages;

@end

@implementation ProductDetailViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{
    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
        self.bannerView.hidden = YES;
        CGRect newframe=_detailView.frame;
        newframe.size.height = [UIScreen mainScreen].bounds.size.height-20;
        _detailView.frame=newframe;
    }else{
        self.bannerView.adUnitID = kAdUnitIDFilal;
        self.bannerView.rootViewController = self;

        GADRequest *request = [GADRequest request];
        request.testDevices = @[kTestDevice];
        [self.bannerView loadRequest:request];
    }

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];

    UIFont *font1 = [UIFont fontWithName:@"Roboto-Bold" size:15.0f];
    UIFont *font2 = [UIFont fontWithName:@"Roboto-Regular"  size:15.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style};
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font2,
                            NSParagraphStyleAttributeName:style};

    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"BUY NOW " attributes:dict1]];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"with" attributes:dict2]];

    [_btnBuyNow setAttributedTitle:attString forState:UIControlStateNormal];
    [_btnBuyNow1 setAttributedTitle:attString forState:UIControlStateNormal];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CommonInit

- (void)commonInit{
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.pullRefresh = NO;

    _arrImages = [[NSMutableArray alloc]init];
    _txtDesc.editable = NO;
    if (app.isDetail) {

    }else{
        _firstView.hidden = _secondView.hidden = _fourthView.hidden = YES;
        _thirdView.hidden = NO;
    }

    CGRect newframe=_shareView.frame;
    newframe.origin.y = [UIScreen mainScreen].bounds.size.height;
    _shareView.frame=newframe;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.blackView addGestureRecognizer:tapGestureRecognizer];

    [self getProductDetail];
}

- (void)getProductDetail{
    [_arrImages removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[WebClient sharedClient]getProductDetail:@{@"product_id":[NSNumber numberWithInteger:_product.intProductID]} success:^(NSDictionary *dictionary) {
        NSLog(@"Dictionary : %@",dictionary);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(dictionary){
            if([dictionary[@"success"] boolValue]){
                NSArray *listResult = dictionary[@"details"];
                if(listResult.count!=0){
                    [listResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        _productDetail = [ProductDetail dataWithInfo:obj];
                    }];
                    [_arrImages addObjectsFromArray:[_productDetail.arrImages valueForKey:@"image_name"]];
                    _pageControl.numberOfPages = _arrImages.count;

                    NSMutableString *productName = [_productDetail.strName mutableCopy];
                    [productName enumerateSubstringsInRange:NSMakeRange(0, [productName length])
                                                    options:NSStringEnumerationByWords
                                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                     [productName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                withString:[[substring substringToIndex:1] uppercaseString]];
                                                 }];

//                    NSString *productName = [NSString stringWithFormat:@"%@%@",[[_productDetail.strName substringToIndex:1] uppercaseString],[[_productDetail.strName substringFromIndex:1] lowercaseString] ];
                    _lblName.text = productName;

                    _lblDate.text = [NSString stringWithFormat:@"Posted on: %@",[Helper dateStringFromString:_productDetail.strDate format:@"yyyy-mm-dd" toFormat:kDateFormat]]  ;
                    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
                    [currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    
                    _lblPrice.text = [NSString stringWithFormat:@"$%@",[currencyFormatter stringFromNumber:[NSNumber numberWithInteger:[_productDetail.strPrice integerValue]]]];

                    if (_productDetail.isPayPal)
                    {
                        _btnBuyNow.hidden = _btnPayPal.hidden = _imgPayPal.hidden = _secondView.hidden = NO;
                        _firstView.hidden = YES;
                    }
                    else{
                        _btnBuyNow.hidden = _btnPayPal.hidden = _imgPayPal.hidden = YES;
                    }

                    if (app.isDetail) {

                    }else{
                        if (_productDetail.isPayPal){
                            _btnBuyNow1.hidden = _imgPayPal1.hidden = _fourthView.hidden = NO;
                            _btnBuyNow.hidden = _imgPayPal.hidden = YES;
                        }
                        else{
                            _btnBuyNow1.hidden = _imgPayPal1.hidden = YES;
                            _btnBuyNow.hidden = _imgPayPal.hidden = YES;
                        }
                    }

                    NSString *result = [_productDetail.strDesc stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                    result = [[result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]trimWhiteSpace];
                    
                    NSString *productDesc = [NSString stringWithFormat:@"%@%@",[[result substringToIndex:1] uppercaseString],[[result substringFromIndex:1] lowercaseString] ];

                    _lblLink.text = [_productDetail.strProductURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    _txtDesc.text = [productDesc trimWhiteSpace];
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",_productDetail.strFBID]];
                    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                    UIImage *fbImage = [UIImage imageWithData:imageData];

                    if ([_productDetail.strFBID isEqualToString:@""]) {
                        [_btnSellerSnap setImage:[UIImage imageNamed:@"seller_snap_icon"] forState:UIControlStateNormal];
                        [_btnSellerSnap1 setImage:[UIImage imageNamed:@"seller_snap_icon"] forState:UIControlStateNormal];
                    }else{

                        UIImage *img = [fbImage resizedImage:CGSizeMake(24, 24) interpolationQuality:kCGInterpolationHigh];

                        UIImage *img1 = [self makeRoundedImage:img radius:12.0];


                        [_btnSellerSnap setImage:img1 forState:UIControlStateNormal];
                        [_btnSellerSnap1 setImage:img1 forState:UIControlStateNormal];

                        _btnSellerSnap.contentMode = UIViewContentModeScaleAspectFit;
                        _btnSellerSnap1.contentMode = UIViewContentModeScaleAspectFit;

                    }
                    [_collectionView reloadData];
                }
            }else {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
            }
        }else{
            [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

-(UIImage *)makeRoundedImage:(UIImage *)image radius:(float)r;
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, image.size}
                                cornerRadius:r] addClip];
    [image drawInRect:(CGRect){CGPointZero, image.size}];
    [image drawAtPoint:CGPointMake(image.size.width,0)];

    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;

//    CALayer *imageLayer = [CALayer layer];
//    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
//    imageLayer.contents = (id) image.CGImage;
//
//    imageLayer.borderColor = [UIColor whiteColor].CGColor;
//    imageLayer.borderWidth = 1.0;
//    imageLayer.masksToBounds = YES;
//    imageLayer.cornerRadius = r;
//
//    UIGraphicsBeginImageContext(image.size);
//    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return roundedImage;
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self btnCancelTapped:nil];
}

#pragma mark - Button Click event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnContactSellerTapped:(id)sender{
    ContactSellerViewController *contactSellerViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ContactSellerViewController"];
    contactSellerViewController.productDetail = _productDetail;
    [self.navigationController pushViewController:contactSellerViewController animated:YES];
}

- (IBAction)btnSellerSnapsTapped:(id)sender{
    SellerSnapsViewController *sellerSnapsViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"SellerSnapsViewController"];
    sellerSnapsViewController.productDetail = _productDetail;
    app.isShowMember = YES;
    [self.navigationController pushViewController:sellerSnapsViewController animated:YES];
}

- (IBAction)btnBuyNowTapped:(id)sender{
    ConfirmOrderVC *confirmOrderVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmOrderVC"];
    confirmOrderVC.productDetail = _productDetail;
    [self.navigationController pushViewController:confirmOrderVC animated:YES];
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

//    [[SocialMedia sharedInstance] shareViaFacebook:self params:@{@"Message":[NSString stringWithFormat:sharingMsg,_lblName.text,_lblPrice.text,_lblLink.text]} callback:^(BOOL success, NSError *error) {
//        if(error){
//            [Helper siAlertView:titleFail msg:error.localizedDescription];
//        }else {
//            [self displaySuccessAlertView:kFacebookPostSuccessMsg];
//        }
//    }];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if ([FBSDKAccessToken currentAccessToken] != nil)
    {
        NSDictionary *dict =  @{@"message":[NSString stringWithFormat:sharingMsg,_lblName.text,_lblPrice.text,_lblLink.text]};
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

                     NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_lblName.text,_lblPrice.text,_lblLink.text]};
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

                              NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_lblName.text,_lblPrice.text,_lblLink.text]};
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
    [[SocialMedia sharedInstance] shareViaTwitter:self params:@{@"Message":[NSString stringWithFormat:TWSharingMsg,_lblName.text,_lblPrice.text,_lblLink.text]} callback:^(BOOL success, NSError *error) {
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
//                NSDictionary *message = @{@"status":[NSString stringWithFormat:sharingMsg,_lblName.text,_lblPrice.text,_lblLink.text]};
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
//                        [Helper siAlertView:titleSuccess msg:kTwitterPostSuccessMsg];
//                        [self btnCancelTapped:nil];
//                    }else{
//                        [Helper siAlertView:titleSuccess msg:kTwitterPostSuccessMsg];
//                        [self btnCancelTapped:nil];
//                    }
//
//                }];
//
//            }else
//            {
//                [Helper siAlertView:titleFail msg:@"Please setup your twitter account from settings."];
//                [self btnCancelTapped:nil];
//            }
//        }
//    }];
}

- (IBAction)btnEmailTapped:(id)sender{
    [[SocialMedia sharedInstance] shareViaEmail:self params:@{@"subject":appName,@"message":[NSString stringWithFormat:emailSharingMsg,_lblName.text,_lblPrice.text,_lblLink.text]} callback:^(BOOL success, NSError *error) {
        if(error){
            [Helper siAlertView:titleFail msg:error.localizedDescription];
        }else {
           // [self displaySuccessAlertView:@"Email is sent successfully."];
        }
    }];
}

- (IBAction)btnSpamTapped:(id)sender{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:@"Are you sure you want to report this product as spam?"];
    alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                              [[WebClient sharedClient]spamReport:@{@"selleritemid":[NSNumber numberWithInteger:_product.intProductID]} success:^(NSDictionary *dictionary) {
                                  NSLog(@"Dictionary : %@",dictionary);
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  if(dictionary){
                                      if([dictionary[@"success"] boolValue]){
                                          [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                                      }else {
                                          [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
                                      }
                                  }else{
                                      [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
                                  }
                              } failure:^(NSError *error) {
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
                              }];
                          }];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
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
                              //[self btnCancelTapped:nil];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

#pragma mark - UICollectionView Delegate Method

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
    return _arrImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSURL *imgURL = [NSURL URLWithString:[_arrImages[indexPath.row] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//
//    indicator.center = cell.center;
//
//    [cell addSubview:indicator];
//    [indicator startAnimating];
//
//    [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
//        [indicator stopAnimating];
//        [indicator removeFromSuperview];
//        cell.imgView.image = image;
//    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
//        cell.imgView.image = [UIImage imageNamed:@"no-image"];
//        [indicator stopAnimating];
//        [indicator removeFromSuperview];
//    }];

    [cell.imgView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image != nil && !error)
             [cell.imgView setImage:image];

     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    cell.imgView.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return _collectionView.frame.size;
}

#pragma mark - Scroll View delegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageControl.currentPage = self.collectionView.contentOffset.x / _collectionView.frame.size.width;
}

@end
