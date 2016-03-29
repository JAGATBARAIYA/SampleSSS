//
//  CatListViewController.h
//  SnapShotSale
//
//  Created by Manish on 08/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cat.h"
#import "Country.h"
#import "Zone.h"

@class CatListViewController;

@protocol CatListViewControllerDeleagate <NSObject>
- (void)catListViewController:(CatListViewController*)controller categoryList:(Cat *)categoryList;
- (void)catListViewController:(CatListViewController *)controller countryList:(Country *)countryList;
- (void)catListViewController:(CatListViewController *)controller zoneList:(Zone *)zoneList;
@end

@interface CatListViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *arrCat;
@property (strong, nonatomic) NSString *strTitle;
@property (assign, nonatomic) NSInteger intCountryID;

@property (assign, nonatomic) id<CatListViewControllerDeleagate> delegate;

@end
