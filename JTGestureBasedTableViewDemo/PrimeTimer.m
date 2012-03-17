//
//  PrimeTimer.m
//  PrimeTimer
//
//  Created by John Brunsfeld on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PrimeTimer.h"

@implementation PrimeTimer
@synthesize delegate;
@synthesize totalSeconds;

- (id) init {
    if ((self = [super init]))
    {
        totalSeconds = [NSNumber numberWithInt:0];
        isAdded = FALSE;
    }
    return self;
}

- (BOOL) isAdded
{
    return isAdded;
}

- (void) setAdded
{
    isAdded = YES;
}

- (void) resetTimer
{
    totalSeconds = [NSNumber numberWithInt:0];
}

- (void) toggleTimerType
{
    
}

// Button tap event handler
- (void)toggleTimer {
    
    // Create timer instance
    if (timer != nil){
        // Here we are resetting it so as to start another timer on each click of the button.
        [timer invalidate];
        hasTimerStarted = NO;
        timer = nil;
        return;
    }
    
    // Now initialize the timer.
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(timerUpdater)
                                           userInfo:nil repeats:YES];
}

// This is the method that is run when the timer is initialized.
// It is run every time based on the timer interval (in our case, every second)
- (void)timerUpdater {
    
    // First, get the current timestamp
    if(!hasTimerStarted){
        hasTimerStarted = YES;
    }

    int value = [totalSeconds intValue];
    totalSeconds = [NSNumber numberWithDouble:value + 1.0];
    [[self delegate] timerUpdated];
    
    
    // If totalSeconds has equaled zero, then timer is up!
    if (totalSeconds == [NSNumber numberWithInt:1500]){
        
        // Show an alert because the time is up.
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Time's UP"
                              message:@"Your countdown is complete!"
                              delegate:self
                              cancelButtonTitle:nil otherButtonTitles:@"OK!", nil];
        
        // Setting this to -1 will not show the cancel button.
        alert.cancelButtonIndex = -1;
        
        // Now show the alert!
        [alert show];
        
        // Reset the timer
        [timer invalidate];
        
        // Update the flag so we can create another timer if we want
        hasTimerStarted = NO;
    }
    
}


@end
