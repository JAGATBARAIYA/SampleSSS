//
//  Country.m
//  SnapShotSale
//
//  Created by Manish on 02/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import "Country.h"

@implementation Country

+ (Country *)dataWithInfo:(NSDictionary *)dict{
    return [[self alloc]initWithDictionary:dict];
}

- (Country *)initWithDictionary:(NSDictionary *)dict{
    if (dict[@"country_id"] != [NSNull null])
        self.intCountryID = [dict[@"country_id"]integerValue];

    if (dict[@"name"] != [NSNull null])
        self.strCountryName = dict[@"name"];

    return self;
}

@end
