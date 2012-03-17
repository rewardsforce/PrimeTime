//
//  PrimeTimer.h
//  PrimeTimer
//
//  Created by John Brunsfeld on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PrimeTimeDelegate <NSObject>
- (void)timerUpdated; 
@end

@interface PrimeTimer : NSObject
{
    //public variables
    NSNumber *totalSeconds;

    //local variables
    NSNumber *timerType;
    NSNumber *timerState;
    NSTimer *timer;
    
    //booleans
    BOOL hasTimerStarted;
    BOOL isAdded;
}

@property (nonatomic, unsafe_unretained) id <PrimeTimeDelegate> delegate;
@property (nonatomic, strong) NSNumber *totalSeconds;

- (void) resetTimer;
- (void) toggleTimer;
- (void) toggleTimerType;
- (BOOL) isAdded;
- (void) setAdded;


@end
