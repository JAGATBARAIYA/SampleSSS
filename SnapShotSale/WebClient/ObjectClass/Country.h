//
//  Country.h
//  SnapShotSale
//
//  Created by Manish on 02/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Country : NSObject

@property (assign, nonatomic) NSInteger intCountryID;

@property (strong, nonatomic) NSString *strCountryName;

+ (Country *)dataWithInfo:(NSDictionary *)dict;
- (Country *)initWithDictionary:(NSDictionary *)dict;

@end
