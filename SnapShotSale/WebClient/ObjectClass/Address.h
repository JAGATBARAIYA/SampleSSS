//
//  Address.h
//  SnapShotSale
//
//  Created by Manish on 04/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (assign, nonatomic) NSInteger intAddressID;

@property (strong, nonatomic) NSString *strFirstName;
@property (strong, nonatomic) NSString *strLastName;
@property (strong, nonatomic) NSString *strAddress;
@property (strong, nonatomic) NSString *strCity;
@property (strong, nonatomic) NSString *strCountry;
@property (strong, nonatomic) NSString *strState;
@property (strong, nonatomic) NSString *strPhone;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strZipCode;

@property (assign, nonatomic) BOOL isBilling;

+ (Address *)dataWithInfo:(NSDictionary *)dict;
- (Address *)initWithDictionary:(NSDictionary *)dict;

@end
