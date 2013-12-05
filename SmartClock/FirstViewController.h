//
//  FirstViewController.h
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/12.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary* addClockInfo;
@property (nonatomic, strong) NSMutableArray *clockArray;

@end
