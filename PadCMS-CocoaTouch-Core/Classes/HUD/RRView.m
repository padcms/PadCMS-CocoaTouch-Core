//
//  RRView.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/20/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "RRView.h"

@interface RRView ()
{
    RRViewState _state;
}

- (void)transitToState:(RRViewState)state animated:(BOOL)animated;

@end

@implementation RRView
@synthesize statesDelegate;
@synthesize state = _state;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _state = RRViewStateInvalid;
    }
    return self;
}

- (void)transitToState:(RRViewState)state animated:(BOOL)animated
{
    if (_state != state) {
        _state = state;
//        [self viewTransitToState:_state animated:animated];
    }
    [self viewTransitToState:_state animated:animated];
}

#pragma mark - states delegate methods

- (void)viewTransitToState:(RRViewState)state animated:(BOOL)animated
{
    if ([self.statesDelegate respondsToSelector:@selector(view:transitToState:animated:)]) {
        [self.statesDelegate view:self transitToState:state animated:animated];
    }
}

@end
