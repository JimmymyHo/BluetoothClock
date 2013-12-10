//
//  RepeatViewController.h
//  SmartClock
//
//  Created by JimmyHo on 2013/12/9.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepeatViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableArray *checkArray;
@end
