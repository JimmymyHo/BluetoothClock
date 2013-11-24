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

@interface SecondViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                                      selector: @selector(refreshDistance) userInfo: nil repeats: YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (NSArray *) deviceList
{
    return appDelegate.leMgr.devList;
}

- (void) refreshDistance
{
    if ([self deviceList].count == 0)
        return;
    
    LeDevice *dev = [[self deviceList] objectAtIndex:0];
    
    //update distant
    if ([dev isKindOfClass:[LeSnfDevice class]])
    {
        NSString *s = objc_getAssociatedObject(dev, @"dist");
        if (nil != s)
            self.distantLabel.text = s;
        else
            self.distantLabel.text = @"";
    }else
        self.distantLabel.text = @"";
    
    //update connect state
    if ([dev isKindOfClass:[LeSnfDevice class]])
    {
        NSString *s = objc_getAssociatedObject(dev, @"constate");
        if (nil != s)
            self.connectLabel.text = s;
        else
            self.connectLabel.text = @"";
    }else
        self.connectLabel.text = @"";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
