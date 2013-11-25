//
//  AppDelegate.h
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/21.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <snfsdk/snfsdk.h>
#import "TabBarViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,LeDeviceManagerDelegate,LeSnfDeviceDelegate>
{
    LeDeviceManager *leMgr;
    NSData *snfFirmwareData;        // firmware update data
    NSString *leFileName;           // file name for persistent storage dictionary
    NSMutableDictionary *leDict;    // dictionary used for persistent storage
}

@property (strong, nonatomic) LeDeviceManager *leMgr;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TabBarViewController *tabVC;

@end
