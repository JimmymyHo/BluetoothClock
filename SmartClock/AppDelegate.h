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
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>
{
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TabBarViewController *tabVC;

@end
