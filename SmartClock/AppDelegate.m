//
//  AppDelegate.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/21.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "AppDelegate.h"
#include <objc/message.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate (){
    SystemSoundID soundID;
    CLLocationManager *_locationManager;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        NSLog(@"DEBUG: didFinishLaunchingWithOptions => %@", locationNotification);
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    
    //add NSNotificaiton observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopSound)
                                                 name:@"arriveDestination"
                                               object:nil];
    
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
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"saveClockData" object:self];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"DEBUG: applicationWillEnterForeground");
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%@", notification.userInfo);
    NSLog(@"didReceiveLocalNotification");
    
    [self.tabVC setSelectedIndex:1];
    
    NSArray *array = [notification.soundName componentsSeparatedByString:@"."];
    [self playSound:array[0]];
    
    // ring ring ring
    [[NSNotificationCenter defaultCenter] postNotificationName:@"alarmTimeUp" object:nil userInfo:notification.userInfo];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

-(void) playSound:(NSString*)name {
    NSString *soundPath;
    
    if ([name isEqualToString:@"UILocalNotificationDefaultSoundName"]) {
        soundPath = [[NSBundle mainBundle] pathForResource:@"Voicemail" ofType:@"wav"];
    }else {
        soundPath = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
    }
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

- (void) stopSound {
    AudioServicesDisposeSystemSoundID(soundID);
}

@end
