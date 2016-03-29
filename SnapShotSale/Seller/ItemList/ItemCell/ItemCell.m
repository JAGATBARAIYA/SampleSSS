//
//  ItemCell.m
//  SnapShotSale
//
//  Created by Manish on 11/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ItemCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIImage+fixOrientation.h"
#import "MBProgressHud.h"
#import "JMImageCache.h"

@implementation ItemCell

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

    _lblPrice.text =[[NSString stringWithFormat:@"%@ - ",price]stringByAppendingString:productName];

    NSURL *imgURL = [NSURL URLWithString:[_sellerItem.strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    indicator.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);

    [self addSubview:indicator];
    [indicator startAnimating];

    [[JMImageCache sharedCache] imageForURL:imgURL completionBlock:^(UIImage *image) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        _imgView.image = image;
    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        _imgView.image = [UIImage imageNamed:@"no-image"];
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }];

    if (_sellerItem.isSold)
        _soldView.hidden = NO;
    else
        _soldView.hidden = YES;
}

@end
