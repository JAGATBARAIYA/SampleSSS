//
//  SellerSnapsCell.m
//  SnapShotSale
//
//  Created by Manish on 10/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "SellerSnapsCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "JMImageCache.h"

@implementation SellerSnapsCell

- (void)awakeFromNib {
    _mainView.layer.borderWidth = 1;
    _mainView.layer.borderColor = [UIColor grayColor].CGColor;
    _mainView.layer.masksToBounds = YES;
}

- (void)setSellerItem:(Product *)sellerItem{
    _sellerItem = sellerItem;
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *price = [NSString stringWithFormat:@" $%@",[currencyFormatter stringFromNumber:[NSNumber numberWithInteger:[_sellerItem.strPrice integerValue]]]];

    NSMutableString *productName = [_sellerItem.strName mutableCopy];
    [productName enumerateSubstringsInRange:NSMakeRange(0, [productName length])
                                    options:NSStringEnumerationByWords
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     [productName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                withString:[[substring substringToIndex:1] uppercaseString]];
                                 }];

//    NSString *productName = [NSString stringWithFormat:@"%@%@",[[_sellerItem.strName substringToIndex:1] uppercaseString],[[_sellerItem.strName substringFromIndex:1] lowercaseString] ];

    _lblPrice.text = [[NSString stringWithFormat:@"%@ - ",price]stringByAppendingString:productName];
    
    NSString *strURL = [_sellerItem.strURL stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSURL *imgURL = [NSURL URLWithString:[strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//
//    indicator.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
//
//    [self addSubview:indicator];
//    [indicator startAnimating];
//
//    [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
//        [indicator stopAnimating];
//        [indicator removeFromSuperview];
//        self.imgView.image = image;
//    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
//        self.imgView.image = [UIImage imageNamed:@"no-image"];
//        [indicator stopAnimating];
//        [indicator removeFromSuperview];
//    }];

    [_imgView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"no-image"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image != nil && !error)
             [_imgView setImage:image];

     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

@end
