//
//  AddItemViewController.m
//  SnapShotSale
//
//  Created by Manish on 11/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "AddItemViewController.h"
#import "REFrostedViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "CatListViewController.h"
#import "MSTextField.h"
#import "WebClient.h"
#import "TKAlertCenter.h"
#import "Helper.h"
#import "Common.h"
#import "Cat.h"
#import "PhotoCell.h"
#import <objc/runtime.h>
#import "ProductDetailViewController.h"
#import "ItemListViewController.h"
#import "SIAlertView.h"
#import "AdMobViewController.h"
#import "SettingViewController.h"
#import "HelpView.h"
#import "SocialMedia.h"
#import "UIActionSheet+BlockExtensions.h"
#import "UIImage+fixOrientation.h"
#import "AppDelegate.h"
#import "SubscribeView.h"
#import "LPlaceholderTextView.h"
#import "ProductListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789:,.-_"

#define sharingMsg             @"I thought you may be interested in this item on Snapshotsale.com \r\n\nProduct Name : %@ \r\nPrice : $ %@ \r\nFind this product useful? Buy it today! \r\n%@\r\n\nDownload our App today and start selling on Snapshotsale.com!"

#define TWSharingMsg           @"Product Name : %@ \r\nPrice : $ %@ \r\nFind this product useful? Buy it today! \r\n%@"

#define emailSharingMsg        @"I thought you would find the below item interesting: \r\n\nProduct Name : %@ \r\nPrice : %@ \r\nFind this product useful? Buy it today! \r\n%@\r\n\nDownload our App today and start selling on Snapshotsale.com!"

#define appName                @"SnapShotSale"

static void * kDGProgressChanged = &kDGProgressChanged;

@class GADBannerView;

@import GoogleMobileAds;

@interface AddItemViewController ()<CatListViewControllerDeleagate,UIActionSheetDelegate,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HelpViewDelegate,SubscribeViewDelegate,MBProgressHUDDelegate>
{
    BOOL done;
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet UIButton *btnAdditional;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd1;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd2;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd3;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd4;
@property (strong, nonatomic) IBOutlet UIButton *btnPayPal;

@property (strong, nonatomic) IBOutlet UILabel *lblLink;
@property (strong, nonatomic) IBOutlet UILabel *lblShippingDollar;

@property (strong, nonatomic) IBOutlet MSTextField *txtProductName;
@property (strong, nonatomic) IBOutlet MSTextField *txtCategory;
@property (strong, nonatomic) IBOutlet MSTextField *txtPrice;
@property (strong, nonatomic) IBOutlet MSTextField *txtShippingPrice;
@property (strong, nonatomic) IBOutlet MSTextField *txtPayPalID;

@property (strong, nonatomic) IBOutlet LPlaceholderTextView *txtDesc;

@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UIView *blackView;
@property (strong, nonatomic) IBOutlet UIView *paypalView;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray *arrImages;
@property (strong, nonatomic) NSMutableArray *arrTemp;
@property (strong, nonatomic) NSMutableArray *arrItems;

@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSString *filePath;
@property (assign, nonatomic) NSInteger flag;
@property (strong, nonatomic) Cat *catList;
@property (strong, nonatomic) HelpView *helpView;
@property (strong, nonatomic) SubscribeView *guideView;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation AddItemViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getItemList];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.pullRefresh = NO;
    _arrImages = [[NSMutableArray alloc]init];
    _arrTemp = [[NSMutableArray alloc]init];
    _arrItems = [[NSMutableArray alloc]init];

    [Helper registerKeyboardNotification:self];
    _flag = 0;
    _btnAdditional.hidden = NO;
    _txtDesc.placeholderText = @"Description";
    _txtDesc.placeholderColor = [UIColor lightGrayColor];
    [_collectionView reloadData];
    
    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
        self.bannerView.hidden = YES;
        CGRect newframe=_detailView.frame;
        newframe.size.height = [UIScreen mainScreen].bounds.size.height-64;
        _detailView.frame=newframe;
    }else{
        self.bannerView.adUnitID = kAdUnitIDFilal;
        self.bannerView.rootViewController = self;

        GADRequest *request = [GADRequest request];
        request.testDevices = @[kTestDevice];
        [self.bannerView loadRequest:request];
    }

    if ([Helper getIntFromNSUserDefaults:kHelpViewDisplay] == 0) {
        _helpView = [[NSBundle mainBundle] loadNibNamed:@"HelpView" owner:self options:nil][0];
        _helpView.delegate = self;
        [self.view addSubview:_helpView];
        _helpView.frame = self.view.bounds;
    }
    CGRect newframe=_shareView.frame;
    newframe.origin.y = [UIScreen mainScreen].bounds.size.height;
    _shareView.frame=newframe;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.blackView addGestureRecognizer:tapGestureRecognizer];
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self btnCancelActionTapped:nil];
}

