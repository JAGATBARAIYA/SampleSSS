//
//  ProductListViewController.m
//  SnapShotSale
//
//  Created by Manish on 08/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductDetailViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "REFrostedViewController.h"
#import "INTULocationManager.h"
#import "SVGeocoder.h"
#import "TKAlertCenter.h"
#import "ProductCell.h"
#import "WebClient.h"
#import "Product.h"
#import "Common.h"
#import "User.h"
#import "AdMobViewController.h"
#import "SIAlertView.h"
#import "AppDelegate.h"
#import "GuideView.h"
#import "Helper.h"
#import "NSObject+Extras.h"
#import "MSTextField.h"
#import "Cat.h"
#import "AllCategoryCell.h"
#import "UtilityManager.h"
#import "UIImage+fixOrientation.h"
#import "MBProgressHUD.h"
#import "JMImageCache.h"

@class GADBannerView;

@import GoogleMobileAds;

@interface ProductListViewController ()<UISearchBarDelegate,UISearchResultsUpdating,UISearchDisplayDelegate,GuideViewDelegate,UICollectionViewDataSource>
{
    AppDelegate *app;
    UIRefreshControl *refreshControll;
    CGRect tblframe;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITableView *tblList;

@property (strong, nonatomic) IBOutlet MSTextField *txtSearch;
@property (strong, nonatomic) IBOutlet MSTextField *txtMax;
@property (strong, nonatomic) IBOutlet MSTextField *txtMin;
@property (strong, nonatomic) IBOutlet MSTextField *txtZipCode;

@property (strong, nonatomic) IBOutlet UIButton *btnHighest;
@property (strong, nonatomic) IBOutlet UIButton *btnLowest;
@property (strong, nonatomic) IBOutlet UIButton *btnClear;
@property (strong, nonatomic) IBOutlet UIButton *btnDone;
@property (strong, nonatomic) IBOutlet UIButton *btnToday;

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UIView *additionalSearchView;
@property (strong, nonatomic) IBOutlet UIView *subView;
@property (strong, nonatomic) IBOutlet UIView *categoryView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;

@property (strong, nonatomic) NSMutableArray *arrProducts;
@property (strong, nonatomic) NSMutableArray *arrFilteredProducts;
@property (strong, nonatomic) NSMutableArray *arrCategory;
@property (strong, nonatomic) NSMutableArray *arrTempCat;

@property (assign, nonatomic) BOOL isTextfieldLoded;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (strong, nonatomic) GuideView *guideView;
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation ProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{

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
        newframe.size.height = [UIScreen mainScreen].bounds.size.height-160;
        _collectionView.frame=newframe;
    }
    
    [_txtZipCode resignFirstResponder];
    [_txtMin resignFirstResponder];
    [_txtMax resignFirstResponder];
    [_txtSearch resignFirstResponder];

    [self getProductList];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    if ([Helper getIntFromNSUserDefaults:kGuideViewDisplay] == 0) {
        [self performBlock:^{
            _guideView = [[NSBundle mainBundle] loadNibNamed:@"GuideView" owner:self options:nil][0];
            _guideView.delegate = self;
            [self.view addSubview:_guideView];
            _guideView.frame = self.view.bounds;
        } afterDelay:0.3];
    }
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _arrProducts = [[NSMutableArray alloc]init];
    _arrFilteredProducts = [[NSMutableArray alloc]init];
    _arrCategory = [[NSMutableArray alloc]init];
    _arrTempCat = [[NSMutableArray alloc]init];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"ProductCell" bundle:nil] forCellWithReuseIdentifier:@"ProductCell"];
    if(IPHONE4 || IPHONE5){
        EdgeInsets = 30;
    }else if(IPHONE6 || IPHONE6PLUS){
        EdgeInsets = 30;
    }
    _searchView.layer.cornerRadius = 15.0;
    _searchView.layer.masksToBounds = YES;
    refreshControll = [[UIRefreshControl alloc]init];
    [refreshControll addTarget:self action:@selector(refreshCollectionView) forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:refreshControll];
    
    tblframe = _categoryView.frame;
    app.pullRefresh = NO;
    _txtZipCode.layer.cornerRadius = 15.0;
    _txtMax.layer.cornerRadius = _txtMin.layer.cornerRadius = _btnClear.layer.cornerRadius = _btnDone.layer.cornerRadius
    = 20;

    if (IPHONE4) {
        _txtZipCode.layer.cornerRadius = 10.0;
        _txtMax.layer.cornerRadius = _txtMin.layer.cornerRadius = _btnClear.layer.cornerRadius = _btnDone.layer.cornerRadius
        = 15;
    }
}

