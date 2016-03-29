//
//  AddressListVC.h
//  SnapShotSale
//
//  Created by Manish on 04/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressCell.h"
#import "Address.h"

@class AddressListVC;

@protocol AddressListVCDeleagate <NSObject>
- (void)addressListVC:(AddressListVC*)controller addressList:(Address *)addressList;
@end

@interface AddressListVC : UIViewController

@property (assign, nonatomic) id<AddressListVCDeleagate> delegate;

@end
