//
//  FirstViewController.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/12.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "FirstViewController.h"
#import "AddClockViewController.h"

#define cellHeight 100
#define viewFrameHeight 500
#define Cell_ImageTag 1001
#define Cell_AMPMTag 1002
#define Cell_timeTag 1003
#define Cell_switchTag 1004


@interface FirstViewController () {
    NSMutableArray *_clockArray;
    NSMutableArray *_viewArray;
}
@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //init
    self.tableView.backgroundColor = [UIColor clearColor];
    _clockArray = [[NSMutableArray alloc] init];
    _viewArray = [[NSMutableArray alloc] init];
    
    [_clockArray addObject:@"addClock"];
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 500)];
//    view.backgroundColor = [UIColor redColor];
//    [self.view insertSubview:view atIndex:0];
//    
//    view = [[UIView alloc] initWithFrame:CGRectMake(0, 20+100, 320, 500)];
//    view.backgroundColor = [UIColor orangeColor];
//    [self.view insertSubview:view atIndex:1];
}

- (IBAction)insertNewClock:(id)sender
{
//    if (!_clockArray) {
//        _clockArray = [[NSMutableArray alloc] init];
//    }
//    [_clockArray insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddClockSegue"]) {
        if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setDelegate:)]) {
            [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setValue:self forKey:@"delegate"];
        }
    }
}

- (void)setAddClockInfo:(NSDictionary *)addClockInfo {
    _addClockInfo = addClockInfo;
    NSLog(@"%i",_clockArray.count);
    [_clockArray insertObject:_addClockInfo atIndex:_clockArray.count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_clockArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexRow:%i,objectCount:%i",indexPath.row,_clockArray.count);
    UITableViewCell *cell;
    if (indexPath.row == [_clockArray count]-1) {
        cell = [tableView
                        dequeueReusableCellWithIdentifier:@"AddClockCell" forIndexPath:indexPath];
        
    }else {
        cell = [tableView
                        dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:Cell_ImageTag];
        UILabel *AMPM = (UILabel*)[cell viewWithTag:Cell_AMPMTag];
        UILabel *time = (UILabel*)[cell viewWithTag:Cell_timeTag];
        UISwitch *switchButton = (UISwitch*)[cell viewWithTag:Cell_switchTag];
        
        AMPM.text = [_addClockInfo objectForKey:@"AMPM"];
        time.text = [NSString stringWithFormat:@"%@:%@",
                     [_addClockInfo objectForKey:@"hour"],[_addClockInfo objectForKey:@"mins"]];
    }
    //NSDate *object = _clockArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.tableView setContentOffset:CGPointMake(0, 100*indexPath.row) animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_clockArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
