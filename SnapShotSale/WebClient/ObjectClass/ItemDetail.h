//
//  ItemDetail.h
//  SnapShotSale
//
//  Created by Manish on 09/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemDetail : NSObject

@property (assign, nonatomic) NSInteger intProductID;

@property (strong, nonatomic) NSString *strName;
@property (strong, nonatomic) NSString *strCatName;
@property (strong, nonatomic) NSString *strPrice;
@property (strong, nonatomic) NSString *strURL;
@property (strong, nonatomic) NSString *strDesc;

@property (strong, nonatomic) NSMutableArray *arrSimilarPro;
@property (strong, nonatomic) NSMutableArray *arrImages;

@property (assign, nonatomic) BOOL isSelected;

+ (ItemDetail *)dataWithInfo:(NSDictionary *)dict;
- (ItemDetail *)initWithDictionary:(NSDictionary *)dict;

@end
