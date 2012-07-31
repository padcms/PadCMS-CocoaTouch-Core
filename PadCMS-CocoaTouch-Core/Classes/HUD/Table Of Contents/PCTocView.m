//
//  PCTocView.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/30/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCTocView.h"

#import "PCGridView.h"

typedef enum _PCTocViewPosition {
    PCTocViewPositionInvalid = -1,
    PCTocViewPositionTop = 0,
    PCTocViewPositionBottom = 1
} PCTocViewPosition;


@interface PCTocView ()
{
    PCTocViewPosition _position;
    PCTocViewState _state;
}

- (void)buttonTapped:(UIButton *)button;
- (void)setPosition:(PCTocViewPosition)position;

- (CGPoint)hiddenStateCenterForRect:(CGRect)rect;
- (CGPoint)visibleStateCenterForRect:(CGRect)rect;
- (CGPoint)activeStateCenterForRect:(CGRect)rect;

@end

@implementation PCTocView
@synthesize state = _state;
@synthesize backgroundView = _backgroundView;
@synthesize button = _button;
@synthesize gridView = _gridView;

- (void)dealloc
{
    [_button release];
    [_gridView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self != nil) {
        
        _position = PCTocViewPositionInvalid;
        _state = PCTocViewStateInvalid;
        
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] init];
        [self addSubview:_backgroundView];
        
        _button = [[UIButton alloc] init];
        [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        _gridView = [[PCGridView alloc] init];
        _gridView.backgroundColor = [UIColor clearColor];
        [self addSubview:_gridView];
    }
    
    return self;
}

#pragma mark - public methods

- (void)transitToState:(PCTocViewState)state animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(tocView:transitToState:animated:)]) {
        if ([self.delegate tocView:self transitToState:state animated:animated]) {
            _state = state;
        }
    }
}

- (CGPoint)centerForState:(PCTocViewState)state containerBounds:(CGRect)containerBounds
{
    switch (state) {
        case PCTocViewStateInvalid:
            return CGPointZero;
            break;
            
        case PCTocViewStateHidden:
            return [self hiddenStateCenterForRect:containerBounds];
            break;
            
        case PCTocViewStateVisible:
            return [self visibleStateCenterForRect:containerBounds];
            break;
            
        case PCTocViewStateActive:
            return [self activeStateCenterForRect:containerBounds];
            break;
            
        default:
            break;
    }
    
    return CGPointZero;
}

#pragma mark - private methods

- (void)buttonTapped:(UIButton *)button
{
    if (_state == PCTocViewStateInvalid || _state == PCTocViewStateHidden) {
        return;
    }
    
    if (_state == PCTocViewStateActive) {
        [self transitToState:PCTocViewStateVisible animated:YES];
    } else {
        [self transitToState:PCTocViewStateActive animated:YES];
    }
}

- (void)setPosition:(PCTocViewPosition)position
{
    _position = position;
}

- (CGPoint)hiddenStateCenterForRect:(CGRect)rect
{
    switch (_position) {
        case PCTocViewPositionInvalid:
            return CGPointZero;
            break;
        
        case PCTocViewPositionTop: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               -(boundsSize.height / 2) + rect.origin.y);
        }
            break;
        
        case PCTocViewPositionBottom: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               (boundsSize.height / 2) + rect.size.height + rect.origin.y);
        }
            break;
    }
    
    return CGPointZero;
}

- (CGPoint)visibleStateCenterForRect:(CGRect)rect
{
    switch (_position) {
        case PCTocViewPositionInvalid:
            return CGPointZero;
            break;
            
        case PCTocViewPositionTop: {
            CGSize boundsSize = self.bounds.size;
            CGSize buttonSize = _button.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               -(boundsSize.height / 2) + buttonSize.height + rect.origin.y);
        }
            break;
            
        case PCTocViewPositionBottom: {
            CGSize boundsSize = self.bounds.size;
            CGSize buttonSize = _button.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               (boundsSize.height / 2) + rect.size.height + rect.origin.y - buttonSize.height);
        }
            break;
    }
    
    return CGPointZero;
}

- (CGPoint)activeStateCenterForRect:(CGRect)rect
{
    switch (_position) {
        case PCTocViewPositionInvalid:
            return CGPointZero;
            break;
            
        case PCTocViewPositionTop: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake(boundsSize.width / 2 + rect.origin.x,
                               boundsSize.height / 2 + rect.origin.y);
        }
            break;
            
        case PCTocViewPositionBottom: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               (rect.size.height + rect.origin.y) - (boundsSize.height / 2));
        }
            break;
    }
    
    return CGPointZero;
}

#pragma mark - public class methods

#define TopTocButtonDefaultWidth 100
#define TopTocButtonDefaultHeight 50

+ (PCTocView *)topTocViewWithFrame:(CGRect)frame
{
    PCTocView *tocView = [[PCTocView alloc] initWithFrame:frame];
    
    [tocView setPosition:PCTocViewPositionTop];
    
    // Adjust layout
    
    CGSize tocSize = frame.size;
    
    CGRect buttonFrame = CGRectMake(tocSize.width - TopTocButtonDefaultWidth,
                                    tocSize.height - TopTocButtonDefaultHeight,
                                    TopTocButtonDefaultWidth,
                                    TopTocButtonDefaultHeight);
    tocView.button.frame = buttonFrame;
    tocView.button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    tocView.button.backgroundColor = [UIColor redColor];


    CGRect gridViewFrame = CGRectMake(0,
                                      0,
                                      tocSize.width,
                                      tocSize.height - buttonFrame.size.height);
    tocView.gridView.frame = gridViewFrame;
    tocView.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tocView.gridView.backgroundColor = [UIColor clearColor];

    tocView.backgroundView.frame = gridViewFrame;
    tocView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tocView.backgroundView.backgroundColor = [UIColor redColor];
    tocView.backgroundView.alpha = 0.5f;
    
    return [tocView autorelease];
}

#define BottomTocButtonDefaultWidth 100
#define BottomTocButtonDefaultHeight 50

+ (PCTocView *)bottomTocViewWithFrame:(CGRect)frame
{
    PCTocView *tocView = [[PCTocView alloc] initWithFrame:frame];
    
    [tocView setPosition:PCTocViewPositionBottom];
    
    // Adjust layout
    
    tocView.backgroundColor = [UIColor clearColor];
    
    CGSize tocSize = frame.size;
    
    CGRect buttonFrame = CGRectMake(0,
                                    0,
                                    BottomTocButtonDefaultWidth,
                                    BottomTocButtonDefaultHeight);
    tocView.button.frame = buttonFrame;
    tocView.button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    tocView.button.backgroundColor = [UIColor redColor];
    
    CGRect gridViewFrame = CGRectMake(0,
                                      buttonFrame.size.height,
                                      tocSize.width,
                                      tocSize.height - buttonFrame.size.height);
    tocView.gridView.frame = gridViewFrame;
    tocView.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tocView.gridView.backgroundColor = [UIColor clearColor];
    
    tocView.backgroundView.frame = gridViewFrame;
    tocView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tocView.backgroundView.backgroundColor = [UIColor blackColor];
    tocView.backgroundView.alpha = 0.5f;
    
    return [tocView autorelease];
}

@end