#pragma mark - Pull To Refresh

- (void)refreshCollectionView {
    app.pullRefresh = YES;
    double delayInSeconds = 1.0;
    [self getProductList];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControll endRefreshing];
        [_collectionView reloadData];
    });
}

#pragma mark - Get Product List

- (void)getProductList{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[WebClient sharedClient]getProductList:nil success:^(NSDictionary *dictionary) {
        NSLog(@"Dictionary : %@",dictionary);
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if(dictionary){
            if([dictionary[@"success"] boolValue]){
                [_arrProducts removeAllObjects];
                [_arrCategory removeAllObjects];
                NSArray *listResult = dictionary[@"products"];
                if(listResult.count!=0){
                    [listResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Product *product = [Product dataWithInfo:obj];
                        [_arrProducts addObject:product];
                    }];
                    _arrFilteredProducts = _arrProducts;
                }
                NSArray *listResult1 = dictionary[@"categories"];
                if(listResult1.count!=0){
                    [listResult1 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Cat *catList = [Cat dataWithInfo:obj];
                        [_arrCategory addObject:catList];
                    }];
                    [_tblList reloadData];

                    CGRect newframe = _tblList.frame;
                    newframe.size.height = _arrCategory.count*50;
                    [_tblList setFrame:newframe];

                }
                [_collectionView reloadData];
            }else {
                _lblNoRecordFound.hidden = _arrProducts.count!=0;
            }
            [_collectionView reloadData];
        }
        _lblNoRecordFound.hidden = _arrProducts.count!=0;
        
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
    if (_isTextfieldLoded == YES)
        return _arrFilteredProducts.count;
    return _arrProducts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCell" forIndexPath:indexPath];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductCell" owner:self options:nil] objectAtIndex:0];
    
    Product *product = nil;
    if (_isTextfieldLoded == YES) {
        product = _arrFilteredProducts[indexPath.row];
    }else{
        product = _arrProducts[indexPath.row];
    }
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *price = [NSString stringWithFormat:@" $%@",[currencyFormatter stringFromNumber:[NSNumber numberWithInteger:[product.strPrice integerValue]]]];

    NSMutableString *productName = [product.strName mutableCopy];
    [productName enumerateSubstringsInRange:NSMakeRange(0, [productName length])
                               options:NSStringEnumerationByWords
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                [productName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                            }];