#pragma mark - Get Item List

- (void)getItemList{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WebClient sharedClient]getSellerItemList:@{@"seller_id":[NSNumber numberWithInteger:[User sharedUser].intSellerId]} success:^(NSDictionary *dictionary) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Item List %@",dictionary);
        if(dictionary){
            if([dictionary[@"success"] boolValue]){
                [_arrItems removeAllObjects];
                NSArray *listResult = dictionary[@"products"];
                if(listResult.count!=0){
                    [listResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Product *item = [Product dataWithInfo:obj];
                        [_arrItems addObject:item];
                    }];
                }else {
                    NSLog(@"Data Not Found");
                }
                [Helper addIntToUserDefaults:_arrItems.count forKey:@"TotalCount"];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

#pragma mark - Button Tapped Event

- (IBAction)doneClicked:(id)sender{
    if (IPHONE4 || IPHONE5) {
        [_scrollView setContentOffset:CGPointZero animated:YES];
    }
    [self.view endEditing:YES];
}

- (IBAction)btnDoneTapped:(id)sender{
    [_txtDesc resignFirstResponder];
}

- (IBAction)btnMenuTapped:(id)sender{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)btnAdditionalTapped:(id)sender{
    _btnAdd1.hidden = _btnAdd2.hidden = _btnAdd3.hidden = _btnAdd4.hidden = NO;
    _btnAdditional.hidden = YES;
}

- (IBAction)btnAddTapped:(UIButton *)sender{
    
    UIImage *strURL = objc_getAssociatedObject(sender, @"Image");
    if (sender.selected) {
        [_arrImages removeObject:strURL];
        if (sender.tag == 0) {
            [_btnAdd1 setBackgroundImage:nil forState:UIControlStateNormal];
            [_btnAdd1 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
            _btnAdd1.selected = NO;
        }else if (sender.tag == 1) {
            [_btnAdd2 setBackgroundImage:nil forState:UIControlStateNormal];
            [_btnAdd2 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
            _btnAdd2.selected = NO;
        }else if (sender.tag == 2) {
            [_btnAdd3 setBackgroundImage:nil forState:UIControlStateNormal];
            [_btnAdd3 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
            _btnAdd3.selected = NO;
        }else if (sender.tag == 3) {
            [_btnAdd4 setBackgroundImage:nil forState:UIControlStateNormal];
            [_btnAdd4 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
            _btnAdd4.selected = NO;
        }
        [_collectionView reloadData];
    }else{
        [self showActionSheet];
        _flag = sender.tag;
        sender.selected = YES;
    }
}

- (IBAction)btnCategoryTapped:(id)sender{
    [self hideKeyboard];
    [self resignFields];
    [_txtProductName resignFirstResponder];
    CatListViewController *catListViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CatListViewController"];
    catListViewController.strTitle = @"Select Category";
    catListViewController.delegate = self;
    [self.navigationController pushViewController:catListViewController animated:YES];
}

- (IBAction)btnPostDoneTapped:(id)sender{
    [self hideKeyboard];
    [self resignFields];
    if ([self isValidLoginDetails]) {
        if ([Helper getIntFromNSUserDefaults:@"TotalCount"] >= [Helper getIntFromNSUserDefaults:@"TotalQty"]){
            [self subscribeMessage];
        }else{
            [self uploadPicture];
        }
    }
}

- (IBAction)btnDoneNextTapped:(id)sender{
    [self hideKeyboard];
    [self resignFields];
    if ([self isValidLoginDetails]) {
        if ([Helper getIntFromNSUserDefaults:@"TotalCount"] >= [Helper getIntFromNSUserDefaults:@"TotalQty"]){
            [self subscribeMessage];
        }else{
            [self uploadImages];
        }
    }
}

- (IBAction)btnPayPalTapped:(id)sender{
    if ([[User sharedUser].strPayPalID isEqualToString:@""]) {
        _blackView.hidden = _paypalView.hidden = NO;
        _blackView.alpha = 0;
        [UIView animateWithDuration:0.6
                         animations:^{
                             _blackView.alpha = 0.8;
                         }
                         completion:^(BOOL finished){

                         }];
    }else{
        _btnPayPal.selected = !_btnPayPal.selected;

        if (_btnPayPal.selected) {
            _txtShippingPrice.hidden = _lblShippingDollar.hidden = NO;
            if (IPHONE4 || IPHONE5) {
                _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 138, _txtPrice.frame.size.height);
            }else if (IPHONE6){
                _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 160, _txtPrice.frame.size.height);
            }else if (IPHONE6PLUS){
                _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 180, _txtPrice.frame.size.height);
            }
        }else{
            _txtShippingPrice.hidden = _lblShippingDollar.hidden = YES;
            if (IPHONE4 || IPHONE5) {
                _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 290, _txtPrice.frame.size.height);
            }else if (IPHONE6){
                _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 345, _txtPrice.frame.size.height);
            }else if (IPHONE6PLUS){
                _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 384, _txtPrice.frame.size.height);
            }
        }
    }
}

