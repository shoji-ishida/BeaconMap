//
//  AppDelegate.m
//  BeaconMap
//
//  Created by Pablo Bartolome on 10/10/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *const UUID = @"e2c56db5-dffb-48d2-b060-d0f5a71096e0";
static NSString *const identifier = @"mBox.beacon";


@interface AppDelegate () <CLLocationManagerDelegate>

@property CLBeaconRegion *beaconRegion;
@property CLLocationManager *manager;
@property BOOL notified;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Load from sharedDefaults
    [self load];
    
    //Construct the region
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUID] major:10 minor:1 identifier:identifier];
    self.beaconRegion.notifyEntryStateOnDisplay = YES ;
    self.beaconRegion.notifyOnExit = YES;
    
    //Start monitoring
    self.manager = [[CLLocationManager alloc] init];
    [self.manager setDelegate:self];
    //[self startMonitor];
    
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];

    
    self.notified = false;
    return YES;
}

- (void) load {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.jp.neoscorp.rand.beacongroup"];
    NSString* strValue = [sharedDefaults objectForKey:@"MyURL"];
    NSURL *url = [NSURL URLWithString:strValue];
    
    ViewController *topViewController = (ViewController *)[self.window rootViewController];
    NSLog(@"%@, %@", topViewController.url, strValue);
    if (![[topViewController.url absoluteString] isEqualToString:(strValue)]) {
        NSLog(@"different");
        topViewController.url = url;
        [topViewController reload];
    }
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)startMonitor {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestAlwaysAuthorization];
    }
    [self.manager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Got authorization, start tracking location");
            [self startMonitor];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [self.manager requestAlwaysAuthorization];
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.manager requestStateForRegion:region];
    NSLog(@"Started Monitoring for Beacon Region %@", region);
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"didReceiveLocalNotification");
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    self.notified = false;
}

- (void)applicationDidEnterBackground:(UIApplication *) application {
    NSLog(@"App entered to bg.");
    self.notified = false;
}

- (void)applicationWillEnterForeground:(UIApplication *) application {
    NSLog(@"App entered to fg.");
    [self load];
}

//Callback when the iBeacon is in range
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
        NSLog(@"Started ranging beacons @ didEnter!! %@", region);
    }
}


/*
 * Delegate Method that gets called all the time
 */
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"State of the region: state %i region %@",(int)state,region);
    switch (state) {
        case CLRegionStateInside:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
                NSLog(@"Enter %@",region.identifier);
                //if already inside beacon range then start ranging
                [manager startRangingBeaconsInRegion:(CLBeaconRegion *)self.beaconRegion];
                NSLog(@"Started ranging beacons @ didDetermineState!!");
            }
            break;
            
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
            self.notified = false;
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed With Error");
}

//Callback when the iBeacon has left range
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Did Exit Region");
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        self.notified = false;
    }
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"Did paused location updates");
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"Did resume location updates");
}

//Callback when ranging is successful
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        NSLog(@"Did range Beacons %@", beacon);

        
        UILocalNotification *notification = [UILocalNotification new];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        notification.alertBody = @"Beaconの近辺です。";
        
        if (self.notified == false) {
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            NSLog(@"Post a notification");
            self.notified = true;
        }
    }
//    [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    
}

@end
