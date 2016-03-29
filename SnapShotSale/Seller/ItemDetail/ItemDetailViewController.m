//
//  ItemDetailViewController.m
//  SnapShotSale
//
//  Created by Manish on 09/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ContactSellerViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "AdMobViewController.h"
#import "CatListViewController.h"
#import "TKAlertCenter.h"
#import "WebClient.h"
#import "ImageCell.h"
#import "Common.h"
#import "MSTextField.h"
#import "Cat.h"
#import "PhotoCell.h"
#import "Helper.h"
#import "SIAlertView.h"
#import "User.h"
#import "UIKit+AFNetworking.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "LPlaceholderTextView.h"
#import "MBProgressHUD.h"
#import "JMImageCache.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface ItemDetailViewController ()<CatListViewControllerDeleagate,UIActionSheetDelegate,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    AppDelegate *app;
}

@property (weak, nonatomic) IBOutlet UIButton *btnAdd1;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd2;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd3;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd4;
@property (strong, nonatomic) IBOutlet UIButton *btnPayPal;

@property (strong, nonatomic) IBOutlet MSTextField *txtProductName;
@property (strong, nonatomic) IBOutlet MSTextField *txtCategory;
@property (strong, nonatomic) IBOutlet MSTextField *txtPrice;
@property (strong, nonatomic) IBOutlet MSTextField *txtShippingPrice;
@property (strong, nonatomic) IBOutlet MSTextField *txtPayPalID;

@property (strong, nonatomic) IBOutlet LPlaceholderTextView *txtDesc;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *lblDollar;
@property (strong, nonatomic) IBOutlet UILabel *lblShippingDollar;

@property (strong, nonatomic) NSMutableArray *arrImages;
@property (strong, nonatomic) NSMutableArray *arrDeleteImg;
@property (strong, nonatomic) NSMutableArray *arrEditImg;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIView *blackView;
@property (strong, nonatomic) IBOutlet UIView *paypalView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSString *filePath;
@property (assign, nonatomic) NSInteger flag;
@property (assign, nonatomic) BOOL load;
@property (assign, nonatomic) BOOL temp;

@property (strong, nonatomic) Cat *catList;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
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
    _flag = 0;
    _load = YES;
    _catList = nil;
    _arrImages = [[NSMutableArray alloc]init];
    _arrDeleteImg = [[NSMutableArray alloc]init];
    _arrEditImg = [[NSMutableArray alloc]init];

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

    _txtDesc.placeholderText = @"Description";
    _txtDesc.placeholderColor = [UIColor lightGrayColor];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.blackView addGestureRecognizer:tapGestureRecognizer];

    if (IPHONE6 || IPHONE6PLUS){
        _scrollView.contentSize = CGSizeMake(0, 600);
    }

    [self getProductDetail];
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self btnPayPalCancelTapped:nil];
}