//    NSString *productName = [NSString stringWithFormat:@"%@%@",[[product.strName substringToIndex:1] uppercaseString],[[product.strName substringFromIndex:1] lowercaseString] ];

    cell.lblPrice.text = [[NSString stringWithFormat:@"%@ - ",price]stringByAppendingString:productName];
    
    NSURL *imgURL = [NSURL URLWithString:[product.strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

 //   [cell.indicator  startAnimating];

//    [cell.imgView sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image) {
//            [cell.indicator  stopAnimating];
//            [cell.indicator  removeFromSuperview];
//            cell.imgView.image = image;
//        }else{
//            [cell.indicator  stopAnimating];
//            [cell.indicator  removeFromSuperview];
//            cell.imgView.image = [UIImage imageNamed:@"no-image"];
//        }
//    }];

    [cell.imgView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

//    [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
//        [indicator stopAnimating];
//        [indicator removeFromSuperview];
//        cell.imgView.image = image;
//    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
//        cell.imgView.image = [UIImage imageNamed:@"no-image"];
//        [indicator stopAnimating];
//        [indicator removeFromSuperview];
//    }];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Product *product = nil;
    if (_isTextfieldLoded == YES) {
        product = _arrFilteredProducts[indexPath.row];
    }else{
        product = _arrProducts[indexPath.row];
    }
    ProductDetailViewController *productDetailViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ProductDetailViewController"];
    productDetailViewController.product = product;
    app.isDetail = YES;
    [self.navigationController pushViewController:productDetailViewController animated:YES];
}

#pragma mark - UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrCategory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"AllCategoryCell";
    AllCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AllCategoryCell" owner:self options:nil] objectAtIndex:0];
    
    Cat *cat = _arrCategory[indexPath.row];
    cell.allCategory = cat;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [UIScreen mainScreen].bounds.size.width-(EdgeInsets);
    return CGSizeMake(width/2, width/2);
}

#pragma mark - TextField Delegate Method

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _txtSearch) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"strName contains[cd] %@", textField.text];
        _arrFilteredProducts = [NSMutableArray arrayWithArray:[_arrProducts filteredArrayUsingPredicate:resultPredicate]];
        if (self.txtSearch.text.length!=0) {
            self.isTextfieldLoded=YES;
        }
        else{
            self.isTextfieldLoded=NO;
        }
        [_collectionView reloadData];
    }if (textField == _txtZipCode) {

        NSInteger length = [_txtZipCode.text length];

        if(length == 5)
        {
            if(range.length == 0)
                return NO;
        }

        NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterNoStyle];
        
        NSString * newString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSNumber * number = [nf numberFromString:newString];
        
        if (number)
            return YES;
        else
            return NO;
    }
    else if (textField == _txtMax || textField == _txtMin){
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
    }
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    _txtSearch.text = @"";
    [_txtSearch resignFirstResponder];
    self.isTextfieldLoded=NO;
    [_collectionView reloadData];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _txtSearch) {
        [_txtSearch becomeFirstResponder];
        _additionalSearchView.hidden = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    if (textField == _txtMax || textField == _txtMin || textField == _txtZipCode) {
        if (_tblList.hidden) {
            if (IPHONE5) {
                _scrollView.contentSize = CGSizeMake(0, 610);
            }else if (IPHONE6){
                _scrollView.contentSize = CGSizeMake(0, 700);
            }else if (IPHONE6PLUS){
                _scrollView.contentSize = CGSizeMake(0, 780);
            }else{
                _scrollView.contentSize = CGSizeMake(0, 520);
            }
            if (textField == _txtZipCode) {

            }else{
                CGPoint scrollPoint = CGPointMake(0, 100);
                [_scrollView setContentOffset:scrollPoint animated:YES];
            }

        }else{
            if (IPHONE5) {
                _scrollView.contentSize = CGSizeMake(0, 1400);
            }else if (IPHONE6){
                _scrollView.contentSize = CGSizeMake(0, 1500);
            }else if (IPHONE6PLUS){
                _scrollView.contentSize = CGSizeMake(0, 1580);
            }else{
                _scrollView.contentSize = CGSizeMake(0, 1310);
            }

            if (textField == _txtZipCode) {

            }else{
                CGPoint scrollPoint = CGPointMake(0, 900);
                [_scrollView setContentOffset:scrollPoint animated:YES];
            }
        }
    }

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textField.inputAccessoryView = keyboardDoneButtonView;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _txtSearch) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (IBAction)doneClicked:(id)sender{
    [self.view endEditing:YES];
    if (_tblList.hidden) {
        _scrollView.contentSize = CGSizeMake(0, 0);
        CGPoint scrollPoint = CGPointMake(0, 0);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }else{
        if (IPHONE5) {
            _scrollView.contentSize = CGSizeMake(0, 1200);
        }else if (IPHONE6){
            _scrollView.contentSize = CGSizeMake(0, 1300);
        }else if (IPHONE6PLUS){
            _scrollView.contentSize = CGSizeMake(0, 1370);
        }else{
            _scrollView.contentSize = CGSizeMake(0, 1110);
        }

        CGPoint scrollPoint = CGPointMake(0, 790);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
}

#pragma mark - Button Click event

- (IBAction)btnMenuTapped:(id)sender{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)btnAdditionalSearchTapped:(UIButton *)sender{
    [_txtZipCode resignFirstResponder];
    [_txtMin resignFirstResponder];
    [_txtMax resignFirstResponder];
    [_txtSearch resignFirstResponder];
    
    if ([UtilityManager isConnectedToNetwork] == NO || [UtilityManager isDataSourceAvailable] == NO) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:@"Internet is not availabel."];
        alertView.buttonsListStyle = SIAlertViewButtonsListStyleRows;
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alert) {
                                  
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }else{
        _additionalSearchView.hidden = !_additionalSearchView.hidden;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_subView.bounds byRoundingCorners:UIRectCornerBottomLeft| UIRectCornerBottomRight cornerRadii:CGSizeMake(10.0, 10.0)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = _subView.bounds;
        maskLayer.path = maskPath.CGPath;
        _subView.layer.mask = maskLayer;
    }
}

