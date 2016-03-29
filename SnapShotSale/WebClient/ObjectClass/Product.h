//
//  Product.h
//  SnapShotSale
//
//  Created by Manish on 11/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (assign, nonatomic) NSInteger intProductID;

@property (strong, nonatomic) NSString *strName;
@property (strong, nonatomic) NSString *strPrice;
@property (strong, nonatomic) NSString *strURL;
@property (strong, nonatomic) NSString *strProductURL;

@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) BOOL isSold;

+ (Product *)dataWithInfo:(NSDictionary *)dict;
- (Product *)initWithDictionary:(NSDictionary *)dict;

@end
