//
//  ViewController.m
//  DelayedActionDemo
//
//  Created by Tom Adriaenssen on 03/02/14.
//  Copyright (c) 2014 Tom Adriaenssen. All rights reserved.
//

#import "ViewController.h"
#import "IIDelayedAction.h"

@interface ViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController {
    IIDelayedAction* _delayedAction;
    NSMutableArray* _logs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _logs = [NSMutableArray array];

    _delayedAction = [IIDelayedAction delayedAction:^{
        [self log:@"initial action"];
    } withDelay:1];
    _delayedAction.onMainThread = YES;
}

- (void)log:(NSString*)message
{
    [_logs insertObject:@{@"message": message, @"date": [NSDate date]} atIndex:0];
    [self.tableView reloadData];
}

- (IBAction)triggerPressed {
    static NSUInteger index = 0;
    NSUInteger useIndex = index++;
    [_delayedAction action:^{
        [self log:[NSString stringWithFormat:@"triggered %lu", (unsigned long)useIndex]];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_logs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Default"];
    }

    cell.textLabel.text = _logs[indexPath.row][@"message"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _logs[indexPath.row][@"date"]];

    return cell;
}

@end
