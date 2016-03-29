//
//  Product.m
//  SnapShotSale
//
//  Created by Manish on 11/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "Product.h"

@implementation Product

+ (Product *)dataWithInfo:(NSDictionary *)dict{
    return [[self alloc]initWithDictionary:dict];
}

- (Product *)initWithDictionary:(NSDictionary *)dict{
    if (dict[@"product_id"] != [NSNull null])
        self.intProductID = [dict[@"product_id"]integerValue];

    if (dict[@"product_name"] != [NSNull null])
        self.strName = dict[@"product_name"];
    
    if (dict[@"product_price"] != [NSNull null])
        self.strPrice = dict[@"product_price"];
    
    if (dict[@"product_image"] != [NSNull null])
        self.strURL = dict[@"product_image"];
    
    if (dict[@"producturl"] != [NSNull null])
        self.strProductURL = dict[@"producturl"];

    if (dict[@"bad_snap"] != [NSNull null])
        self.isSold = [dict[@"bad_snap"] boolValue];

    return self;
}

@end
