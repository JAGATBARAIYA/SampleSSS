//
//  Address.m
//  SnapShotSale
//
//  Created by Manish on 04/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import "Address.h"

@implementation Address

+ (Address *)dataWithInfo:(NSDictionary *)dict{
    return [[self alloc]initWithDictionary:dict];
}

- (Address *)initWithDictionary:(NSDictionary *)dict{
    if (dict[@"id"] != [NSNull null])
        self.intAddressID = [dict[@"id"]integerValue];

    if (dict[@"fname"] != [NSNull null])
        self.strFirstName = dict[@"fname"];

    if (dict[@"lname"] != [NSNull null])
        self.strLastName = dict[@"lname"];

    if (dict[@"address"] != [NSNull null])
        self.strAddress = dict[@"address"];

    if (dict[@"city"] != [NSNull null])
        self.strCity = dict[@"city"];

    if (dict[@"country"] != [NSNull null])
        self.strCountry = dict[@"country"];

    if (dict[@"state"] != [NSNull null])
        self.strState = dict[@"state"];

    if (dict[@"phone"] != [NSNull null])
        self.strPhone = dict[@"phone"];

    if (dict[@"email"] != [NSNull null])
        self.strEmail = dict[@"email"];

    if (dict[@"is_billing"] != [NSNull null])
        self.isBilling = [dict[@"is_billing"] boolValue];

    if (dict[@"zipcode"] != [NSNull null])
        self.strZipCode = dict[@"zipcode"];

    return self;
}

@end
