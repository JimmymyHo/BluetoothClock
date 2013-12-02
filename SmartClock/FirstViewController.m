//
//  FirstViewController.m
//  BluetoothClock
//
//  Created by JimmyHo on 2013/11/12.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController () {
    NSMutableArray *_objects;
}
@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    
    // table view custom
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.tableView setBackgroundView:imageView];
    
    self.tableView.separatorColor = [UIColor whiteColor];
    
    // localnotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable)
                                                 name:@"reloadData"
                                               object:nil];
}

- (IBAction)insertNewClock:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _objects.count;
    //return [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults arrayForKey:@"AlarmArray"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Get list of local notifications
    // NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    // UILocalNotification *localNotification = [localNotifications objectAtIndex:indexPath.row];
    
    // Get NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *alarmArray = [userDefaults arrayForKey:@"AlarmArray"];
    NSDictionary *alarmDict = [alarmArray objectAtIndex:indexPath.row];
    
//    NSDate *object = _objects[indexPath.row];
//    cell.textLabel.text = [object description];
    UILabel *fireTimeLabel = (UILabel *)[cell viewWithTag:1001];
    UILabel *noonLabel = (UILabel *)[cell viewWithTag:1002];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    fireTimeLabel.text = [formatter stringFromDate:[alarmDict objectForKey:@"AlarmDate"]];
    
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    switchView.tag = [indexPath row];
    if([[alarmDict objectForKey:@"AlarmSwitch"] isEqualToString:@"on"]){
        [switchView setOn:YES animated:NO];
        // switchview.on = YES;
    }
    else{
        [switchView setOn:NO animated:NO];
        // switchview.on = NO;
    }
    [switchView addTarget:self action:@selector(chick_Switch:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = switchView;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showClockSetting"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = _objects[indexPath.row];
//        [[segue destinationViewController] setDetailItem:object];
    }
    if ([[segue identifier] isEqualToString:@"AddClock"]) {
        NSLog(@"AddClock segue");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)chick_Switch:(id)sender
{
    UISwitch *switchView = (UISwitch *)sender;
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *hitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    if ([switchView isOn])  {
        NSLog(@"open");
        
        
        
        
    } else {
        NSLog(@"close");
        
        // Get NSUserDefaults and update
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *alarmArray = [userDefaults arrayForKey:@"AlarmArray"];
        NSMutableArray *alarmMutableArray = [NSMutableArray arrayWithArray:alarmArray];
        
        NSDictionary *alarmDict = [alarmMutableArray objectAtIndex:hitIndex.row];
        NSMutableDictionary *alarmMutableDict = [alarmDict mutableCopy];
        
        [alarmMutableDict setObject:@"off" forKey:@"AlarmSwitch"];
        alarmDict = [NSDictionary dictionaryWithDictionary:alarmMutableDict];
        [alarmMutableArray replaceObjectAtIndex:hitIndex.row withObject:alarmDict];
        alarmArray = [NSArray arrayWithArray:alarmMutableArray];
        [userDefaults setObject:alarmArray forKey:@"AlarmArray"];
        [userDefaults synchronize];
        
        // Cancel LocalNotification
        alarmDict = [alarmArray objectAtIndex:hitIndex.row];
        NSString *alarmIndex = [alarmDict objectForKey:@"AlarmIndex"];
        // Get list of local notifications
        NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for(NSUInteger i=0; i<[localNotifications count]; i++){
            UILocalNotification *localNotification = [localNotifications objectAtIndex:i];
            
            if([alarmIndex isEqualToString:[localNotification.userInfo objectForKey:@"AlarmIndex"]]){
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }
        
        NSLog(@"alarmArray : %@", [userDefaults arrayForKey:@"AlarmArray"]);
        NSLog(@"localNotificationArray : %@", localNotifications);
        
        
    }
}

- (void)reloadTable
{
    NSLog(@"reload Table");
    [self.tableView reloadData];
}

@end
