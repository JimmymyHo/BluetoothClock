//
//  AddClockViewController.h
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/19.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddClockViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *noonArray;
@property (nonatomic, strong) NSArray *hourArray;
@property (nonatomic, strong) NSMutableArray *minuteArray;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSArray *checkArray;
@property (nonatomic, strong) NSString *alarmLabel;
@property (nonatomic, strong) NSString *songName;

@property (nonatomic, strong) NSDictionary *alarmData; //edit clock

@end
