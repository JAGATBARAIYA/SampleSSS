//
//  ProductDetail.m
//  SnapShotSale
//
//  Created by Manish on 13/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ProductDetail.h"

@implementation ProductDetail

+ (ProductDetail *)dataWithInfo:(NSDictionary *)dict{
    return [[self alloc]initWithDictionary:dict];
}

- (ProductDetail *)initWithDictionary:(NSDictionary *)dict{
    if (dict[@"product_id"] != [NSNull null])
        self.intProductID = [dict[@"product_id"]integerValue];
    
    if (dict[@"selleraccountid"] != [NSNull null])
        self.intSellerID = [dict[@"selleraccountid"]integerValue];

    if (dict[@"category_id"] != [NSNull null])
        self.intCatID = [dict[@"category_id"]integerValue];

    if (dict[@"sellername"] != [NSNull null])
        self.strSellerName = dict[@"sellername"];

    if (dict[@"product_name"] != [NSNull null])
        self.strName = dict[@"product_name"];
    
    if (dict[@"product_price"] != [NSNull null])
        self.strPrice = dict[@"product_price"];

    if (dict[@"shipping_price"] != [NSNull null])
        self.strShippingPrice = dict[@"shipping_price"];

    if (dict[@"product_image"] != [NSNull null])
        self.strURL = dict[@"product_image"];

    if (dict[@"item_description"] != [NSNull null])
        self.strDesc = dict[@"item_description"];

    if (dict[@"category_name"] != [NSNull null])
        self.strCatName = dict[@"category_name"];

    if (dict[@"fbid"] != [NSNull null])
        self.strFBID = dict[@"fbid"];

    if (dict[@"createddate"] != [NSNull null])
        self.strDate = dict[@"createddate"];
    
    if (dict[@"membersince"] != [NSNull null])
        self.strMemberSince = dict[@"membersince"];

    if (dict[@"sellerdate"] != [NSNull null])
        self.strSellerDate = dict[@"sellerdate"];

    if (dict[@"producturl"] != [NSNull null])
        self.strProductURL = dict[@"producturl"];

    if (dict[@"paypal"] != [NSNull null])
        self.isPayPal = [dict[@"paypal"] boolValue];

    _arrImages = [[NSMutableArray alloc]init];
    _arrImages = dict[@"gallery_image"];
    
    return self;
}

@end
