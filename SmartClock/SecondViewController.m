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

@interface SecondViewController (){
    AppDelegate *appDelegate;
    BOOL alertBlock;
    NSDictionary *whichAlarm;
    SystemSoundID soundID;
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
    NSString *distance;
    NSString *state;
    
    //update distant
    if ([dev isKindOfClass:[LeSnfDevice class]])
    {
        //d:1.234 -> cancel d:
        distance = [objc_getAssociatedObject(dev, @"dist") substringFromIndex:2];
        if (nil != distance){
            //update image
            self.distantLabel.text = distance;
            if ([distance floatValue] > 0.7 || [distance floatValue] < 0)
                self.imageView.image = [UIImage imageNamed:@"Signal-02"];
            else if ([distance floatValue] > 0.2 && [distance floatValue] < 0.7)
                self.imageView.image = [UIImage imageNamed:@"Signal-03"];
            else{ //arrive
                self.imageView.image = [UIImage imageNamed:@"Signal-04"];
                //[self.songImageView stopAnimating];
                self.songImageView.image = [UIImage imageNamed:@"music-02.png"];
                
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
        else
            self.distantLabel.text = @"";
    }else
        self.distantLabel.text = @"";
    
    //update connect state
    if ([dev isKindOfClass:[LeSnfDevice class]])
    {
        state = objc_getAssociatedObject(dev, @"constate");
        if (nil != state) {
            self.connectLabel.text = state;
            if ([state isEqualToString:@"disconnected"] || [state isEqualToString:@"connecting"]) {
                [self animationSignal];
            }else {
                //self.imageView.image = [UIImage imageNamed:@"Signal-02.png"];
                [self.imageView stopAnimating];
            }
        }
        else
            self.connectLabel.text = @"";
    }else
        self.connectLabel.text = @"";
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
    self.songImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"music-02.png"],[UIImage imageNamed:@"music-01.png"], nil];
    self.songImageView.animationDuration = 0.5;
    self.songImageView.animationRepeatCount = 0;
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
