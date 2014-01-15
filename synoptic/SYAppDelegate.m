//
//  SYAppDelegate.m
//  synoptic
//
//  Created by sjg on 22/07/2013.
//  Copyright (c) 2013 sjg. All rights reserved.
//

#import "SYAppDelegate.h"

#import "SGMetOfficeStationsViewController.h"
#import "SGMetOfficeForcastLayerViewController.h"
#import "SGMetOfficeObservationLayerViewController.h"

@implementation SYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [GMSServices provideAPIKey: GOOGLE_MAPS_SDK_KEY];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //UIViewController *stationView = [[SGMetOfficeStationsViewController alloc] initWithNibName:@"SGMetOfficeStationsViewController" bundle:nil];
    
    UIViewController *rainForecastVC = [[SGMetOfficeForcastLayerViewController alloc] initWithLayerName: @"Precipitation_Rate" andTitle: @"Rainfall" andImage: @"raincloud"];
    UIViewController *cloudForecastVC = [[SGMetOfficeForcastLayerViewController alloc] initWithLayerName: @"Total_Cloud_Cover" andTitle: @"Cloud" andImage: @"cloud"];
    UIViewController *cloudRainForecastVC = [[SGMetOfficeForcastLayerViewController alloc] initWithLayerName: @"Total_Cloud_Cover_Precip_Rate_Overlaid" andTitle: @"Cloud/Rain" andImage: @"cloud-rain"];
    UIViewController *temperatureForecastVC = [[SGMetOfficeForcastLayerViewController alloc] initWithLayerName: @"Temperature" andTitle: @"Temperature" andImage: @"thermometer"];
    UIViewController *pressureForecastVC = [[SGMetOfficeForcastLayerViewController alloc] initWithLayerName: @"Atlantic" andTitle: @"Pressure" andImage: @"pressure"];

    UIViewController *rainObservationVC = [[SGMetOfficeObservationLayerViewController alloc] initWithLayerName: @"Rainfall" andTitle: @"Rainfall Observations" andImage: @"raincloud"];
    UIViewController *satIRObservationVC = [[SGMetOfficeObservationLayerViewController alloc] initWithLayerName: @"SatelliteIR" andTitle: @"Satellite Infrared Obs" andImage: @"ir"];
    UIViewController *satVisObservationVC = [[SGMetOfficeObservationLayerViewController alloc] initWithLayerName: @"SatelliteVis" andTitle: @"Satellite Visable Obs" andImage: @"eye"];
    UIViewController *lightningObservationVC = [[SGMetOfficeObservationLayerViewController alloc] initWithLayerName: @"Lightning" andTitle: @"Lightning Observations" andImage: @"thunder"];

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[rainForecastVC, cloudForecastVC, cloudRainForecastVC, temperatureForecastVC, pressureForecastVC, rainObservationVC, satIRObservationVC, satVisObservationVC, lightningObservationVC];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
