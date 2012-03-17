//
//  ViewController.m
//  JTGestureBasedTableViewDemo
//
//  Created by James Tang on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "TransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"


// Configure your viewController to conform to JTTableViewGestureEditingRowDelegate
// and/or JTTableViewGestureAddingRowDelegate depends on your needs
@interface ViewController () <JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate, JTTableViewGestureMoveRowDelegate>
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;
@end

@implementation ViewController
@synthesize tableViewRecognizer;
@synthesize grabbedObject;
@synthesize timers;
@synthesize player;

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 80
#define NORMAL_CELL_FINISHING_HEIGHT 80

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // In this example, we setup self.rows as datasource
    self.timers = [[NSMutableArray alloc] init];
    PrimeTimer *pt = [[PrimeTimer alloc] init];
    self.player = [[AVAudioPlayer alloc] init];
    pt.delegate = self;
    [pt setAdded];
    [self.timers addObject:pt];
     
    // Setup your tableView.delegate and tableView.datasource,
    // then enable gesture recognition in one line.
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight       = NORMAL_CELL_FINISHING_HEIGHT;
}

#pragma mark Helpers

- (void) playSound:(NSString *)name
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
    NSURL *theURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:theURL error:nil];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

// Return a string to be used representing hours, minutes, seconds (used in updating the label text).
- (NSString *)revertHoursMinutesSecondsFromTotalSecondsToString:(NSInteger)totalNumberOfSeconds {
    
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSUInteger numberOfSecondsInOneHour = 3600;
    NSUInteger numberOfSecondsInOneMinute = 60;
    
    // Example case: totalSeconds = 12305
    if(totalNumberOfSeconds > numberOfSecondsInOneHour ){
        // Then we have at least an hour
        // in the example case we have 3 from 12305/3600
        hours = (NSInteger)(floor(totalNumberOfSeconds/3600));
        
        // We need to update totalSeconds to reflect it minus the number of hours
        // in the example case 12305 - 10800 = 1505
        totalNumberOfSeconds = totalNumberOfSeconds - (hours*3600);
        
    }
    
    if(totalNumberOfSeconds > numberOfSecondsInOneMinute){
        // then we have at least one hour
        minutes = (NSInteger)floor(totalNumberOfSeconds/60); // in the example case we have 25 from 1505/60
        // update total seconds again.
        totalNumberOfSeconds = totalNumberOfSeconds - (minutes*60);
    }
    
    // Read this for string formatting specifiers:
    // http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
    NSString *timeToString = [NSString stringWithFormat:@"%ld:%ld:%ld", hours, minutes, totalNumberOfSeconds];
    
    return timeToString;
    
}

// Just a helper method to return the total number of seconds from hours, minutes, seconds as a string
- (NSInteger)getSecondsFromHours:(NSInteger)hours andMinutes:(NSInteger)minutes andSeconds:(NSInteger)seconds{
    
    // We want to return the total number of seconds
    NSUInteger numberOfSecondsInOneHour = 3600;
    NSUInteger numberOfSecondsInOneMinute = 60;
    
    NSInteger hourSeconds = hours * numberOfSecondsInOneHour;
    
    NSInteger minuteSeconds = minutes * numberOfSecondsInOneMinute;
    
    // Add them all up
    NSInteger allSeconds = hourSeconds + minuteSeconds + seconds;
    
    return allSeconds;
}

- (void)timerUpdated
{
    [timerTable reloadData];
}


