//
//  CustomSegue.m
//  TravelApp
//
//  Created by Manish Dudharejia on 29/10/14.
//  Copyright (c) 2014 E2M. All rights reserved.
//

#import "CustomSegue.h"
#import "Helper.h"
#import "User.h"

@implementation CustomSegue

- (void)perform{
    UIViewController *sourceViewController = self.sourceViewController;
//    UIViewController *destinationViewController = self.destinationViewController;
    if ([self.identifier isEqualToString:@"pop"]) {
        [sourceViewController.navigationController popViewControllerAnimated:YES];
    } else if ([self.identifier isEqualToString:@"logOut"]) {
        [User sharedUser].login = NO;
        [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
        [sourceViewController.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
