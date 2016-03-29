//
//  OrderPlacedVC.m
//  SnapShotSale
//
//  Created by Manish on 14/12/15.
//  Copyright © 2015 E2M. All rights reserved.
//

#import "OrderPlacedVC.h"

@interface OrderPlacedVC ()

@end

@implementation OrderPlacedVC

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Click Event

- (IBAction)btnHomeTapped:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