- (IBAction)btnPayPalAddTapped:(id)sender{
    if ([self isValidPayPalID]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WebClient sharedClient] addPayPalID:@{@"selleraccountid":[NSNumber numberWithInteger:[User sharedUser].intSellerId], @"paypal_id":_txtPayPalID.text} success:^(NSDictionary *dictionary) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([dictionary[@"success"] boolValue]) {
                [User sharedUser].strPayPalID = _txtPayPalID.text;
                [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                _blackView.alpha = 0.8;
                [self resignFields];
                [UIView animateWithDuration:0.6
                                 animations:^{
                                     _blackView.alpha = 0;
                                 }
                                 completion:^(BOOL finished){
                                     _blackView.hidden = _paypalView.hidden = YES;
                                 }];
            }else{
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
        }];
    }
}

- (IBAction)btnPayPalCancelTapped:(id)sender{
    [self resignFields];
    _blackView.alpha = 0.8;
    [UIView animateWithDuration:0.6
                     animations:^{
                         _blackView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         _blackView.hidden = _paypalView.hidden = YES;
                     }];
}

- (void)uploadImages {
    NSString *strPrice = [[_txtPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];

    NSString *strShippingPrice = [[_txtShippingPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];

    if ([strShippingPrice isEqualToString:@""]) {
        strShippingPrice = @"0";
    }

    NSString *strPayPal;
    if (_btnPayPal.selected)
        strPayPal = @"1";
    else
        strPayPal = @"0";

    NSString *decodedString = [[[_txtDesc.text trimWhiteSpace] stringByReplacingOccurrencesOfString:@" " withString:@"+"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSString *stringUrl =@"https://software.snapshotsale.com/webservices/add_product.php?";
    NSString *stringUrl = @"http://dev-imaginovation.net/snapshotsale/webservices/add_product.php?";

    NSDictionary *parameters  = @{@"selleraccountid":[NSNumber numberWithInteger:[User sharedUser].intSellerId],@"userid":[User sharedUser].strUserID,@"item_name":_txtProductName.text,@"category_id":[NSNumber numberWithInteger:_catList.intCatID],@"category_name":_catList.strCatName,@"item_description":decodedString,@"item_price":strPrice,@"shipping_price":strShippingPrice,@"paypal":strPayPal};
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:stringUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i<_arrImages.count; i++) {
            NSData *pngData = UIImageJPEGRepresentation([_arrImages objectAtIndex:i],0.8);
            NSString *file = [[Helper getStringFromDate:[NSDate date] withFormat:@"hhmmss"] stringByAppendingString:[NSString stringWithFormat:@"%d.png",i]];

            [formData appendPartWithFileData:pngData name:[NSString stringWithFormat:@"image%d",i+1] fileName:file mimeType:@"image/jpeg"];
        }
    } error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSDictionary *dict;
                                         [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                         if([responseObject isKindOfClass:[NSDictionary class]]) {
                                             dict = responseObject;
                                         }
                                         else {
                                             dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                                         }
                                         if([[dict objectForKey:@"success"] boolValue]) {
                                             done = NO;
                                             _lblLink.text = [dict[@"producturl"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                             [self shareItem];
                                             User *user = [Helper getCustomObjectToUserDefaults:kUserInformation];
                                             user.intTotalCount =  user.intTotalCount + 1;
                                             [Helper addCustomObjectToUserDefaults:user key:kUserInformation];
                                             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                         }
                                         else {
                                             
                                         }
                                         [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         [self clearFields];
                                         [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                     }];
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        long prog = (100*totalBytesWritten)/totalBytesExpectedToWrite;
        long currentProgress = (prog * _arrImages.count)/100;
        if (currentProgress >= _arrImages.count) {
            currentProgress = currentProgress - 1;
        }
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Please Wait";
        HUD.detailsLabelText = [NSString stringWithFormat:@"%ld/%ld image uploading",currentProgress+1,(unsigned long)_arrImages.count];
        HUD.square = YES;
        [HUD show:YES];
    }];
    
    [operation start];
}

- (void)uploadPicture{
    NSString *strPrice = [[_txtPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];

    NSString *strShippingPrice = [[_txtShippingPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];

    if ([strShippingPrice isEqualToString:@""]) {
        strShippingPrice = @"0";
    }

    NSString *strPayPal;
    if (_btnPayPal.selected)
        strPayPal = @"1";
    else
        strPayPal = @"0";

    NSString *decodedString = [[[_txtDesc.text trimWhiteSpace] stringByReplacingOccurrencesOfString:@" " withString:@"+"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSString *stringUrl = @"https://software.snapshotsale.com/webservices/add_product.php?";
    NSString *stringUrl = @"http://dev-imaginovation.net/snapshotsale/webservices/add_product.php?";

    NSDictionary *parameters  = @{@"selleraccountid":[NSNumber numberWithInteger:[User sharedUser].intSellerId],@"userid":[User sharedUser].strUserID,@"item_name":_txtProductName.text,@"category_id":[NSNumber numberWithInteger:_catList.intCatID],@"category_name":_catList.strCatName,@"item_description":decodedString,@"item_price":strPrice,@"shipping_price":strShippingPrice,@"paypal":strPayPal};
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:stringUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i<_arrImages.count; i++) {
            NSData *pngData = UIImageJPEGRepresentation([_arrImages objectAtIndex:i],0.8);
            NSString *file = [[Helper getStringFromDate:[NSDate date] withFormat:@"hhmmss"] stringByAppendingString:[NSString stringWithFormat:@"%d.png",i]];

            [formData appendPartWithFileData:pngData name:[NSString stringWithFormat:@"image%d",i+1] fileName:file mimeType:@"image/jpeg"];
        }
    } error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                         NSDictionary *dict;
                                         if([responseObject isKindOfClass:[NSDictionary class]]) {
                                             dict = responseObject;
                                         }
                                         else {
                                             dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                                         }
                                         if([[dict objectForKey:@"success"] boolValue]) {
                                             _lblLink.text = [dict[@"producturl"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                             done = YES;
                                             [self shareItem];
                                             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                         }
                                         else {
                                             
                                         }
                                         [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [self.navigationController popViewControllerAnimated:YES];
                                         [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                     }];
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        long prog = (100*totalBytesWritten)/totalBytesExpectedToWrite;
        long currentProgress = (prog * _arrImages.count)/100;
        if (currentProgress >= _arrImages.count) {
            currentProgress = currentProgress - 1;
        }
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Please Wait";
        HUD.detailsLabelText = [NSString stringWithFormat:@"%ld/%ld image uploading",currentProgress+1,(unsigned long)_arrImages.count];
        HUD.square = YES;
        [HUD show:YES];
    }];
    [operation start];
}

- (IBAction)btnCancelTapped:(id)sender{
    [self hideKeyboard];
    [self resignFields];
    ProductListViewController *pd = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductListViewController"];
    [self.navigationController pushViewController:pd animated:YES];
}

- (void)showActionSheet{
    UIActionSheet *act=[[UIActionSheet alloc]initWithTitle:@"Upload Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Camera",@"From Photo Library", nil];
    [act showInView:self.view];
}

- (void)shareItem{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [Helper addIntToUserDefaults:[Helper getIntFromNSUserDefaults:@"TotalCount"]+1 forKey:@"TotalCount"];
    [self shareImage];
}

- (void)shareImage{
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
//    [[SocialMedia sharedInstance] shareViaFacebook:self params:@{@"Message":[NSString stringWithFormat:sharingMsg,_txtProductName.text,_txtPrice.text,_lblLink.text]} callback:^(BOOL success, NSError *error) {
//        if(error){
//            [Helper siAlertView:titleFail msg:error.localizedDescription];
//        }else {
//            [self displaySuccessAlertView:kFacebookPostSuccessMsg];
//        }
//    }];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if ([FBSDKAccessToken currentAccessToken] != nil)
    {
        NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_txtProductName.text,_txtPrice.text,_lblLink.text]};
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (error != nil) {
                 NSLog(@"%@",error.localizedDescription);
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [Helper siAlertView:titleFail msg:error.localizedDescription];
                 [self btnCancelActionTapped:nil];
             }else
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [Helper siAlertView:titleSuccess msg:kFacebookPostSuccessMsg];
                 [self btnCancelActionTapped:nil];
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
                 [self btnCancelActionTapped:nil];
                 [loginManager logOut];
             }
             else if (result.isCancelled)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self btnCancelActionTapped:nil];
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

                     NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_txtProductName.text,_txtPrice.text,_lblLink.text]};
                     FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
                     [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                      {
                          if (error != nil) {
                              NSLog(@"%@",error.localizedDescription);
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [Helper siAlertView:titleFail msg:error.localizedDescription];
                              [self btnCancelActionTapped:nil];
                          }else
                          {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [Helper siAlertView:titleSuccess msg:kFacebookPostSuccessMsg];
                              [self btnCancelActionTapped:nil];
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
                              [self btnCancelActionTapped:nil];
                              [loginManager logOut];
                          }
                          else if (result.isCancelled)
                          {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self btnCancelActionTapped:nil];
                              [loginManager logOut];
                          }
                          else
                          {
                              NSTimeInterval addTimeInterval = 60*60*24*365*50;
                              NSDate *expireDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];
                              NSDate *refreshDate = [[NSDate date] dateByAddingTimeInterval:addTimeInterval];

                              FBSDKAccessToken *newAccessToken = [[FBSDKAccessToken alloc] initWithTokenString:[[FBSDKAccessToken currentAccessToken] tokenString] permissions:nil declinedPermissions:nil appID:FACEBOOK_ID userID:[[FBSDKAccessToken currentAccessToken] userID] expirationDate:expireDate refreshDate:refreshDate];
                              [FBSDKAccessToken setCurrentAccessToken:newAccessToken];

                              NSDictionary *dict = @{@"message":[NSString stringWithFormat:sharingMsg,_txtProductName.text,_txtPrice.text,_lblLink.text]};
                              FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me/feed" parameters:dict HTTPMethod:@"POST"];
                              [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                               {
                                   if (error != nil) {
                                       NSLog(@"%@",error.localizedDescription);
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       [Helper siAlertView:titleFail msg:error.localizedDescription];
                                       [self btnCancelActionTapped:nil];
                                   }else
                                   {
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       [Helper siAlertView:titleSuccess msg:kFacebookPostSuccessMsg];
                                       [self btnCancelActionTapped:nil];
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
    [[SocialMedia sharedInstance] shareViaTwitter:self params:@{@"Message":[NSString stringWithFormat:TWSharingMsg,_txtProductName.text,_txtPrice.text,_lblLink.text]} callback:^(BOOL success, NSError *error) {
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
//                NSDictionary *message = @{@"status":[NSString stringWithFormat:sharingMsg,_txtProductName.text,_txtPrice.text,_lblLink.text]};
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
//                        [self btnCancelActionTapped:nil];
//                    }else{
//                        [Helper siAlertView:titleSuccess msg:kTwitterPostSuccessMsg];
//                        [self btnCancelActionTapped:nil];
//                    }
//
//                }];
//
//            }else
//            {
//                [Helper siAlertView:titleFail msg:@"Please setup your twitter account from settings."];
//                [self btnCancelActionTapped:nil];
//            }
//        }
//    }];
}

- (IBAction)btnEmailTapped:(id)sender{
    [[SocialMedia sharedInstance] shareViaEmail:self params:@{@"subject":appName,@"message":[NSString stringWithFormat:emailSharingMsg,_txtProductName.text,_txtPrice.text,_lblLink.text]} callback:^(BOOL success, NSError *error) {
        if(error){
            [Helper siAlertView:titleFail msg:error.localizedDescription];
        }else {
           // [self displaySuccessAlertView:@"Email is sent successfully."];
        }
    }];
}

- (IBAction)btnCancelActionTapped:(id)sender{
    if (done) {
        ItemListViewController *list = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemListViewController"];
        [self.navigationController pushViewController:list animated:YES];
    }else{
        [self clearFields];
    }
    [UIView animateWithDuration:0.4 animations:^{
        CGRect newframe=_shareView.frame;
        newframe.origin.y = [UIScreen mainScreen].bounds.size.height;
        _shareView.frame=newframe;
    } completion:^(BOOL finished) {
        
    }];
    [self resignFields];
    _blackView.alpha = 0.8;
    [UIView animateWithDuration:0.6
                     animations:^{
                         _blackView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         _blackView.hidden = _paypalView.hidden = YES;
                     }];
}

- (void)displaySuccessAlertView:(NSString *)msgSuccess{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleSuccess andMessage:[@"Product saved successfully!"stringByAppendingString:msgSuccess]];
    alertView.buttonsListStyle = SIAlertViewButtonsListStyleRows;
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              if (done) {
                                  ItemListViewController *list = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemListViewController"];
                                  [self.navigationController pushViewController:list animated:YES];
                              }else{
                                  [self clearFields];
                              }
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

- (void)subscribeMessage{
    [Helper addIntToUserDefaults:1 forKey:@"subscribe"];
    
    if ([Helper getIntFromNSUserDefaults:@"subscribe"] == 1) {
        _guideView = [[NSBundle mainBundle] loadNibNamed:@"SubscribeView" owner:self options:nil][0];
        _guideView.delegate = self;
        [self.view addSubview:_guideView];
        _guideView.frame = self.view.bounds;
    }
}

#pragma mark - UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        @try
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }
        @catch (NSException *exception)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera is not available." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if (buttonIndex ==1){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - image choose from gallery

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [self scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [_arrImages addObject:img];
    
    if (_flag == 0) {
        [_btnAdd1 setBackgroundImage:img forState:UIControlStateNormal];
        [_btnAdd1 setTag:_flag];
        objc_setAssociatedObject(_btnAdd1, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd1 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        _btnAdd1.selected = YES;
    }else if (_flag == 1){
        [_btnAdd2 setBackgroundImage:img forState:UIControlStateNormal];
        [_btnAdd2 setTag:_flag];
        objc_setAssociatedObject(_btnAdd2, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd2 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        _btnAdd2.selected = YES;
    }else if (_flag == 2){
        [_btnAdd3 setBackgroundImage:img forState:UIControlStateNormal];
        [_btnAdd3 setTag:_flag];
        objc_setAssociatedObject(_btnAdd3, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd3 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        _btnAdd3.selected = YES;
    }else if (_flag == 3){
        [_btnAdd4 setBackgroundImage:img forState:UIControlStateNormal];
        [_btnAdd4 setTag:_flag];
        objc_setAssociatedObject(_btnAdd4, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd4 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        _btnAdd4.selected = YES;
    }
    _pageControl.numberOfPages = _arrImages.count;
    [_collectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Delegate Method

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
    if (_arrImages.count == 0) {
        _pageControl.numberOfPages = 0;
        return _arrTemp.count + 1;
    }else{
        _pageControl.numberOfPages = _arrImages.count;
        return _arrImages.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    if (_arrImages.count == 0) {
        if ([Helper getIntFromNSUserDefaults:kHelpViewDisplay] == 0) {
            cell.imgPhoto.image = [UIImage imageNamed:@""];
            [cell.btnPhoto setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }else{
            cell.imgPhoto.image = [UIImage imageNamed:@""];
            [cell.btnPhoto setImage:[UIImage imageNamed:@"add_photo"] forState:UIControlStateNormal];
        }
    }else{
        cell.imgPhoto.image = _arrImages[indexPath.row];
        cell.imgPhoto.contentMode = UIViewContentModeScaleAspectFit;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_arrImages.count == 0) {
        [self showActionSheet];
        _flag =0;
        _btnAdd1.selected = YES;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return _collectionView.frame.size;
}

#pragma mark - Scroll View delegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageControl.currentPage = self.collectionView.contentOffset.x / _collectionView.frame.size.width;
}

#pragma mark - Validate Add Information

- (BOOL)isValidLoginDetails{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];

    NSString *filtered = [[_txtProductName.text componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];

    if ([_txtProductName.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterProductName image:kErrorImage];
        return NO;
    }else{
        if ([_txtProductName.text isEqualToString:filtered]) {
            NSLog (@"Product Name is Valid");
        } else {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidProductName image:kErrorImage];
            return NO;
        }
    }

    if ([_txtCategory.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgSelectCategory image:kErrorImage];
        return NO;
    }else if ([_txtPrice.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterPrice image:kErrorImage];
        return NO;
    }else if ([_txtDesc.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterDesc image:kErrorImage];
        return NO;
    }else if (_arrImages.count == 0){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgSelectImages image:kErrorImage];
        return NO;
    }else if ([_txtPrice.text integerValue] == 0){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgPriceNotZero image:kErrorImage];
        return NO;
    }

    if (_btnPayPal.selected) {
        if ([_txtShippingPrice.text isEmptyString]) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterShippingPrice image:kErrorImage];
            return NO;
        }
    }

    return YES;
}

- (BOOL)isValidPayPalID{
    if ([_txtPayPalID.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterPayPalID image:kErrorImage];
        return NO;
    }
    return YES;
}

#pragma mark - UITextView Delegate Methods

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textView.inputAccessoryView = keyboardDoneButtonView;

    CGRect frame = _detailView.frame;
        frame.origin.y = -140;

    [UIView animateWithDuration:0.4 animations:^{
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self hideKeyboard];
    return YES;
}

#pragma mark - UITextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = 64;
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _txtPrice || textField == _txtShippingPrice) {
        UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
        [keyboardDoneButtonView sizeToFit];
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleBordered target:self
                                                                      action:@selector(doneClicked:)];
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
        textField.inputAccessoryView = keyboardDoneButtonView;
    }
    
    CGRect frame = _detailView.frame;
    if (textField == _txtProductName) {
        frame.origin.y = -40;
    }else if (textField == _txtPrice || textField == _txtShippingPrice){
        frame.origin.y = -140;
    }

    [UIView animateWithDuration:0.4 animations:^{
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _txtPrice || textField == _txtShippingPrice) {
        if (([string isEqualToString:@"0"] || [string isEqualToString:@""]) && [textField.text rangeOfString:@"."].location < range.location) {
            return YES;
        }
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        bool isNumeric = [string isEqualToString:filtered];
        
        if (isNumeric ||
            [string isEqualToString:@""] ||
            ([string isEqualToString:@"."] &&
             [textField.text rangeOfString:@"."].location == NSNotFound)) {
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [formatter setMaximumFractionDigits:10];
                
                NSString *combinedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
                NSString *numberWithoutCommas = [combinedText stringByReplacingOccurrencesOfString:@"," withString:@""];
                NSNumber *number = [formatter numberFromString:numberWithoutCommas];
                
                NSString *formattedString = [formatter stringFromNumber:number];
                if ([string isEqualToString:@"."] &&
                    range.location == textField.text.length) {
                    formattedString = [formattedString stringByAppendingString:@"."];
                }
                textField.text = formattedString;
            }
        return NO;
    }
    return YES;
}

- (void)resignFields{
    [_txtProductName resignFirstResponder];
    [_txtCategory resignFirstResponder];
    [_txtPrice resignFirstResponder];
    [_txtShippingPrice resignFirstResponder];
    [_txtDesc resignFirstResponder];
    [_txtPayPalID resignFirstResponder];
}

- (void)clearFields{
    _txtProductName.text = _txtCategory.text = _txtPrice.text = _txtShippingPrice.text = _txtDesc.text = @"";
    _btnPayPal.selected = NO;
    _txtShippingPrice.hidden = _lblShippingDollar.hidden = YES;
    if (IPHONE4 || IPHONE5) {
        _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 290, _txtPrice.frame.size.height);
    }else if (IPHONE6){
        _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 345, _txtPrice.frame.size.height);
    }else if (IPHONE6PLUS){
        _txtPrice.frame = CGRectMake(_txtPrice.frame.origin.x, _txtPrice.frame.origin.y, 384, _txtPrice.frame.size.height);
    }

    [_btnAdd1 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_btnAdd2 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_btnAdd3 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_btnAdd4 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    [_btnAdd1 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
    [_btnAdd2 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
    [_btnAdd3 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
    [_btnAdd4 setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];

    [_arrImages removeAllObjects];
    [_collectionView reloadData];
}

#pragma mark - Keyboard Notifications

- (void)sfkeyboardWillHide:(NSNotification*)notification{
    [self hideKeyboard];
}

- (void)sfkeyboardWillShow:(NSNotification*)notification{
    
}

- (void)hideKeyboard{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = 64;
        _detailView.frame = frame;
    }];
    [UIView commitAnimations];
}

#pragma mark - Delegate Method

- (void)catListViewController:(CatListViewController *)controller categoryList:(Cat *)categoryList{
    _catList = categoryList;
    _txtCategory.text = categoryList.strCatName;
}

- (void)helpView:(HelpView *)view{
    [view removeFromSuperview];
    [Helper addIntToUserDefaults:1 forKey:kHelpViewDisplay];
    [_collectionView reloadData];
    [self showActionSheet];
}

- (void)subView:(SubscribeView *)view{
    [self removeFromParentViewController];
}

#pragma mark - UIImage Orientation

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = [[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale];
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (void)popUpZoomIn:(PhotoCell *)cell{
    PhotoCell *cellPhoto = (PhotoCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:0];
    
    cellPhoto.btnPhoto.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7001, 0.7001);
    [UIView animateWithDuration:1.0
                     animations:^{
                         cellPhoto.btnPhoto.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     } completion:^(BOOL finished) {
                         [self popZoomOut:cellPhoto];
                     }];
}

- (void)popZoomOut:(PhotoCell *)cell{
    PhotoCell *cellPhoto = (PhotoCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:0];
    [UIView animateWithDuration:1.0
                     animations:^{
                         cellPhoto.btnPhoto.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7001, 0.7001);
                     } completion:^(BOOL finished) {
                         //_viewRound.hidden = TRUE;
                         [self popUpZoomIn:cellPhoto];
                     }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
