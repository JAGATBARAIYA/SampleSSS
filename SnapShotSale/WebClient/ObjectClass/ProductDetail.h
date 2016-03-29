//
//  ProductDetail.h
//  SnapShotSale
//
//  Created by Manish on 13/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDetail : NSObject

@property (assign, nonatomic) NSInteger intProductID;
@property (assign, nonatomic) NSInteger intSellerID;
@property (assign, nonatomic) NSInteger intCatID;

@property (strong, nonatomic) NSString *strName;
@property (strong, nonatomic) NSString *strSellerName;
@property (strong, nonatomic) NSString *strCatName;
@property (strong, nonatomic) NSString *strPrice;
@property (strong, nonatomic) NSString *strShippingPrice;
@property (strong, nonatomic) NSString *strURL;
@property (strong, nonatomic) NSString *strDesc;
@property (strong, nonatomic) NSString *strFBID;
@property (strong, nonatomic) NSString *strDate;
@property (strong, nonatomic) NSString *strSellerDate;
@property (strong, nonatomic) NSString *strMemberSince;
@property (strong, nonatomic) NSString *strProductURL;

@property (strong, nonatomic) NSMutableArray *arrSimilarPro;
@property (strong, nonatomic) NSMutableArray *arrImages;

@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) BOOL isPayPal;

+ (ProductDetail *)dataWithInfo:(NSDictionary *)dict;
- (ProductDetail *)initWithDictionary:(NSDictionary *)dict;

@end
