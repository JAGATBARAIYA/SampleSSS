//
//  AppDelegate.m
//  SnapShotSale
//
//  Created by Manish on 08/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "AppDelegate.h"
#import "Helper.h"
#import <TestFairy.h>
#import "PayPalMobile.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //testfairy key
//    [TestFairy begin:@"5d3871bd23a6757e22c692d1ba333f657fdc5883"];

    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction :@"AQ-qxdI1PBxood2Uk3zOq-MxNP6T8ImUt3M8kHC3ymJF4m4J3RjsHpeObdZcWMDc0vjzeT6xclblh51J"}];

//    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox :@"ASPb9p-ACnIZ8yHPe3xRhzpMyRgfYNhLpHKVhOV99gec7jPFOfmiqR_dzqfuOuL38LS1-LtubkFACyGj"}];


    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    _isSignIn = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