#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.timers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PrimeTimer *pt = [self.timers objectAtIndex:indexPath.row];
    UIColor *backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:(0.6 - 0.12 * indexPath.row / [self tableView:tableView numberOfRowsInSection:indexPath.section])];
    if (![pt isAdded]) {
        NSString *cellIdentifier = nil;
        TransformableTableViewCell *cell = nil;
        
        // IndexPath.row == 0 is the case we wanted to pick the pullDown style
        if (indexPath.row == 0) {
            cellIdentifier = @"PullDownTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.detailTextLabel.font = [UIFont fontWithName:@"fv_almelo-webfont" size:16];
            cell.textLabel.font = [UIFont fontWithName:@"fv_almelo-webfont" size:16];
            
            if (cell == nil) {
                cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStylePullDown
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.font = [UIFont fontWithName:@"fv_almelo-webfont" size:16];
            }
            
            // Setup tint color
            cell.tintColor = backgroundColor;
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.textLabel.text = @"Release to create timer...";
            } else {
                cell.textLabel.text = @"Continue Pulling...";
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = @"details3 ";
            
            return cell;

        } else {
            // Otherwise is the case we wanted to pick the pullDown style
            cellIdentifier = @"UnfoldingTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

            if (cell == nil) {
                cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStyleUnfolding
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.font = [UIFont fontWithName:@"fv_almelo-webfont" size:16];
            }
            
            // Setup tint color
            cell.tintColor = backgroundColor;
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.textLabel.text = @"Release to create timer...";
            } else {
                cell.textLabel.text = @"Continue Pinching...";
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = @"details2 ";
            return cell;
        }
    
    } else {

        static NSString *cellIdentifier = @"MyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.detailTextLabel.font = [UIFont fontWithName:@"fv_almelo-webfont" size:26];
        cell.textLabel.font = [UIFont fontWithName:@"fv_almelo-webfont" size:26];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self revertHoursMinutesSecondsFromTotalSecondsToString:[pt.totalSeconds intValue]]];
        cell.detailTextLabel.text = @"details ";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = backgroundColor;
        return cell;
    }

}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NORMAL_CELL_FINISHING_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PrimeTimer *pt = [self.timers objectAtIndex:indexPath.row];
    [pt resetTimer];
    [pt toggleTimer];
}

#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    PrimeTimer *pt = [[PrimeTimer alloc] init];
    [self.timers insertObject:pt atIndex:indexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    PrimeTimer *t = [self.timers objectAtIndex:indexPath.row];
    [t setAdded];
    TransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
    cell.textLabel.text = @"00:00:00";
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.timers removeObjectAtIndex:indexPath.row];
}

#pragma mark JTTableViewGestureEditingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    UIColor *backgroundColor = nil;
    switch (state) {
        case JTTableViewCellEditingStateMiddle:
            backgroundColor = [[UIColor redColor] colorWithHueOffset:0.12 * indexPath.row / [self tableView:self.tableView numberOfRowsInSection:indexPath.section]];
            break;
        case JTTableViewCellEditingStateRight:
            backgroundColor = [UIColor greenColor];
            break;
        default:
            backgroundColor = [UIColor darkGrayColor];
            break;
    }
    cell.contentView.backgroundColor = backgroundColor;
    if ([cell isKindOfClass:[TransformableTableViewCell class]]) {
        ((TransformableTableViewCell *)cell).tintColor = backgroundColor;
    }
}

// This is needed to be implemented to let our delegate choose whether the panning gesture should work
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    [tableView beginUpdates];
    if (state == JTTableViewCellEditingStateLeft) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
        [self.timers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else if (state == JTTableViewCellEditingStateRight) {
        // An example to retain the cell at commiting at JTTableViewCellEditingStateRight
        //[self.rows replaceObjectAtIndex:indexPath.row withObject:DONE_CELL];

        [[self.timers objectAtIndex:indexPath.row] resetTimer];
        [[self.timers objectAtIndex:indexPath.row] toggleTimer];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        // JTTableViewCellEditingStateMiddle shouldn't really happen in
        // - [JTTableViewGestureDelegate gestureRecognizer:commitEditingState:forRowAtIndexPath:]
    }
    [tableView endUpdates];

    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];
}

#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"CREATED3");
    self.grabbedObject = [self.timers objectAtIndex:indexPath.row];
    [self.timers replaceObjectAtIndex:indexPath.row withObject:DUMMY_CELL];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"CREATED2");
    id object = [self.timers objectAtIndex:sourceIndexPath.row];
    [self.timers removeObjectAtIndex:sourceIndexPath.row];
    [self.timers insertObject:object atIndex:destinationIndexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:
(NSIndexPath *)indexPath {
    NSLog(@"CREATED1");
    [self.timers replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    self.grabbedObject = nil;
}

@end
