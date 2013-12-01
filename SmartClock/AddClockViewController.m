//
//  AddClockViewController.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/19.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "AddClockViewController.h"

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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //translucent navigationBar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    //init array
    self.noonArray = @[@"AM",@"PM"];
    self.hourArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    self.minuteArray = [NSMutableArray arrayWithCapacity:60];
    for (int i=0; i<60; i++) {
        [self.minuteArray addObject:[NSString stringWithFormat:@"%d",i]];
    }

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

}

- (NSArray*)getNowTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *temp = [currentTime componentsSeparatedByString:@" "];
    NSMutableArray *result = (NSMutableArray*)[temp[0] componentsSeparatedByString:@":"];
    [result addObject:temp[1]];
    return result;
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
    NSLog(@"setTime:%@",[setTime objectForKey:@"AMPM"]);
    if ([self.delegate respondsToSelector:@selector(setAddClockInfo:)]) {
        [self.delegate setValue:setTime forKey:@"addClockInfo"];
    }
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
    if (component == 0) {
        [setTime setValue:self.noonArray[row] forKey:@"AMPM"];
    }else if (component == 1){
        [setTime setValue:self.hourArray[row%12] forKey:@"hour"];
    }else{
        [setTime setValue:self.minuteArray[row%60] forKey:@"mins"];
    }
    
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    
//}


@end
