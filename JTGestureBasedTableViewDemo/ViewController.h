//
//  ViewController.h
//  JTGestureBasedTableViewDemo
//
//  Created by James Tang on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PrimeTimer.h"

@interface ViewController : UITableViewController <PrimeTimeDelegate>
{
    NSMutableArray *timers;
    IBOutlet UITableView *timerTable;
    AVAudioPlayer *player;
}

@property (nonatomic, strong) NSMutableArray *timers;
@property (nonatomic, strong) AVAudioPlayer *player;

- (void) playSound:(NSString *)name;

@end
