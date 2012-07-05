//
//  RRComplexScrollView.m
//  ComplexScrollResearch
//
//  Created by Maxim Pervushin on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RRComplexScrollView.h"

@interface RRComplexScrollView ()
{
  
    UIView *_nextElementView;
}

- (void)initialize;
- (void)deinitialize;

- (void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeDownGesture:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeLeftGesture:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeRightGesture:(UISwipeGestureRecognizer *)recognizer;

@end

@implementation RRComplexScrollView
@synthesize datasource=_datasource;
@synthesize delegate=_delegate;
@synthesize currentElementView=_currentElementView;

- (void)initialize
{
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = 
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpGesture:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUpGestureRecognizer];
    [swipeUpGestureRecognizer release];
    
    UISwipeGestureRecognizer *swipeDownGestureRecognizer = 
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownGesture:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeDownGestureRecognizer];
    [swipeDownGestureRecognizer release];

    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = 
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftGesture:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    [swipeLeftGestureRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = 
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGesture:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGestureRecognizer];
    [swipeRightGestureRecognizer release];
}

- (void)deinitialize
{
}

- (void)dealloc
{
    [self deinitialize];
	_datasource = nil;
	_delegate = nil;
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor greenColor];
        [self initialize];
    }
    return self;
}


-(void)setCurrentElementView:(UIView *)currentElementView
{
	if (_currentElementView != currentElementView) {
       
        
        if (_currentElementView == nil) {
            CGRect currentElementViewFrame = CGRectMake(self.bounds.origin.x + 10, 
                                                        self.bounds.origin.y + 10,
                                                        self.bounds.size.width - 20,
                                                        self.bounds.size.height - 20);
            
            _currentElementView = [currentElementView retain];
			[_currentElementView setFrame:currentElementViewFrame];
            [self addSubview:_currentElementView];
        }
		
       
        [self setNeedsLayout];
    }

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    NSArray *subviews = self.subviews;
//    for (UIView *subview in subviews) {
//        if ([subview isKindOfClass:RRElementView.class]) {
//            
//        }
//    }
}

- (void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer
{
    [self scrollToBottomElementAnimated:YES];
}

- (void)swipeDownGesture:(UISwipeGestureRecognizer *)recognizer
{
    [self scrollToTopElementAnimated:YES];
}

- (void)swipeLeftGesture:(UISwipeGestureRecognizer *)recognizer
{
    [self scrollToRightElementAnimated:YES];
}

- (void)swipeRightGesture:(UISwipeGestureRecognizer *)recognizer
{
    [self scrollToLeftElementAnimated:YES];
}

- (void)scrollToTopElementAnimated:(BOOL)animated
{
	UIView* view = [self.datasource viewForConnection:TOP];
    if (view != nil) {
        
        CGRect currentElementViewFrame = _currentElementView.frame;
        CGRect nextElementViewFrame = CGRectMake(currentElementViewFrame.origin.x,  
                                                 currentElementViewFrame.origin.y - currentElementViewFrame.size.height - 20, 
                                                 currentElementViewFrame.size.width, 
                                                 currentElementViewFrame.size.height);
        _nextElementView = view;
        _nextElementView.frame = nextElementViewFrame;
        [self addSubview:_nextElementView];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextElementViewNewFrame = _currentElementView.frame;
            CGRect currentElementNewFrame = CGRectMake(currentElementViewFrame.origin.x, 
                                                       currentElementViewFrame.origin.y + currentElementViewFrame.size.height, 
                                                       currentElementViewFrame.size.width, 
                                                       currentElementViewFrame.size.height);
            
            _nextElementView.frame = nextElementViewNewFrame;
            _currentElementView.frame = currentElementNewFrame;
            
        } completion:^(BOOL finished) {
            
            
            [_currentElementView removeFromSuperview];
            _currentElementView = _nextElementView;
			[_delegate viewDidMoved];
            
        }];
        
    } else {
        NSLog(@"Scroll Up Blocked");
    }
}

