//
//  RepeatViewController.m
//  SmartClock
//
//  Created by JimmyHo on 2013/12/9.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "RepeatViewController.h"

@interface RepeatViewController ()

@end

@implementation RepeatViewController

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
    
    // init
    self.tableView.backgroundColor = [UIColor clearColor];
    
    if (_checkArray == nil) {
        _checkArray = [NSMutableArray array];
        for (int i=0; i<7; i++) {
            [_checkArray insertObject:@"uncheck" atIndex:i];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UITableViewCell *cell;
    for (int i=0; i<7; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [_checkArray replaceObjectAtIndex:i withObject:@"check"];
        }else {
            [_checkArray replaceObjectAtIndex:i withObject:@"uncheck"];
        }
    }
    if ([self.delegate respondsToSelector:@selector(setCheckArray:)]) {
        [self.delegate setValue:_checkArray forKey:@"checkArray"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView
                dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Every Sunday";
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"Every Monday";
    }else if (indexPath.row == 2){
        cell.textLabel.text = @"Every Tuesday";
    }else if (indexPath.row == 3){
        cell.textLabel.text = @"Every Wednesday";
    }else if (indexPath.row == 4){
        cell.textLabel.text = @"Every Thursday";
    }else if (indexPath.row == 5){
        cell.textLabel.text = @"Every Friday";
    }else if (indexPath.row == 6){
        cell.textLabel.text = @"Every Saturday";
    }
    
    if ([_checkArray[indexPath.row] isEqualToString:@"check"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

@end
