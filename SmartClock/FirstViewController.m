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
    
    [_clockArray insertObject:_addClockInfo atIndex:0];
    [_clockArray removeObjectAtIndex:_clockArray.count-1];

    //compare AMPM
    _clockArray = [[_clockArray sortedArrayUsingComparator:^NSComparisonResult(id firstObject, id secondObject){
        NSString *first = [firstObject objectForKey:@"AMPM"];
        NSString *second = [secondObject objectForKey:@"AMPM"];
        int result = [first compare:second];
        if(result!=0)
        {
            return result;
        }else //AMPM equal, compare hour
        {
            NSString *first = [firstObject objectForKey:@"hour"];
            NSString *second = [secondObject objectForKey:@"hour"];
            int result = [@([first intValue]) compare: @([second intValue])];
            if (result != 0) {
                return result;
            }else { //hour equal, compare mins
                NSString *first = [firstObject objectForKey:@"mins"];
                NSString *second = [secondObject objectForKey:@"mins"];
                return [@([first intValue]) compare: @([second intValue])];
            }
        }
        
    }] mutableCopy];
    
    [_clockArray insertObject:@"addClock" atIndex:_clockArray.count];
    [self.tableView reloadData];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath]
//                          withRowAnimation:UITableViewRowAnimationNone];
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
        
        //set time
        AMPM.text = [_clockArray[indexPath.row] objectForKey:@"AMPM"];
        time.text = [NSString stringWithFormat:@"%@:%@",
                     [_clockArray[indexPath.row] objectForKey:@"hour"],
                     [_clockArray[indexPath.row] objectForKey:@"mins"]];
        
        //set image
        if ([[_clockArray[indexPath.row] objectForKey:@"AMPM"] isEqualToString:@"AM"] &&
            [[_clockArray[indexPath.row] objectForKey:@"hour"] intValue] <= 11 &&
            [[_clockArray[indexPath.row] objectForKey:@"hour"] intValue] >= 6) {
            imageView.image = [UIImage imageNamed:@"Weather-01.png"];
        }else if([[_clockArray[indexPath.row] objectForKey:@"AMPM"] isEqualToString:@"AM"] &&
                 [[_clockArray[indexPath.row] objectForKey:@"hour"] intValue] == 11) {
            imageView.image = [UIImage imageNamed:@"Weather-02.png"];
        }else if ([[_clockArray[indexPath.row] objectForKey:@"AMPM"] isEqualToString:@"PM"] &&
                  [[_clockArray[indexPath.row] objectForKey:@"hour"] intValue] == 12){
            imageView.image = [UIImage imageNamed:@"Weather-02.png"];
        }else if ([[_clockArray[indexPath.row] objectForKey:@"AMPM"] isEqualToString:@"PM"] &&
                  [[_clockArray[indexPath.row] objectForKey:@"hour"] intValue] <= 2){
            imageView.image = [UIImage imageNamed:@"Weather-02.png"];
        }else if (([[_clockArray[indexPath.row] objectForKey:@"AMPM"] isEqualToString:@"PM"] &&
                   [[_clockArray[indexPath.row] objectForKey:@"hour"] intValue] <= 6)) {
            imageView.image = [UIImage imageNamed:@"Weather-03.png"];
        }else {
            imageView.image = [UIImage imageNamed:@"Weather-04.png"];
        }
    }
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
