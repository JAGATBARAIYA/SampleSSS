//
//  Cat.m
//  SnapShotSale
//
//  Created by Manish on 08/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "Cat.h"

@implementation Cat

+ (Cat *)dataWithInfo:(NSDictionary *)dict{
    return [[self alloc]initWithDictionary:dict];
}

- (Cat *)initWithDictionary:(NSDictionary *)dict{
    if (dict[@"category_id"] != [NSNull null])
        self.intCatID = [dict[@"category_id"]integerValue];
    
    if (dict[@"category_name"] != [NSNull null])
        self.strCatName = dict[@"category_name"];
    
    if (dict[@"category_description"] != [NSNull null])
        self.strCatDesc = dict[@"category_description"];
        
    return self;
}

@end
