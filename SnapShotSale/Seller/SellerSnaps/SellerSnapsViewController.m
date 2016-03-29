//
//  SellerSnapsViewController.m
//  SnapShotSale
//
//  Created by Manish on 10/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "SellerSnapsViewController.h"
#import "AdMobViewController.h"
#import "SellerSnapsCell.h"
#import "WebClient.h"
#import "Common.h"
#import "User.h"
#import "TKAlertCenter.h"
#import "ProductDetailViewController.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "SellerDetailView.h"
#import "MBProgressHUD.h"

@interface SellerSnapsViewController ()<SellerDetailViewDelegate>
{
    AppDelegate *app;
    UIRefreshControl *refreshControll;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
@property (strong, nonatomic) IBOutlet UILabel *lblSellerName;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;

@property (strong, nonatomic) SellerDetailView *sellerDetailView;

@property (strong, nonatomic) NSMutableArray *arrItems;

@end

@implementation SellerSnapsViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{
    app.pullRefresh = NO;
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
    _arrItems = [[NSMutableArray alloc]init];
    [_collectionView registerNib:[UINib nibWithNibName:@"SellerSnapsCell" bundle:nil] forCellWithReuseIdentifier:@"SellerSnapsCell"];
    if(IPHONE4 || IPHONE5){
        EdgeInsets =   30;
    }else if(IPHONE6 || IPHONE6PLUS){
        EdgeInsets = 30;
    }

    NSMutableString *productName = [_productDetail.strSellerName mutableCopy];
    [productName enumerateSubstringsInRange:NSMakeRange(0, [productName length])
                                    options:NSStringEnumerationByWords
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     [productName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                withString:[[substring substringToIndex:1] uppercaseString]];
                                 }];

    _lblSellerName.text = productName;

    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
    }else{
        [AdMobViewController createBanner:self];
    }

    _imgProfile.layer.borderWidth = 1;
    _imgProfile.layer.cornerRadius = 17.0;
    _imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    _imgProfile.layer.masksToBounds = YES;

    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",_productDetail.strFBID]];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *fbImage = [UIImage imageWithData:imageData];
    _imgProfile.image = fbImage;
    if ([_productDetail.strFBID isEqualToString:@""]) {
        UIImage *fbImage = [UIImage imageNamed:@"selar_snap_icon"];
        _imgProfile.image = fbImage;
    }
    refreshControll = [[UIRefreshControl alloc]init];
    [_collectionView addSubview:refreshControll];
    [refreshControll addTarget:self action:@selector(refreshCollectionView) forControlEvents:UIControlEventValueChanged];
    [self getItemList];
}

#pragma mark - Pull To Refresh

- (void)refreshCollectionView {
    app.isShowMember = NO;
    app.pullRefresh = YES;
    double delayInSeconds = 1.0;
    [self getItemList];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControll endRefreshing];
        [_collectionView reloadData];
    });
}

#pragma mark - Get Product List

- (void)getItemList{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WebClient sharedClient]getSellerItemList:@{@"seller_id":[NSNumber numberWithInteger:_productDetail.intSellerID]} success:^(NSDictionary *dictionary) {
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
                    if (app.isShowMember) {
                        [self btnSellerDetailTapped:nil];
                    }
                }else {
                    NSLog(@"Data Not Found");
                }
            }else {
                //[[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
                _lblNoRecordFound.hidden = _arrItems.count!=0;
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
    return _arrItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SellerSnapsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SellerSnapsCell" forIndexPath:indexPath];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SellerSnapsCell" owner:self options:nil] objectAtIndex:0];
    
    Product *item = _arrItems[indexPath.row];
    cell.sellerItem = item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Product *item = nil;
    item = _arrItems[indexPath.row];
    ProductDetailViewController *productDetailViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ProductDetailViewController"];
    productDetailViewController.product = item;
    app.isDetail = NO;
    app.isShowMember = NO;
    [self.navigationController pushViewController:productDetailViewController animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [UIScreen mainScreen].bounds.size.width-(EdgeInsets)-2;
    return CGSizeMake(width/2, width/2);
}

#pragma mark - Button Click event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSellerDetailTapped:(id)sender{
    _sellerDetailView = [[NSBundle mainBundle] loadNibNamed:@"SellerDetailView" owner:self options:nil][0];
    _sellerDetailView.lblMemberSince.text = [Helper dateStringFromString:_productDetail.strSellerDate format:@"yyyy-MM-dd" toFormat:@"MMMM yyyy"];
    
//    NSString *sellerName = [NSString stringWithFormat:@"%@%@",[[_productDetail.strSellerName substringToIndex:1] uppercaseString],[[_productDetail.strSellerName substringFromIndex:1] lowercaseString] ];

    _sellerDetailView.lblName.text = [[_productDetail.strSellerName capitalizedString] stringByAppendingString:@"'s"];
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",_productDetail.strFBID]];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *fbImage = [UIImage imageWithData:imageData];
    _sellerDetailView.imgProfile.image = fbImage;
    if ([_productDetail.strFBID isEqualToString:@""]) {
        UIImage *fbImage = [UIImage imageNamed:@"popup_user_photo"];
        _sellerDetailView.imgProfile.image = fbImage;
    }
    _sellerDetailView.delegate = self;
    [self.view addSubview:_sellerDetailView];
    _sellerDetailView.frame = self.view.bounds;
}

#pragma mark - Delegate Method

- (void)sellerDetailView:(SellerDetailView *)view{
    [view removeFromSuperview];
}

@end
