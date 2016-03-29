//
//  ItemDetail.m
//  SnapShotSale
//
//  Created by Manish on 09/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "ItemDetail.h"

@implementation ItemDetail

+ (ItemDetail *)dataWithInfo:(NSDictionary *)dict{
    return [[self alloc]initWithDictionary:dict];
}

- (ItemDetail *)initWithDictionary:(NSDictionary *)dict{
    if (dict[@"product_id"] != [NSNull null])
        self.intProductID = [dict[@"product_id"]integerValue];
    
    if (dict[@"product_name"] != [NSNull null])
        self.strName = dict[@"product_name"];
    
    if (dict[@"product_price"] != [NSNull null])
        self.strPrice = dict[@"product_price"];
    
    if (dict[@"product_image"] != [NSNull null])
        self.strURL = dict[@"product_image"];
    
    if (dict[@"item_description"] != [NSNull null])
        self.strDesc = dict[@"item_description"];
    
    if (dict[@"category_name"] != [NSNull null])
        self.strCatName = dict[@"category_name"];
    
    _arrImages = [[NSMutableArray alloc]init];
    _arrImages = dict[@"gallery_image"];
    
    return self;
}

@end
