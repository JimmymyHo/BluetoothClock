//
//  AddClockViewController.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/19.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "AddClockViewController.h"

@interface AddClockViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //init array
    self.noonArray = @[@"上午",@"下午"];
    self.hourArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    self.minuteArray = [NSMutableArray arrayWithCapacity:60];
    for (int i=0; i<60; i++) {
        [self.minuteArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    [self.pickerView selectRow:(1000-4) inComponent:1 animated:NO];
    [self.pickerView selectRow:(1000-40)inComponent:2 animated:NO];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

-(IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)saveButtonPressed:(id)sender {
    NSInteger noonRow, hourRow, minuteRow;
    noonRow = [self.pickerView selectedRowInComponent:0];
    hourRow = [self.pickerView selectedRowInComponent:1];
    minuteRow = [self.pickerView selectedRowInComponent:2];
    
    NSLog(@"%@, %@:%@", self.noonArray[noonRow], self.hourArray[hourRow%12], self.minuteArray[minuteRow%60]);
    
    // Covert to NSDate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Asia/Taipei"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:tz];
    
    
    NSDate *nowDate = [NSDate new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nowDateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:nowDate];
    
    NSLog(@"now %@", nowDate);
    NSLog(@"%@", [nowDate descriptionWithLocale:[NSLocale systemLocale]]);
//    NSLog(@"now month %d", [nowDateComponents month]);
//    NSLog(@"now day %d", [nowDateComponents day]);
//    NSLog(@"now hour %d", [nowDateComponents hour]);
//    NSLog(@"now minute %d", [nowDateComponents minute]);
//    
    NSString *pickHour;
    NSString *pickMinute = self.minuteArray[minuteRow%60];
    if(noonRow == 1){ // pm
        int pickHourInt = [self.hourArray[hourRow%12] intValue] + 12;
        if(pickHourInt == 24){
            pickHourInt = 12;
        }
        pickHour = [NSString stringWithFormat:@"%d", pickHourInt];
    }
    else{ // am
        int pickHourInt = [self.hourArray[hourRow%12] intValue];
        if(pickHourInt == 12){
            pickHourInt = 0;
        }
        pickHour = [NSString stringWithFormat:@"%d", pickHourInt];
    }
    
    NSDate *pickDate = [dateFormatter dateFromString: [NSString stringWithFormat:@"%d-%d-%d %@:%@:00", [nowDateComponents year], [nowDateComponents month], [nowDateComponents day], pickHour, pickMinute] ];
    
    if ([nowDate compare:pickDate] == NSOrderedDescending) {
        NSLog(@"nowDate is later than pickDate");
        pickDate = [pickDate dateByAddingTimeInterval:60*60*24*1];
    }
    
    NSLog(@"pick %@", pickDate);
    NSLog(@"%@", [pickDate descriptionWithLocale:[NSLocale systemLocale]]);
    
    // Get NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *alarmArray = [userDefaults arrayForKey:@"AlarmArray"];
    NSMutableArray *alarmMutableArray = [NSMutableArray arrayWithArray:alarmArray];
    if (alarmArray == nil || [alarmArray count] == 0) {
        NSLog(@"[DEBUG]UserDefaults null or empty.");
    }
    NSString *alarmIndexString = [NSString stringWithFormat:@"%d_%d", (int)[nowDate timeIntervalSince1970], (int)[pickDate timeIntervalSince1970]];
    // Create Alarm Dict
    NSDictionary *alarmDict = [NSDictionary dictionaryWithObjectsAndKeys:pickDate, @"AlarmDate",
                               alarmIndexString, @"AlarmIndex", @"on", @"AlarmSwitch", pickHour, @"AlarmHour", pickMinute, @"AlarmMimute", nil];
    [alarmMutableArray addObject:alarmDict];
    alarmArray = [NSArray arrayWithArray:alarmMutableArray];
    // Set to NSUserDefaults
    [userDefaults setObject:alarmArray forKey:@"AlarmArray"];
    [userDefaults synchronize];
    
    // [alarmMutableArray addObject:pickDate];

    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    NSDate *now=[NSDate new];
    localNotification.fireDate = pickDate;
    localNotification.alertBody = @"Smart alarm time up";
    //    localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    localNotification.userInfo = alarmDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    NSLog(@"alarmArray : %@", [userDefaults arrayForKey:@"AlarmArray"]);
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    
//}


@end