- (void)getProductDetail{
    [_arrImages removeAllObjects];
 //   _btnAdd1.userInteractionEnabled = _btnAdd2.userInteractionEnabled = _btnAdd3.userInteractionEnabled = _btnAdd4.userInteractionEnabled = NO;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WebClient sharedClient]getProductDetail:@{@"product_id":[NSNumber numberWithInteger:_sellerItem.intProductID]} success:^(NSDictionary *dictionary) {
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
                    _temp = YES;
                    _pageControl.numberOfPages = _arrImages.count;

                    for (int i = 0; i<_arrImages.count; i++) {
                        NSURL *imgURL = [NSURL URLWithString:[[_arrImages objectAtIndex:i] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        if (i == 0) {
                            _btnAdd1.userInteractionEnabled = NO;
//                            [_btnAdd1 setBackgroundImageForState:UIControlStateNormal withURLRequest:[NSURLRequest requestWithURL:imgURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                 [_btnAdd1 setBackgroundImageForState:UIControlStateNormal withURL:imgURL];
//                                _btnAdd1.userInteractionEnabled = YES;
//                            } failure:^(NSError * _Nonnull error) {
//                                _btnAdd1.userInteractionEnabled = YES;
//                            }];

                            [_btnAdd1.imageView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                             {
                                 if (image != nil && !error)
                                 {
                                     [_btnAdd1 setBackgroundImage:image forState:UIControlStateNormal];
                                 }
                                 _btnAdd1.userInteractionEnabled = YES;

                             } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

                            [_btnAdd1 setTag:i];
                            objc_setAssociatedObject(_btnAdd1, @"URL", [_arrImages objectAtIndex:i], OBJC_ASSOCIATION_RETAIN);
                            [_btnAdd1 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                            _btnAdd1.selected = YES; 
                        }else if (i == 1){
                            _btnAdd2.userInteractionEnabled = NO;
//                            [_btnAdd2 setBackgroundImageForState:UIControlStateNormal withURLRequest:[NSURLRequest requestWithURL:imgURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                 [_btnAdd2 setBackgroundImageForState:UIControlStateNormal withURL:imgURL];
//                                _btnAdd2.userInteractionEnabled = YES;
//                            } failure:^(NSError * _Nonnull error) {
//                                _btnAdd2.userInteractionEnabled = YES;
//                            }];

                            [_btnAdd2.imageView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                             {
                                 if (image != nil && !error)
                                 {
                                     [_btnAdd2 setBackgroundImage:image forState:UIControlStateNormal];
                                 }
                                 _btnAdd2.userInteractionEnabled = YES;

                             } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

                            [_btnAdd2 setTag:i];
                            objc_setAssociatedObject(_btnAdd2, @"URL", [_arrImages objectAtIndex:i], OBJC_ASSOCIATION_RETAIN);
                            [_btnAdd2 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                            _btnAdd2.selected = YES;
                        }else if (i == 2){
                            _btnAdd3.userInteractionEnabled = NO;
//                            [_btnAdd3 setBackgroundImageForState:UIControlStateNormal withURLRequest:[NSURLRequest requestWithURL:imgURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                 [_btnAdd3 setBackgroundImageForState:UIControlStateNormal withURL:imgURL];
//                                _btnAdd3.userInteractionEnabled = YES;
//                            } failure:^(NSError * _Nonnull error) {
//                                _btnAdd3.userInteractionEnabled = YES;
//                            }];

                            [_btnAdd3.imageView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                             {
                                 if (image != nil && !error)
                                 {
                                     [_btnAdd3 setBackgroundImage:image forState:UIControlStateNormal];
                                 }
                                 _btnAdd3.userInteractionEnabled = YES;

                             } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

                            [_btnAdd3 setTag:i];
                            objc_setAssociatedObject(_btnAdd3, @"URL", [_arrImages objectAtIndex:i], OBJC_ASSOCIATION_RETAIN);
                            [_btnAdd3 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                            _btnAdd3.selected = YES;
                        }else if (i == 3){
                            _btnAdd4.userInteractionEnabled = NO;
//                            [_btnAdd4 setBackgroundImageForState:UIControlStateNormal withURLRequest:[NSURLRequest requestWithURL:imgURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                 [_btnAdd4 setBackgroundImageForState:UIControlStateNormal withURL:imgURL];
//                                _btnAdd4.userInteractionEnabled = YES;
//                            } failure:^(NSError * _Nonnull error) {
//                                _btnAdd4.userInteractionEnabled = YES;
//                            }];

                            [_btnAdd4.imageView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                             {
                                 if (image != nil && !error)
                                 {
                                     [_btnAdd4 setBackgroundImage:image forState:UIControlStateNormal];
                                 }
                                 _btnAdd4.userInteractionEnabled = YES;

                             } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

                            [_btnAdd4 setTag:i];
                            objc_setAssociatedObject(_btnAdd4, @"URL", [_arrImages objectAtIndex:i], OBJC_ASSOCIATION_RETAIN);
                            [_btnAdd4 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                            _btnAdd4.selected = YES;
                        }
                    }

                    NSMutableString *productName = [_productDetail.strName mutableCopy];
                    [productName enumerateSubstringsInRange:NSMakeRange(0, [productName length])
                                                    options:NSStringEnumerationByWords
                                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                     [productName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                                withString:[[substring substringToIndex:1] uppercaseString]];
                                                 }];

                    _txtProductName.text = productName;
                    _txtCategory.text = _productDetail.strCatName;
                    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
                    [currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    _txtPrice.text = [NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:[NSNumber numberWithInteger:[_productDetail.strPrice integerValue]]]];

                    _txtShippingPrice.text = [NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:[NSNumber numberWithInteger:[_productDetail.strShippingPrice integerValue]]]];

                    _btnPayPal.selected = _productDetail.isPayPal;

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

                    NSString *result = [_productDetail.strDesc stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                    result = [[result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]trimWhiteSpace];
                    _txtDesc.text = [result trimWhiteSpace];

                    _catList.strCatName = _productDetail.strCatName;
                    _catList.intCatID = _productDetail.intCatID;
                    [_collectionView reloadData];
                }
            }else {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

#pragma mark - Button Tapped Event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneClicked:(id)sender{
    [self hideKeyboard];
    [self.view endEditing:YES];
}

- (IBAction)btnDoneTapped:(id)sender{
    [_txtDesc resignFirstResponder];
}

- (IBAction)btnAddTapped:(UIButton *)sender{
    NSString *strURL = objc_getAssociatedObject(sender, @"URL");
    UIImage *img = objc_getAssociatedObject(sender, @"Image");

    if (sender.selected) {
        [_arrImages removeObject:strURL];
        if ([_arrEditImg containsObject:img]) {
            [_arrEditImg removeObject:img];
            [_arrImages removeObject:img];
        }else{
            [_arrDeleteImg addObject:[[_productDetail.arrImages objectAtIndex:sender.tag] valueForKey:@"image_id"]];
            //[_arrImages removeObject:[_arrImages objectAtIndex:sender.tag]];
        }

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
        _load = NO;
        sender.selected = YES;
    }
}

- (IBAction)btnCategoryTapped:(id)sender{
    [self hideKeyboard];
    CatListViewController *catListViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CatListViewController"];
    catListViewController.strTitle = @"Select Category";
    catListViewController.delegate = self;
    [self.navigationController pushViewController:catListViewController animated:YES];
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

- (IBAction)btnUpdateTapped:(id)sender{
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

    if ([self isValidLoginDetails]) {

        NSString *imgid1 = @"";
        NSString *imgid2 = @"";
        NSString *imgid3 = @"";
        NSString *imgid4 = @"";

        if (_arrDeleteImg.count!=0) {
            for (int i = 0; i <_arrEditImg.count; i++) {
                if (_arrDeleteImg.count!=0) {
                    if (i == 0) {
                        imgid1 = [NSString stringWithFormat:@"%@",_arrDeleteImg[0]];
                        [_arrDeleteImg removeObjectAtIndex:0];
                    }else if (i == 1){
                        imgid2 = [NSString stringWithFormat:@"%@",_arrDeleteImg[0]];
                        [_arrDeleteImg removeObjectAtIndex:0];
                    }else if (i == 2){
                        imgid3 = [NSString stringWithFormat:@"%@",_arrDeleteImg[0]];
                        [_arrDeleteImg removeObjectAtIndex:0];
                    }else if (i == 3){
                        imgid4 = [NSString stringWithFormat:@"%@",_arrDeleteImg[0]];
                        [_arrDeleteImg removeObjectAtIndex:0];
                    }
                }
            }
        }

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_arrDeleteImg options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

//        NSString *stringUrl =@"https://software.snapshotsale.com/webservices/edit_product.php?";
        NSString *stringUrl = @"http://dev-imaginovation.net/snapshotsale/webservices/edit_product.php?";

        NSDictionary *parameters  = @{@"selleritemid":[NSNumber numberWithInteger:_productDetail.intProductID], @"selleraccountid":[NSNumber numberWithInteger:[User sharedUser].intSellerId],@"userid":[User sharedUser].strUserID,@"item_name":_txtProductName.text,@"category_id":[NSNumber numberWithInteger:_productDetail.intCatID],@"category_name":_txtCategory.text,@"item_description":decodedString,@"item_price":strPrice,@"img_delete":jsonString,@"id_image1":imgid1,@"id_image2":imgid2,@"id_image3":imgid3,@"id_image4":imgid4,@"shipping_price":strShippingPrice,@"paypal":strPayPal};

        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:stringUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (int i = 0; i<_arrEditImg.count; i++) {
                NSData *pngData = UIImageJPEGRepresentation([_arrEditImg objectAtIndex:i],0.8);
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
                                                 [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             }
                                             else {

                                             }
                                             [self clearFields];
                                             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                                             [self.navigationController popViewControllerAnimated:YES];
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
}

- (IBAction)btnDeleteTapped:(id)sender{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Delete?" andMessage:@"Are you sure you want to delete?"];
    alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                              [[WebClient sharedClient] deleteItem:@{@"item_id":[NSNumber numberWithInteger:_sellerItem.intProductID]} success:^(NSDictionary *dictionary) {
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];

                                  if ([dictionary[@"success"] boolValue] == YES) {
                                      [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];

                                      [Helper addIntToUserDefaults:[Helper getIntFromNSUserDefaults:@"TotalCount"]-1 forKey:@"TotalCount"];

                                      NSLog(@"%ld",(long)[Helper getIntFromNSUserDefaults:@"TotalQty"]);
                                      NSLog(@"%ld",(long)[Helper getIntFromNSUserDefaults:@"TotalCount"]);

                                      [self.navigationController popViewControllerAnimated:YES];
                                  }else{
                                      [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showActionSheet{
    UIActionSheet *act=[[UIActionSheet alloc]initWithTitle:@"Upload Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Camera",@"From Photo Library", nil];
    [act showInView:self.view];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera is not available  " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
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
    NSString *file = [[Helper getStringFromDate:[NSDate date] withFormat:@"hhmmss"] stringByAppendingString:@".png"];
    _filePath = [file documentDirectory];
    [_arrImages addObject:img];
    [_arrEditImg addObject:img];

    if (_flag == 0) {
        [_btnAdd1 setBackgroundImage:img forState:UIControlStateNormal];
        objc_setAssociatedObject(_btnAdd1, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd1 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    }else if (_flag == 1){
        [_btnAdd2 setBackgroundImage:img forState:UIControlStateNormal];
        objc_setAssociatedObject(_btnAdd2, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd2 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    }else if (_flag == 2){
        [_btnAdd3 setBackgroundImage:img forState:UIControlStateNormal];
        objc_setAssociatedObject(_btnAdd3, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd3 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    }else if (_flag == 3){
        [_btnAdd4 setBackgroundImage:img forState:UIControlStateNormal];
        objc_setAssociatedObject(_btnAdd4, @"Image", img, OBJC_ASSOCIATION_RETAIN);
        [_btnAdd4 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    }
    _pageControl.numberOfPages = _arrImages.count;
    [_collectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Delegate Method

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
    _pageControl.numberOfPages = _arrImages.count;
    return _arrImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    id obj = _arrImages[indexPath.row];
    if (![obj isKindOfClass:[UIImage class]]) {
        NSURL *imgURL = [NSURL URLWithString:[_arrImages[indexPath.row] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        [cell.imgPhoto setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (image != nil && !error)
                 [cell.imgPhoto setImage:image];

         } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

//        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//
//        indicator.center = cell.center;
//
//        [cell addSubview:indicator];
//        [indicator startAnimating];
//
//        [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
//            [indicator stopAnimating];
//            [indicator removeFromSuperview];
//            cell.imgPhoto.image = image;
//        } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
//            cell.imgPhoto.image = [UIImage imageNamed:@"no-image"];
//            [indicator stopAnimating];
//            [indicator removeFromSuperview];
//        }];

    }else{
        cell.imgPhoto.image = _arrImages[indexPath.row];
        cell.imgPhoto.contentMode = UIViewContentModeScaleAspectFit;
    }
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

#pragma mark - Validate login Information

- (BOOL)isValidLoginDetails{
    if ([_txtProductName.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterProductName image:kErrorImage];
        return NO;
    }else if ([_txtCategory.text isEmptyString]){
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
        if ([textField.text length] <= 0) {
            _lblDollar.hidden = NO;
//            if (IPHONE4 || IPHONE5){
//                _txtPrice.frame = CGRectMake(20, 318, 292, 40);
//                _lblDollar.frame = CGRectMake(8, 318, 19, 40);
//            }else if (IPHONE6){
//                _txtPrice.frame = CGRectMake(20, 318, 347, 40);
//                _lblDollar.frame = CGRectMake(8, 318, 19, 40);
//            }else if (IPHONE6PLUS){
//                _txtPrice.frame = CGRectMake(20, 318, 386, 40);
//                _lblDollar.frame = CGRectMake(8, 318, 19, 40);
//            }
        }
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
}

- (void)clearFields{
    _txtProductName.text = _txtCategory.text = _txtPrice.text = _txtShippingPrice.text = _txtDesc.text = @"";
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
    _productDetail.intCatID = _catList.intCatID;
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

@end