- (IBAction)btnCategoryTapped:(UIButton *)sender{
    [_txtZipCode resignFirstResponder];
    [_txtMin resignFirstResponder];
    [_txtMax resignFirstResponder];
    [_txtSearch resignFirstResponder];
    
    sender.selected = !sender.selected;
    _tblList.hidden = !sender.selected;
    CGRect newnew = tblframe;
    if (sender.selected) {
        if (IPHONE5) {
            newnew.origin.y = _tblList.frame.size.height + 155; //930
            _scrollView.contentSize = CGSizeMake(0, 1200);
        }else if (IPHONE6){
            newnew.origin.y = _tblList.frame.size.height + 200; //980
            _scrollView.contentSize = CGSizeMake(0, 1300);
        }else if (IPHONE6PLUS){
            newnew.origin.y = _tblList.frame.size.height + 230; //1010
            _scrollView.contentSize = CGSizeMake(0, 1370);
        }else{
            newnew.origin.y = _tblList.frame.size.height + 120; //930
            _scrollView.contentSize = CGSizeMake(0, 1110);
        }
        [_categoryView setFrame:newnew];
    }else{
        CGRect newnew = tblframe;
        if (IPHONE5) {
            newnew.origin.y = tblframe.size.height - 70;
        }else if (IPHONE6){
            newnew.origin.y = tblframe.size.height - 90;
        }else if (IPHONE6PLUS){
            newnew.origin.y = tblframe.size.height - 100;
        }else{
            newnew.origin.y = tblframe.size.height - 55;
        }
        _scrollView.contentSize = CGSizeMake(0, 0);
        [_categoryView setFrame:newnew];
    }
}

- (IBAction)btnSnapsTodayTapped:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (IBAction)btnHighestTapped:(UIButton *)sender{
    [self removeSelected];
    sender.selected = YES;
}

- (IBAction)btnLowestTapped:(UIButton *)sender{
    [self removeSelected];
    sender.selected = YES;
}

- (IBAction)btnDoneTapped:(id)sender{
    if ([self isValidLoginDetails]) {
        [_arrProducts removeAllObjects];
        [self.view endEditing:YES];
        NSMutableArray *data = [[NSMutableArray alloc] init];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected = 1"];
        NSArray *selectedData = [_arrCategory filteredArrayUsingPredicate:predicate];
        
        NSString *strCatId = @"";
        if(selectedData.count!=0){
            [selectedData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Cat *category = (Cat*)obj;
                [data addObject:[NSNumber numberWithInteger:category.intCatID]];
            }];
            strCatId = [data componentsJoinedByString:@","];
        }
        NSString *strSorting = @"";
        NSString *strMin = @"";
        NSString *strMax = @"";
        
        strMin = [[_txtMin.text stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        strMax = [[_txtMax.text stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        if (_btnHighest.selected) {
            strSorting = @"2";
        }else if (_btnLowest.selected){
            strSorting = @"1";
        }else{
            strSorting = @"";
        }
        
        NSString *strToday;
        if (_btnToday.selected) {
            strToday = @"1";
        }else{
            strToday = @"2";
        }
        
        NSDictionary *dict = @{@"pincode":_txtZipCode.text,@"today":strToday,@"category":strCatId,@"minprice":strMin,@"maxprice":strMax,@"sortingorder":strSorting};
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WebClient sharedClient] advanceSearch:dict success:^(NSDictionary *dictionary) {
            NSLog(@"dict is : %@",dictionary);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(dictionary){
                if([dictionary[@"success"] boolValue]){
                    _additionalSearchView.hidden = YES;
                    NSArray *listResult = dictionary[@"products"];
                    if(listResult.count!=0){
                        [listResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            Product *product = [Product dataWithInfo:obj];
                            [_arrProducts addObject:product];
                        }];
                        _arrFilteredProducts = _arrProducts;
                    }
                    _lblNoRecordFound.hidden = _arrProducts.count!=0;
                    [_collectionView reloadData];
                    // [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                }else {
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
                    _lblNoRecordFound.hidden = _arrProducts.count!=0;
                }
            }
            _lblNoRecordFound.hidden = _arrProducts.count!=0;
            [_collectionView reloadData];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
        }];
    }
}

- (IBAction)btnClearTapped:(id)sender{
    [self.view endEditing:YES];
    _txtZipCode.text = _txtMax.text = _txtMin.text = @"";
    _btnToday.selected = _btnHighest.selected = _btnLowest.selected = NO;
    [_tblList reloadData];
}

