//
//  Zone.h
//  SnapShotSale
//
//  Created by Manish on 02/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Zone : NSObject

@property (assign, nonatomic) NSInteger intZoneID;
@property (assign, nonatomic) NSInteger intCountryID;

@property (strong, nonatomic) NSString *strZoneName;

+ (Zone *)dataWithInfo:(NSDictionary *)dict;
- (Zone *)initWithDictionary:(NSDictionary *)dict;

@end
