//
//  AddClockViewController.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/19.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "AddClockViewController.h"
#import "RepeatViewController.h"

@interface AddClockViewController (){
    NSArray *nowTime;
    NSMutableDictionary *setTime;
}

@end

@implementation AddClockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupInitData];
    
    if (self.alarmData != nil) { //edit old alarm
        self.navigationItem.title = @"Edit Alarm";
        if ([[self.alarmData valueForKey:@"AMPM"] isEqualToString:@"AM"]) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
        }else{
            [self.pickerView selectRow:1 inComponent:0 animated:NO];
        }
        [self.pickerView selectRow:(1000-5+
                            [[self.alarmData valueForKey:@"hour"] intValue]) inComponent:1 animated:NO];
        [self.pickerView selectRow:(1000-40+
                            [[self.alarmData valueForKey:@"mins"] intValue]) inComponent:2 animated:NO];
    }else { //add new alarm
        self.navigationItem.title = @"Add Alarm";
        nowTime = [self getNowTime];
        NSLog(@"nowTime:%@",nowTime);
        if ([nowTime[3] isEqualToString:@"AM"]) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
        }else{
            [self.pickerView selectRow:1 inComponent:0 animated:NO];
        }
        [self.pickerView selectRow:(1000-5+[nowTime[0] intValue]) inComponent:1 animated:NO];
        [self.pickerView selectRow:(1000-40+[nowTime[1] intValue]) inComponent:2 animated:NO];
        
        NSArray *keys = [NSArray arrayWithObjects:@"hour",@"mins",@"AMPM",nil];
        NSArray *values = [NSArray arrayWithObjects:nowTime[0],nowTime[1],nowTime[3],nil];
        
        setTime = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
        
        //init detailLabel
        self.alarmLabel = @"";
        self.songName = @"";
    }

}

- (void)setupInitData {
    //translucent navigationBar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    //translucent tableView
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    //init array
    self.noonArray = @[@"AM",@"PM"];
    self.hourArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    self.minuteArray = [NSMutableArray arrayWithCapacity:60];
    for (int i=0; i<10; i++) {
        [self.minuteArray addObject:[NSString stringWithFormat:@"0%d",i]];
    }
    for (int i=10; i<60; i++) {
        [self.minuteArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
}

- (NSArray*)getNowTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
#if TARGET_IPHONE_SIMULATOR
    // It's running on the simulator, time format: xx:xx:xx PM
    NSArray *temp = [currentTime componentsSeparatedByString:@" "];
    NSMutableArray *result = (NSMutableArray*)[temp[0] componentsSeparatedByString:@":"];
    [result addObject:temp[1]];
    return result;
#else
    // Running on Actual Device
    // chinese version , time format: 上午xx:xx:xx
    NSMutableArray *temp = [NSMutableArray array];
    NSString *time = [currentTime substringFromIndex:2];
    temp = (NSMutableArray*)[time componentsSeparatedByString:@":"];
    if ([[currentTime substringToIndex:2] isEqualToString:@"上午"]) {
        [temp addObject:@"AM"];
    }else {
        [temp addObject:@"PM"];
    }
    return temp;
#endif

}

- (void)setCheckArray:(NSArray *)checkArray {
    _checkArray = checkArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (self.alarmData != nil) {

    }else {
        if ([segue.identifier isEqualToString:@"REPEAT"]) {
            [segue.destinationViewController setValue:self forKey:@"delegate"];
            [segue.destinationViewController setValue:_checkArray forKey:@"checkArray"];
        }else if ([segue.identifier isEqualToString:@"LABEL"]){
            [segue.destinationViewController setValue:self forKey:@"delegate"];
            [segue.destinationViewController setValue:_alarmLabel forKey:@"alarmLabel"];
        }else if ([segue.identifier isEqualToString:@"SOUND"]){
            [segue.destinationViewController setValue:self forKey:@"delegate"];
            [segue.destinationViewController setValue:_songName forKey:@"songName"];
        }
    }
}

-(IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)saveButtonPressed:(id)sender {
    
    [self createNotificationData];
    
    //set delegate value
    if ([self.delegate respondsToSelector:@selector(setAddClockInfo:)]) {
        [self.delegate setValue:setTime forKey:@"addClockInfo"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNotificationData {
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
    NSString *hour = [setTime valueForKey:@"hour"];
    NSString *mins = [setTime valueForKey:@"mins"];
    NSString *AMPM = [setTime valueForKey:@"AMPM"];
    
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
    
    //set setTime value
    [setTime setValue:alarmIndexString forKey:@"id"];
    [setTime setValue:pickDate forKey:@"pickDate"];
    [setTime setValue:@"on" forKey:@"switch"];
    if (self.checkArray != nil) {
        [setTime setValue:self.checkArray forKey:@"repeat"];
    }
    [setTime setValue:self.alarmLabel forKey:@"label"];
    [setTime setValue:self.songName forKey:@"song"];
    NSLog(@"setTime:%@",setTime);
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.fireDate = pickDate;
    localNotification.alertBody = @"Smart alarm time up";
    //localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    localNotification.userInfo = setTime;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - UITableView method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        UITableViewCell *cell;
        if (indexPath.row == 0) {
            cell = [tableView
                    dequeueReusableCellWithIdentifier:@"REPEAT" forIndexPath:indexPath];
            NSString *detailString = @"";
            for (int i=0; i<7; i++) {
                if ([_checkArray[i] isEqualToString:@"check"]) {
                    if (i==0) {
                        detailString = [detailString stringByAppendingString:@"Sun "];
                    }else if (i==1){
                        detailString = [detailString stringByAppendingString:@"Mon "];
                    }else if (i==2){
                        detailString = [detailString stringByAppendingString:@"Tue "];
                    }else if (i==3){
                        detailString = [detailString stringByAppendingString:@"Wed "];
                    }else if (i==4){
                        detailString = [detailString stringByAppendingString:@"Thu "];
                    }else if (i==5){
                        detailString = [detailString stringByAppendingString:@"Fri "];
                    }else if (i==6){
                        detailString = [detailString stringByAppendingString:@"Sat "];
                    }
                }
            }
            if ([detailString isEqualToString:@""]) {
                detailString = @"Never";
            }
            if (detailString.length > 24) {
                detailString = @"Every day";
            }
            cell.detailTextLabel.text = detailString;
            
        }else if (indexPath.row == 1){
            cell = [tableView
                    dequeueReusableCellWithIdentifier:@"LABEL" forIndexPath:indexPath];
            if ([self.alarmLabel isEqualToString:@""]) {
                self.alarmLabel = @"Alarm";
            }
            cell.detailTextLabel.text = self.alarmLabel;
            
            
        }else {
            cell = [tableView
                    dequeueReusableCellWithIdentifier:@"RINGTONE" forIndexPath:indexPath];
            if ([self.songName isEqualToString:@""]) {
                self.songName = @"Default";
            }
            cell.detailTextLabel.text = self.songName;
        }
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


#pragma mark - UIPickerView DataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.noonArray count];
    }else {
        return 2000;
    }
}

#pragma mark - UIPickerView Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return self.noonArray[row];
    }else if (component == 1){
        return self.hourArray[row%12];
    }else{
        return self.minuteArray[row%60];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [setTime setValue:self.noonArray[row] forKey:@"AMPM"];
    }else if (component == 1){
        [setTime setValue:self.hourArray[row%12] forKey:@"hour"];
    }else{
        [setTime setValue:self.minuteArray[row%60] forKey:@"mins"];
    }
    
}

@end
