//
//  SongViewController.m
//  SmartClock
//
//  Created by JimmyHo on 2013/12/9.
//  Copyright (c) 2013年 JimmyHo. All rights reserved.
//

#import "SongViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SongViewController ()
{
    NSIndexPath *preIndexPath;
    SystemSoundID soundID;
    BOOL check;
}
@end

@implementation SongViewController

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
    
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UITableViewCell *cell;
    for (int i=0; i<5; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.songName = cell.textLabel.text;
            check = YES;
        }
    }
    if (check == NO) {
        self.songName = @"Default";
    }
    if ([self.delegate respondsToSelector:@selector(setSongName:)]) {
        [self.delegate setValue:self.songName forKey:@"songName"];
    }
    
    [self stopSound];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) playSound:(NSString*)name {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

- (void) stopSound {
    AudioServicesDisposeSystemSoundID(soundID);
}
#pragma - mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView
            dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Country";
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"Funk";
    }else if (indexPath.row == 2){
        cell.textLabel.text = @"Guitar";
    }else if (indexPath.row == 3){
        cell.textLabel.text = @"Jazz";
    }else if (indexPath.row == 4){
        cell.textLabel.text = @"Latin";
    }
    
    if ([cell.textLabel.text isEqualToString:self.songName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        preIndexPath = indexPath;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell;
    NSLog(@"preindex:%i",preIndexPath.row);
    if ([preIndexPath isEqual: indexPath]) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self stopSound];
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self playSound:cell.textLabel.text];
        }
    }else {
        cell = [self.tableView cellForRowAtIndexPath:preIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self stopSound];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self playSound:cell.textLabel.text];

    }

    preIndexPath = indexPath;

}

@end
