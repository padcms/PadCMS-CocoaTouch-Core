//
//  PCFlashButton.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCFlashButton.h"

@implementation PCFlashButton

@synthesize flashDuration;

-(void)dealloc
{
    [flashTimer invalidate];
    [flashTimer release];
    flashTimer = nil;
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        flashDuration = 0.35;
        flashTimer = [[NSTimer scheduledTimerWithTimeInterval:flashDuration target:self selector:@selector(animationTimerAction) userInfo:nil repeats:YES] retain];
    }
    return self;
}

-(void)startFlash
{
    [flashTimer fire];
}

-(void)stopFlash
{
    [flashTimer invalidate];
}

- (void) animationTimerAction
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:flashDuration];
    [UIView setAnimationDelegate:nil];
    
    self.alpha = self.alpha < 1 ? 1 : 0.5;
    
    [UIView commitAnimations];
}
@end
