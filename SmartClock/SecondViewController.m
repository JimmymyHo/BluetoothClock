//
//  SecondViewController.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/12.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"
#import <snfsdk/snfsdk.h>
#include <objc/message.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ALDefaults.h"

@interface SecondViewController (){
    AppDelegate *appDelegate;
    BOOL alertBlock;
    NSDictionary *whichAlarm;
    SystemSoundID soundID;
    
    NSMutableDictionary *_beacons;
    CLLocationManager *_locationManager;
    NSMutableArray *_rangedRegions;
}

@end

@implementation SecondViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //update distance and image every 0.5 sec
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                                      selector: @selector(refreshDistance) userInfo: nil repeats: YES];
    //translucent navigationBar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    //add NSNotificaiton observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RingRingRing:)
                                                 name:@"alarmTimeUp"
                                               object:nil];
    
    _beacons = [[NSMutableDictionary alloc] init];
    
    // This location manager will be used to demonstrate how to range beacons.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    // Populate the regions we will range once.
    _rangedRegions = [NSMutableArray array];

    // Populate the regions we will range once.
    _rangedRegions = [NSMutableArray array];
    [[ALDefaults sharedDefaults].supportedProximityUUIDs enumerateObjectsUsingBlock:^(id uuidObj, NSUInteger uuidIdx, BOOL *uuidStop) {
        NSUUID *uuid = (NSUUID *)uuidObj;
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        [_rangedRegions addObject:region];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Start ranging when the view appears.
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager startRangingBeaconsInRegion:region];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Stop ranging when the view goes away.
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager stopRangingBeaconsInRegion:region];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // CoreLocation will call this delegate method at 1 Hz with updated range information.
    // Beacons will be categorized and displayed by proximity.
    [_beacons removeAllObjects];
    NSArray *unknownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityUnknown]];
    if([unknownBeacons count])
        [_beacons setObject:unknownBeacons forKey:[NSNumber numberWithInt:CLProximityUnknown]];
    
    NSArray *immediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityImmediate]];
    if([immediateBeacons count])
        [_beacons setObject:immediateBeacons forKey:[NSNumber numberWithInt:CLProximityImmediate]];
    
    NSArray *nearBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityNear]];
    if([nearBeacons count])
        [_beacons setObject:nearBeacons forKey:[NSNumber numberWithInt:CLProximityNear]];
    
    NSArray *farBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityFar]];
    if([farBeacons count])
        [_beacons setObject:farBeacons forKey:[NSNumber numberWithInt:CLProximityFar]];
    
  [self refreshDistance];
}

- (void) refreshDistance
{
    NSArray *keyArray = [_beacons allKeys];
    if (keyArray.count==0) {
        return;
    }
    NSLog(@"key:%@",keyArray[0]);
    CLBeacon *beacon = [[_beacons objectForKey:keyArray[0]] objectAtIndex:0];
    NSLog(@"Major: %@, Minor: %@, Acc: %.2fm", beacon.major, beacon.minor, beacon.accuracy);
    self.distantLabel.text = [NSString stringWithFormat:@"%.2fm",beacon.accuracy];
    
    if (beacon.accuracy > 1.5 || beacon.accuracy < 0) {
        self.imageView.image = [UIImage imageNamed:@"Signal-02"];
    }else if (beacon.accuracy <= 1.5 && beacon.accuracy > 0.1){
        self.imageView.image = [UIImage imageNamed:@"Signal-03"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"Signal-04"];
        
        if (whichAlarm == nil) {
            return;
        }
        
        if (!alertBlock) {
            [self playSound];
            [self arriveAlart];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"arriveDestination" object:nil userInfo:whichAlarm];
            alertBlock = YES;
        }
    
    }
}

-(void) playSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Arrival" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}


- (void)arriveAlart {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                    message:@"You have waked up successfully!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)animationSignal {
    self.imageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"Signal-01.png"],[UIImage imageNamed:@"Signal-04.png"], nil];
    self.imageView.animationDuration = 0.5;
    self.imageView.animationRepeatCount = 0;
    [self.imageView startAnimating];
    
}

- (void)RingRingRing:(NSNotification*)notification {
//    self.songImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"music-02.png"],[UIImage imageNamed:@"music-01.png"], nil];
//    self.songImageView.animationDuration = 0.5;
//    self.songImageView.animationRepeatCount = 0;
    //[self.songImageView startAnimating];
    
    whichAlarm = notification.userInfo;
    NSLog(@"whichAlarm:%@",whichAlarm);
    
    alertBlock = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
