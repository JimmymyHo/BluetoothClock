//
//  LabelViewController.m
//  SmartClock
//
//  Created by JimmyHo on 2013/12/9.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "LabelViewController.h"
#define textFieldTag 99
@interface LabelViewController ()

@end

@implementation LabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate setValue:self.textField.text forKey:@"alarmLabel"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.backgroundColor = [UIColor clearColor];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView
            dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    _textField = (UITextField*)[cell viewWithTag:textFieldTag];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.text = self.alarmLabel;
    [_textField becomeFirstResponder];
    return cell;
}


@end