- (IBAction)btnLocationTapped:(UIButton*)sender{
    [_txtZipCode resignFirstResponder];
    [_txtMin resignFirstResponder];
    [_txtMax resignFirstResponder];
    [_txtSearch resignFirstResponder];
    
    if ([UtilityManager isConnectedToNetwork] == NO || [UtilityManager isDataSourceAvailable] == NO) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"" andMessage:@"Internet is not availabel."];
        alertView.buttonsListStyle = SIAlertViewButtonsListStyleRows;
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alert) {
                                  
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }else{
        if (sender.selected == NO) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            __weak __typeof(self) weakSelf = self;
            INTULocationManager *locMgr = [INTULocationManager sharedInstance];
            self.locationRequestID =  [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:50 delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                __typeof(weakSelf) strongSelf = weakSelf;
                if (status == INTULocationStatusSuccess) {
                    [SVGeocoder reverseGeocode:currentLocation.coordinate completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
                        [User sharedUser].latitude = currentLocation.coordinate.latitude;
                        [User sharedUser].longitude = currentLocation.coordinate.longitude;
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self getNearestSeller];
                        sender.selected = YES;
                    }];
                } else if (status == INTULocationStatusTimedOut) {
                    sender.selected = NO;
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self locationError:[NSString stringWithFormat:msgTimeOut, currentLocation]];
                } else {
                    sender.selected = NO;
                    if (status == INTULocationStatusServicesNotDetermined) {
                        [self locationError:msgLocationNotDetermine];
                    } else if (status == INTULocationStatusServicesDenied) {
                        [self locationError:msgUserDeniedPermission];
                    } else if (status == INTULocationStatusServicesRestricted) {
                        [self locationError:msgUserRestrictedLocation];
                    } else if (status == INTULocationStatusServicesDisabled) {
                        [self locationError:msgLocationTurnOff];
                    } else {
                        //[self locationError:msgLocationError];
                    }
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
                strongSelf.locationRequestID = NSNotFound;
            }];
        }else {
            sender.selected = NO;
            [self commonInit];
        }
    }
}

- (void)locationError:(NSString *)msg{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:msg];
    alertView.buttonsListStyle = SIAlertViewButtonsListStyleNormal;
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [User sharedUser].latitude = 0.0;
    [User sharedUser].longitude = 0.0;
    
    [alertView show];
}

- (void)removeSelected{
    _btnHighest.selected = _btnLowest.selected = NO;
}

- (void)getNearestSeller{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_arrProducts removeAllObjects];
    [[WebClient sharedClient]getNearestSeller:@{@"latitude":[NSNumber numberWithDouble:[User sharedUser].latitude],@"longitude":[NSNumber numberWithDouble:[User sharedUser].longitude]} success:^(NSDictionary *dictionary) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Dictionary : %@",dictionary);
        if(dictionary){
            if([dictionary[@"success"] boolValue]){
                NSArray *listResult = dictionary[@"products"];
                if(listResult.count!=0){
                    [listResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Product *product = [Product dataWithInfo:obj];
                        [_arrProducts addObject:product];
                    }];
                    _arrFilteredProducts = _arrProducts;
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [_collectionView reloadData];
            }else {
                // [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                _lblNoRecordFound.hidden = _arrProducts.count!=0;
            }
            [_collectionView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _lblNoRecordFound.hidden = _arrProducts.count!=0;
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

#pragma mark - Validate login Information

- (BOOL)isValidLoginDetails{
    if ([_txtMin.text isEqualToString:@"0"] && [_txtMax.text isEqualToString:@"0"]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgMinaAndMaxPriceZero image:kErrorImage];
        return NO;
    }else if ([_txtMin.text integerValue]>[_txtMax.text integerValue]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgMinIsLessThanMax image:kErrorImage];
        return NO;
    }
    NSString *postcodeRegex = @"(^[0-9]{5}(-[0-9]{4})?$)";
    NSPredicate *postcodeValidate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", postcodeRegex];

    if ([_txtZipCode.text isEmptyString]) {

    }else{
        if ([postcodeValidate evaluateWithObject:_txtZipCode.text] == YES) {
            NSLog (@"Postcode is Valid");
        } else {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgZipCode image:kErrorImage];
            return NO;
        }
    }

    return YES;
}

#pragma mark - Keyboard Notification Method

- (void)keyboardWasShown:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height-50, 0.0);
    _collectionView.contentInset = contentInsets;
    _collectionView.scrollIndicatorInsets = contentInsets;
}

- (void) keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _collectionView.contentInset = contentInsets;
    _collectionView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Delegate Method

- (void)guideView:(GuideView *)view{
    [view removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [Helper addIntToUserDefaults:1 forKey:kGuideViewDisplay];
    [self.view endEditing:YES];
}

@end
