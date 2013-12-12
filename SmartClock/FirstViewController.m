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
    float preOffset;
    BOOL blockTapCell;
    NSIndexPath *tapedIndexPath;
}
@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //init
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //get disk clock data
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    _clockArray = [userDefaultes valueForKey:@"clockArray"];
    if (_clockArray == nil) {
        _clockArray = [[NSMutableArray alloc] init];
        [_clockArray addObject:@"addClock"];
    }else{
        NSLog(@"Data in disk:%@",_clockArray);
    }
    
    //add NSNotificaiton observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveClockData)
                                                 name:@"saveClockData"
                                               object:nil];
}

-(void)saveClockData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_clockArray forKey:@"clockArray"];
    [userDefaults synchronize];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddClockSegue"]) {
        if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setDelegate:)]) {
            [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setValue:self forKey:@"delegate"];
        }
    }else {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setValue:self forKey:@"delegate"];
        
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0]
            setValue:_clockArray[tapedIndexPath.row] forKey:@"alarmData"];
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

- (void)reloadTable {
    [self.tableView reloadData];
}

- (IBAction)switchValueChange:(id)sender{
    UISwitch *switchButton = (UISwitch*)sender;
    UITableViewCell *cell = (UITableViewCell*)switchButton.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switchButton = (UISwitch*)[cell viewWithTag: Cell_switchTag];
    if ([[_clockArray[indexPath.row] valueForKey:@"switch"] isEqualToString:@"on"]) {
        [_clockArray[indexPath.row] setValue:@"off" forKey:@"switch"];
        
        // Cancel notifications
        NSMutableDictionary *clockInfo = _clockArray[indexPath.row];
        NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for(NSUInteger i=0; i<[localNotifications count]; i++){
            UILocalNotification *localNotification = [localNotifications objectAtIndex:i];
            if([[clockInfo objectForKey:@"id"] isEqualToString:[localNotification.userInfo objectForKey:@"id"]]){
                NSLog(@"Cancel : %@", [localNotification userInfo]);
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }
    }else{
        [_clockArray[indexPath.row] setValue:@"on" forKey:@"switch"];
        
        //// CreateNotificationData
        //set dateFormatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Asia/Taipei"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss aa"];
        [dateFormatter setTimeZone:tz];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        
        //get now time
        NSDate *nowDate = [NSDate new];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *nowDateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:nowDate];
        
        //get setTime value
        NSString *hour = [_clockArray[indexPath.row] objectForKey:@"hour"];
        NSString *mins = [_clockArray[indexPath.row] objectForKey:@"mins"];
        NSString *AMPM = [_clockArray[indexPath.row] objectForKey:@"AMPM"];
        
        //create notification time
        NSDate *pickDate = [dateFormatter dateFromString: [NSString stringWithFormat:@"%d-%d-%d %@:%@:00 %@", [nowDateComponents year], [nowDateComponents month], [nowDateComponents day],hour,mins,AMPM]];
        
        //today or tomorrow
        if ([nowDate compare:pickDate] == NSOrderedDescending) {
            NSLog(@"nowDate is later than pickDate");
            pickDate = [pickDate dateByAddingTimeInterval:60*60*24*1];
        }
        NSLog(@"%@", [pickDate descriptionWithLocale:[NSLocale systemLocale]]);
        
        //create id
        NSString *alarmIndexString = [NSString stringWithFormat:@"%d_%d", (int)[nowDate timeIntervalSince1970], (int)[pickDate timeIntervalSince1970]];
        
        //update clockInfo value
        [_clockArray[indexPath.row] setValue:alarmIndexString forKey:@"id"];
        [_clockArray[indexPath.row] setValue:pickDate forKey:@"pickDate"];
        
        //// Schedule Notifications
        // 10 times notification 6 seconds
        for(int i=0; i<10; i++){
            // Schedule the notification
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.fireDate = [[_clockArray[indexPath.row] objectForKey:@"pickDate"] dateByAddingTimeInterval:i*6];
            localNotification.alertBody = @"Smart alarm time up";
            localNotification.alertAction = @"Show me the smart alarm and signal";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            localNotification.userInfo = _clockArray[indexPath.row];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        
    }
    NSLog(@"row:%i",indexPath.row);
    [self performSelector:@selector(reloadTable) withObject:self afterDelay:0.2];
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
        
        //set switch
        if ([[_clockArray[indexPath.row] valueForKey:@"switch"] isEqualToString:@"on"]) {
            switchButton.on = YES;
        }else{
            switchButton.on = NO;
        }
        
        //set time
        AMPM.text = [_clockArray[indexPath.row] objectForKey:@"AMPM"];
//        AMPM.layer.borderColor = [[UIColor redColor] CGColor];
//        AMPM.layer.borderWidth = 1.0;
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
        if (switchButton.on) {
            [UIView animateWithDuration:0.2 animations:^{
                cell.contentView.alpha = 1;
            }];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                cell.contentView.alpha = 0.2;
            }];
        }
    }
    cell.backgroundColor = [UIColor clearColor];


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (!blockTapCell) {
//        [self.tableView setContentOffset:CGPointMake(0, 100*indexPath.row) animated:YES];
//        blockTapCell = YES;
//        self.tableView.scrollEnabled = NO;
//    }else {
//        [self.tableView setContentOffset:CGPointMake(0, preOffset) animated:YES];
//        blockTapCell = NO;
//        self.tableView.scrollEnabled = YES;
//    }
//    preOffset = self.tableView.contentOffset.y;
//    NSLog(@"preOffset:%f",self.tableView.contentOffset.y);
    
    if (indexPath.row == _clockArray.count-1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    tapedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"EditClockSegue" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

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
