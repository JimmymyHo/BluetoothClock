//
//  AppDelegate.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/21.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "AppDelegate.h"
#include <objc/message.h>


@implementation AppDelegate
@synthesize leMgr;
@synthesize tabVC;



#define BROADCAST_ID_PACKET0    0xF0    /* constants to identify custom broadcasts */
#define BROADCAST_ID_PACKET1    0xE1
#define BROADCAST_ID_PACKET2    0xD2
#define BROADCAST_ID_PACKET3    0xC3

const uint8_t key0[16] = {0xF0,0xE1,0xD2,0xC3,0xB4,0xA5,0x96,0x87,0x78,0x69,0x5A,0x4B,0x3C,0x2D,0x1E,0x0F};


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *firmwareFileName = [[NSBundle mainBundle] pathForResource:@"bleTag_enc" ofType:@"bin"];
    if (firmwareFileName)
        snfFirmwareData =  [NSData dataWithContentsOfFile: firmwareFileName];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    /*
     The demo app does store persistent information for the devices in a simple dictionary that gets written into a plist
     on every update.
     */
    leFileName =  [applicationSupportDirectory stringByAppendingString:@"/LeDevices.plist"];
    leDict = [[NSMutableDictionary alloc] initWithContentsOfFile: leFileName];
    if (nil == leDict)
        leDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    /* Create a LeDeviceManager object that will handle a list of LeDevices */
    self.leMgr = [[LeDeviceManager alloc] initWithSupportedDevices: [NSArray arrayWithObjects:
                                                                     [LeSnfDevice class], nil] delegate:self];
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
    
    LeDevice *dev = [self.leMgr.devList objectAtIndex:0];
    if (dev.shouldBeConnected){
        NSLog(@"disconnect");
        [dev disconnect];
    }
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

- (NSData *) firmwareDataForLeSnfDevice: (LeSnfDevice *) dev
{
    return snfFirmwareData;
}

