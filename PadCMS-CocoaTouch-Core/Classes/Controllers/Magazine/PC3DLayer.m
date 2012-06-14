/**
 *  CocosTestLayer.m
 *  CocosTest
 *
 *  Created by Maxim Pervushin on 5/21/12.
 *  Copyright __MyCompanyName__ 2012. All rights reserved.
 */

#import "PC3DLayer.h"


@implementation PC3DLayer

- (void)dealloc
{
    [super dealloc];
}

- (void)initializeControls
{
    self.isTouchEnabled = YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (touch.tapCount == 1)
    {
        [self handleTouch:touch ofType:kCCTouchMoved];
    }
}

@end