- (void)scrollToBottomElementAnimated:(BOOL)animated
{
	UIView* view = [self.datasource viewForConnection:BOTTOM];
    if (view != nil) {
        
        CGRect currentElementViewFrame = _currentElementView.frame;
        CGRect nextElementViewFrame = CGRectMake(currentElementViewFrame.origin.x,  
                                                 currentElementViewFrame.origin.y + currentElementViewFrame.size.height + 20, 
                                                 currentElementViewFrame.size.width, 
                                                 currentElementViewFrame.size.height);
        _nextElementView = view;
        _nextElementView.frame = nextElementViewFrame;
        [self addSubview:_nextElementView];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextElementViewNewFrame = _currentElementView.frame;
            CGRect currentElementNewFrame = CGRectMake(currentElementViewFrame.origin.x, 
                                                       currentElementViewFrame.origin.y - currentElementViewFrame.size.height, 
                                                       currentElementViewFrame.size.width, 
                                                       currentElementViewFrame.size.height);
            
            _nextElementView.frame = nextElementViewNewFrame;
            _currentElementView.frame = currentElementNewFrame;
            
        } completion:^(BOOL finished) {
            
           
            [_currentElementView removeFromSuperview];
             _currentElementView = _nextElementView;
            [_delegate viewDidMoved];
        }];
        
    } else {
        NSLog(@"Scroll Down Blocked");
    }
}

- (void)scrollToLeftElementAnimated:(BOOL)animated
{
	UIView* view = [self.datasource viewForConnection:LEFT];
    if (view != nil) {
        
        CGRect currentElementViewFrame = _currentElementView.frame;
        CGRect nextElementViewFrame = CGRectMake(currentElementViewFrame.origin.x - currentElementViewFrame.size.width - 20, 
                                                 currentElementViewFrame.origin.y, 
                                                 currentElementViewFrame.size.width, 
                                                 currentElementViewFrame.size.height);
        _nextElementView =  view;
        _nextElementView.frame = nextElementViewFrame;
        [self addSubview:_nextElementView];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextElementViewNewFrame = _currentElementView.frame;
            CGRect currentElementNewFrame = CGRectMake(currentElementViewFrame.origin.x + currentElementViewFrame.size.width, 
                                                       currentElementViewFrame.origin.y, 
                                                       currentElementViewFrame.size.width, 
                                                       currentElementViewFrame.size.height);
            
            _nextElementView.frame = nextElementViewNewFrame;
            _currentElementView.frame = currentElementNewFrame;
            
        } completion:^(BOOL finished) {
            
			[_currentElementView removeFromSuperview];
            _currentElementView = _nextElementView;
            [_delegate viewDidMoved];
        }];
        
    } else {
        NSLog(@"Scroll Left Blocked");
    }
}

- (void)scrollToRightElementAnimated:(BOOL)animated
{
	UIView* view = [self.datasource viewForConnection:RIGHT];
    
    if (view != nil) {

        CGRect currentElementViewFrame = _currentElementView.frame;
        CGRect nextElementViewFrame = CGRectMake(currentElementViewFrame.origin.x + currentElementViewFrame.size.width + 20, 
                                                 currentElementViewFrame.origin.y, 
                                                 currentElementViewFrame.size.width, 
                                                 currentElementViewFrame.size.height);
        _nextElementView = view;
        _nextElementView.frame = nextElementViewFrame;
        [self addSubview:_nextElementView];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextElementViewNewFrame = _currentElementView.frame;
            CGRect currentElementNewFrame = CGRectMake(currentElementViewFrame.origin.x - currentElementViewFrame.size.width, 
                                                       currentElementViewFrame.origin.y, 
                                                       currentElementViewFrame.size.width, 
                                                       currentElementViewFrame.size.height);
            
            _nextElementView.frame = nextElementViewNewFrame;
            _currentElementView.frame = currentElementNewFrame;
            
        } completion:^(BOOL finished) {
            
            [_currentElementView removeFromSuperview];
             _currentElementView = _nextElementView;
            [_delegate viewDidMoved];
        }];
        
    } else {
        NSLog(@"Scroll Right Blocked");
    }
}

@end
