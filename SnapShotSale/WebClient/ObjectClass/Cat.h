//
//  Cat.h
//  SnapShotSale
//
//  Created by Manish on 08/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cat : NSObject

@property (assign, nonatomic) NSInteger intCatID;

@property (strong, nonatomic) NSString *strCatName;
@property (strong, nonatomic) NSString *strCatDesc;

@property (assign, nonatomic) BOOL isSelected;

+ (Cat *)dataWithInfo:(NSDictionary *)dict;
- (Cat *)initWithDictionary:(NSDictionary *)dict;

@end
