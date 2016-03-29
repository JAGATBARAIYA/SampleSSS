//
//  Zone.m
//  SnapShotSale
//
//  Created by Manish on 02/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import "Zone.h"

@implementation Zone

+ (Zone *)dataWithInfo:(NSDictionary *)dict{
    return [[self alloc]initWithDictionary:dict];
}

- (Zone *)initWithDictionary:(NSDictionary *)dict{
    if (dict[@"zone_id"] != [NSNull null])
        self.intZoneID = [dict[@"zone_id"]integerValue];

    if (dict[@"country_id"] != [NSNull null])
        self.intCountryID = [dict[@"country_id"]integerValue];

    if (dict[@"name"] != [NSNull null])
        self.strZoneName = dict[@"name"];

    return self;
}

@end