- (void) leDeviceManager: (LeDeviceManager *) mgr didAddNewDevice:(LeDevice*) dev
{
    if ([dev isKindOfClass:[LeSnfDevice class]])
    {
        ((LeSnfDevice*)dev).delegate = self;
        objc_setAssociatedObject(dev,@"constate",@"disconnected", OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSArray *) retrieveStoredDeviceUUIDsForLeDeviceManager: (LeDeviceManager *)mgr
{
    return [leDict allKeys];
}

- (id) leDeviceManager: (LeDeviceManager *) mgr valueForDeviceUUID: (CFUUIDRef) uuid key:(NSString *)key
{
    NSDictionary *d = [leDict objectForKey: (__bridge NSString *) CFUUIDCreateString(NULL,uuid) ];
    if (d)
    {
        return [d valueForKey:key];
    }
    return NULL;
}

- (void) leDeviceManager: (LeDeviceManager *) mgr setValue: (id) value forDeviceUUID: (CFUUIDRef) uuid key:(NSString *)key
{
    NSString *ks = (__bridge NSString *) CFUUIDCreateString(NULL,uuid);
    NSMutableDictionary *d = [leDict valueForKey: ks ];
    if (nil == d)
    {
        d = [[NSMutableDictionary alloc] initWithCapacity:2];
        [leDict setValue: d forKey: ks];
    }else if (![d isKindOfClass: [NSMutableDictionary class]])
    {
        d = [d mutableCopy];
        [leDict setValue: d forKey: ks];
    }
    if (d)
    {
        [d setValue: value forKey: key];
        [leDict writeToFile: leFileName atomically:true];
    }
    
}

- (void) didDiscoverLeSnfDevice:(LeSnfDevice *)dev
{
    // [tabVC refreshDeviceList];
    [tabVC connectOperation];
}


- (void) leSnfDevice:(LeSnfDevice *)dev didChangeState:(int)state
{
    NSLog(@"enter didChangeState");
    if (LE_DEVICE_STATE_CONNECTED == state) /* device just connected */
    {
        [dev enableDistanceMeasurement:true];   // enable measurement of distance and observe the distance value
        [dev addObserver:self forKeyPath:@"distanceEstimate" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        [dev addObserver:self forKeyPath:@"temperature" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        
        [dev setConnectionRate:1]; // set connection rate to 1Hz
        
        /* setup broadcast packet 0 to send temperature and battery level and some user bytes */
        uint8_t broadcast0[] = {
            BROADCAST_ID_PACKET0,   // first byte is used to identify that broadcast, very simple approach for demo purpose
            0x00,                   // 2nd byte will be overwritten with the temperature value byt he device
            0x00,                   // 3rd byte wil be overwritten with the battery value by the device
            'b',                    // more data to broadcast
            'r',
            '0'
        };
        [dev setBroadcastData: [NSData dataWithBytes:broadcast0 length:sizeof(broadcast0)]
                      atIndex:0
                      dynData:LeSnfDeviceBroadcastDynTemperature | LeSnfDeviceBroadcastDynBatteryLevel
                       dynOfs:1];
        
        
        /* setup broadcast packet 1 to send button counter with 4 bytes length and some user bytes */
        uint8_t broadcast1[] = {
            BROADCAST_ID_PACKET1,   // first byte is used to identify that broadcast, very simple approach for demo purpose
            0x00,0x00,0x00,0x00,    // 2nd to 5th byte will be overwritten with the button counter value byt he device
            'b',                    // more data to broadcast
            'r',
            '1'
        };
        
        [dev setBroadcastData: [NSData dataWithBytes:broadcast1 length:sizeof(broadcast1)]
                      atIndex:1
                      dynData:LeSnfDeviceBroadcastDynButtonCounter4
                       dynOfs:1];
        
        /* setup broadcast packet 2 to send tempperature and some user bytes, encrypted with key0 and 8 random bytes */
        uint8_t broadcast2[] = {
            BROADCAST_ID_PACKET2,   // first byte is used to identify that broadcast, very simple approach for demo purpose
            0x00,                   // put temperature here
            'b',                    // more data to broadcast
            'r',
            '2',
            0x00,0x00,0x00,0x00,0x0,0x00,0x00,0x00  // 8 bytes, will be overwritten by encryption random data
        };
        
        [dev setBroadcastKey:[NSData dataWithBytes:key0 length:16] atIndex:0];  // set the key
        [dev setEncryptedBroadcastData: [NSData dataWithBytes:broadcast2 length:sizeof(broadcast2)]
                               atIndex:2
                               dynData:LeSnfDeviceBroadcastDynTemperature
                                dynOfs:1
                              keyIndex:0        // use key 0
                       encryptionRange:NSMakeRange(1, 4) // 4 bytes including the temperature
                          randomLength:8];
        
        
        
        /* broadcast at 10Hz for 30s, then at 0.3Hz */
        [dev setBroadcastRate: 10.0 timeout:30.0 rate2:0.3];
        objc_setAssociatedObject(dev,@"constate",@"connected", OBJC_ASSOCIATION_RETAIN);
        
    }else if (LE_DEVICE_STATE_DISCONNECTED == state)
    {
        objc_setAssociatedObject(dev,@"constate",@"disconnected", OBJC_ASSOCIATION_RETAIN);
        @try {
            [dev removeObserver: self forKeyPath:@"distanceEstimate"];
            [dev removeObserver:self forKeyPath:@"temperature"];
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }else if (LE_DEVICE_STATE_CONNECTING == state)
    {
        objc_setAssociatedObject(dev,@"constate",@"connecting", OBJC_ASSOCIATION_RETAIN);
    }else if (LE_DEVICE_STATE_UPDATING_FIRMWARE == state)
    {
        objc_setAssociatedObject(dev,@"constate",@"updating", OBJC_ASSOCIATION_RETAIN);
    }
    // [tabVC refreshDeviceList];
    
}

- (void) leSnfDevice:(LeSnfDevice *)dev didUpdateBroadcastData: (NSData *) data
{
    uint8_t t[32];
    if (data.length > 32) return;
    [data getBytes:t];
    switch (t[0]) {
        case BROADCAST_ID_PACKET0:
            t[data.length] = 0;       // terminate the string part
            NSLog(@"broadcast 0 on device %@ temp: %d battery: %d str: %s",dev.peripheral.name, t[1],t[2],t+3);
            objc_setAssociatedObject(dev,@"bc0",[NSString stringWithFormat:@"temp: %d battery: %d str: %s",((int8_t*)t)[1],t[2],t+3], OBJC_ASSOCIATION_RETAIN);
            // using associated objects to show the info on the listView
            break;
        case BROADCAST_ID_PACKET1:
            t[data.length] = 0;
            uint32_t x;
            memcpy(&x,t+1,4);
            NSLog(@"broadcast 1 on device %@ counter: %d str: %s",dev.peripheral.name, x, t+5);
            objc_setAssociatedObject(dev,@"bc1",[NSString stringWithFormat:@"ctr: %d str: %s",x,t+5], OBJC_ASSOCIATION_RETAIN);
            break;
        case BROADCAST_ID_PACKET2:
        {
            NSData *d = [dev decryptBroadcastData:data key:[NSData dataWithBytes:key0 length:16] encryptionRange:NSMakeRange(1, 4) randomLength:8];
            [d getBytes:t];
            t[data.length-8] = 0;
            NSLog(@"broadcast 2 on device %@ temp: %d str: %s",dev.peripheral.name,t[1],t+2);
            objc_setAssociatedObject(dev,@"bc2",[NSString stringWithFormat:@"temp: %d str: %s",((int8_t*)t)[1],t+2], OBJC_ASSOCIATION_RETAIN);
        }
            break;
        case BROADCAST_ID_PACKET3:
            NSLog(@"broadcast 3 on device %@ data %@",dev.peripheral.name,data);
            break;
        default:
            break;
    }
    // NSLog(@"broadcast data %@ for %@",data,dev);
}

- (NSData *)    authenticationKeyforLeSnfDevice:(LeSnfDevice *)dev
{
    return nil;
}


- (void)       didSetBroadcastDataForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success
{
    
}

- (void)       didSetBroadcastKeyForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success
{
    
    
}

- (void)       didSetBroadcastRateForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success
{
    NSLog(@"broadcast rate set for %@",dev);
}

- (void)       didEnableAlertForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success
{
    
    
}

- (void)       didEnableConnectionLossAlertForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success
{
    
    
}

- (void)       didSetPairingRssiForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success
{
    
}

- (void)       didSetTemperatureCalibrationForLeSnfDevice:(LeSnfDevice *)dev success:(BOOL)success
{
    NSLog(@"temperature calibration set for %@",dev);
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( [keyPath isEqualToString: @"distanceEstimate"])
    {
        LeSnfDevice *dev = (LeSnfDevice *)object;
        NSLog(@"distance update %@ %f",dev,dev.distanceEstimate);
        objc_setAssociatedObject(dev,@"dist",[NSString stringWithFormat:@"d:%3.3f",dev.distanceEstimate], OBJC_ASSOCIATION_RETAIN);
        // [tabVC refreshDeviceList];
    }else
        if ( [keyPath isEqualToString: @"temperature"])
        {
            LeSnfDevice *dev = (LeSnfDevice *)object;
            NSLog(@"temperature update %@ %f",dev,dev.temperature);
            objc_setAssociatedObject(dev,@"temp",[NSString stringWithFormat:@"t:%f",dev.temperature], OBJC_ASSOCIATION_RETAIN);
            
            /* fake calibration to test temperature calibration */
            // [dev setTemperatureCalibration: 33.0f];
            
            // [tabVC refreshDeviceList];
        }
}


@end
