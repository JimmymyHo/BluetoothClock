//
//  FirstViewController.h
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/12.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UITableViewController
@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(IBAction) chick_Switch:(id) sender;
- (void)reloadTable;
@end
