//
//  TabBarViewController.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/13.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "TabBarViewController.h"
#import "AppDelegate.h"
#import <snfsdk/snfsdk.h>
#import "SecondViewController.h"
#import "FirstViewController.h"
#include <objc/message.h>

@interface TabBarViewController (){
    AppDelegate *appDelegate;
    SecondViewController *secondVC;
    FirstViewController *firstVC;
}

@end

@implementation TabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabVC = self;
    firstVC = self.viewControllers[0];
    secondVC = self.viewControllers[1];
    self.tabBar.translucent = YES;
    self.tabBar.backgroundColor = [UIColor clearColor];

}

- (NSArray *) deviceList
{
    return appDelegate.leMgr.devList;
}

- (void)connectOperation{
    LeDevice *dev = [[self deviceList] objectAtIndex:0];
    if (dev.shouldBeConnected){
        NSLog(@"already connected");
    }
	else
	{
        NSLog(@"connecting...");
        [dev connect];
   	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
