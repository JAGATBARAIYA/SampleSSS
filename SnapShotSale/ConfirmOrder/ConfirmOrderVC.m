//
//  ConfirmOrderVC.m
//  SnapShotSale
//
//  Created by Manish on 14/12/15.
//  Copyright © 2015 E2M. All rights reserved.
//

#import "ConfirmOrderVC.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "BillingAddressVC.h"
#import "JMImageCache.h"

#define commonColor         [UIColor colorWithRed:131.0/255.0 green:25.0/255.0 blue:12.0/255.0 alpha:1.0]

@interface ConfirmOrderVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblProductPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblShippingPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblTotal;

@end

@implementation ConfirmOrderVC

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{

    NSURL *imgURL = [NSURL URLWithString:[[[_productDetail.arrImages objectAtIndex:0] valueForKey:@"image_name" ]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    indicator.center = self.imgView.center;

    [self.imgView addSubview:indicator];
    [indicator startAnimating];

    [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        self.imgView.image = image;
    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        self.imgView.image = [UIImage imageNamed:@"no-image"];
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }];

//    [_imgView setImageWithURL:imgURL placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
//     {
//         if (image != nil && !error)
//             [_imgView setImage:image];
//
//     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];


//    [_imgView setImageWithURL:imgURL placeholderImage:nil options:SDWebImageCacheMemoryOnly usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    _imgView.contentMode = UIViewContentModeScaleAspectFit;

    _lblTitle.text = _productDetail.strName;
    _lblProductPrice.text = [NSString stringWithFormat:@"Product Price $%@",_productDetail.strPrice];
    _lblShippingPrice.text = [NSString stringWithFormat:@"Shipping Charge $%@",_productDetail.strShippingPrice];
    _lblTotal.text = [NSString stringWithFormat:@"Total $%ld",[_productDetail.strPrice integerValue]+[_productDetail.strShippingPrice integerValue]];

    NSMutableAttributedString * string1 = [[NSMutableAttributedString alloc] initWithString:_lblProductPrice.text];
    NSMutableAttributedString * string2 = [[NSMutableAttributedString alloc] initWithString:_lblShippingPrice.text];
    NSMutableAttributedString * string3 = [[NSMutableAttributedString alloc] initWithString:_lblTotal.text];

    [string1 addAttribute:NSForegroundColorAttributeName value:commonColor range:NSMakeRange(0,14)];
    [string1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Roboto-Bold" size:18.0] range:NSMakeRange(14,_lblProductPrice.text.length-14)];

    [string2 addAttribute:NSForegroundColorAttributeName value:commonColor range:NSMakeRange(0,16)];
    [string2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Roboto-Bold" size:18.0] range:NSMakeRange(16,_lblShippingPrice.text.length-16)];

    [string3 addAttribute:NSForegroundColorAttributeName value:commonColor range:NSMakeRange(0,6)];
    [string3 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Roboto-Bold" size:18.0] range:NSMakeRange(6,_lblTotal.text.length-6)];

    _lblProductPrice.attributedText = string1;
    _lblShippingPrice.attributedText = string2;
    _lblTotal.attributedText = string3;
}

#pragma mark - Button Click Event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCountinueTapped:(id)sender{
    BillingAddressVC *billingAddressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BillingAddressVC"];
    billingAddressVC.strTitle = _lblTitle.text;
    billingAddressVC.productDetail = _productDetail;
    [self.navigationController pushViewController:billingAddressVC animated:YES];
}

@end
