//
//  RRComplexScrollView.m
//  ComplexScrollResearch
//
//  Created by Maxim Pervushin on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RRComplexScrollView.h"
#import "PCPageViewController.h"

@interface RRComplexScrollView ()
{
    PCPageViewController *_currentPageController;
    PCPageViewController *_nextPageController;
}

@property (nonatomic, retain) PCPageViewController *currentPageController;
@property (nonatomic, retain) PCPageViewController *nextPageController;

- (void)initialize;
- (void)deinitialize;

- (PCPageViewController *)initialPageController;
- (PCPageViewController *)topPageController;
- (PCPageViewController *)bottomPageController;
- (PCPageViewController *)leftPageController;
- (PCPageViewController *)rightPageController;

- (void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeDownGesture:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeLeftGesture:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeRightGesture:(UISwipeGestureRecognizer *)recognizer;

@end

@implementation RRComplexScrollView
@synthesize dataSource = _dataSource;
@synthesize currentPageController=_currentPageController;
@synthesize nextPageController=_nextPageController;


- (void)initialize
{
    self.currentPageController = nil;
    self.nextPageController = nil;
    
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
	[_currentPageController release], _currentPageController = nil;
	[_nextPageController release], _nextPageController = nil;
	_dataSource = nil;
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor whiteColor];
        [self initialize];
    }
    return self;
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

- (PCPageViewController *)initialPageController
{
    if ([self.dataSource respondsToSelector:@selector(pageControllerForPageController:connection:scrollView:)]) {
        return [self.dataSource pageControllerForPageController:nil 
                                                     connection:RRPageConnectionInvalid 
                                                     scrollView:self];
    }
    
    return nil;
}

- (PCPageViewController *)topPageController
{
    if ([self.dataSource respondsToSelector:@selector(pageControllerForPageController:connection:scrollView:)]) {
        return [self.dataSource pageControllerForPageController:_currentPageController 
                                                     connection:RRPageConnectionTop 
                                                     scrollView:self];
    }
    
    return nil;
}

- (PCPageViewController *)bottomPageController
{
    if ([self.dataSource respondsToSelector:@selector(pageControllerForPageController:connection:scrollView:)]) {
        return [self.dataSource pageControllerForPageController:_currentPageController 
                                                     connection:RRPageConnectionBottom 
                                                     scrollView:self];
    }
    
    return nil;
}

- (PCPageViewController *)leftPageController
{
    if ([self.dataSource respondsToSelector:@selector(pageControllerForPageController:connection:scrollView:)]) {
        return [self.dataSource pageControllerForPageController:_currentPageController 
                                                     connection:RRPageConnectionLeft 
                                                     scrollView:self];
    }
    
    return nil;
}

- (PCPageViewController *)rightPageController
{
    if ([self.dataSource respondsToSelector:@selector(pageControllerForPageController:connection:scrollView:)]) {
        return [self.dataSource pageControllerForPageController:_currentPageController 
                                                     connection:RRPageConnectionRight
                                                     scrollView:self];
    }
    
    return nil;
}

- (void)reloadData
{
    PCPageViewController *initialPageController = [self initialPageController];
    
    if (initialPageController != nil) {
        
        self.currentPageController = initialPageController;
        initialPageController.view.frame = self.bounds;
        [self addSubview:initialPageController.view];
        
    } else {
        NSLog(@"Invalid initial page controller");
    }
}

- (void)scrollToTopElementAnimated:(BOOL)animated
{
    PCPageViewController *topPageController = [self topPageController];
    
    if (topPageController != nil) {
        
        CGRect currentPageFrame = _currentPageController.view.frame;
        CGRect nextPageFrame = CGRectMake(currentPageFrame.origin.x,  
                                          currentPageFrame.origin.y - currentPageFrame.size.height - 20, 
                                          currentPageFrame.size.width, 
                                          currentPageFrame.size.height);
        
        self.nextPageController = topPageController;
        _nextPageController.view.frame = nextPageFrame;
        [self addSubview:_nextPageController.view];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextPageNewFrame = _currentPageController.view.frame;
            CGRect currentPageNewFrame = CGRectMake(currentPageFrame.origin.x, 
                                                    currentPageFrame.origin.y + currentPageFrame.size.height, 
                                                    currentPageFrame.size.width, 
                                                    currentPageFrame.size.height);
            
            _nextPageController.view.frame = nextPageNewFrame;
            _currentPageController.view.frame = currentPageNewFrame;
            
        } completion:^(BOOL finished) {
            
            [_currentPageController.view removeFromSuperview];
            self.currentPageController = _nextPageController;

        }];
        
    } else {
        NSLog(@"Scroll Up Blocked");
    }
}

- (void)scrollToBottomElementAnimated:(BOOL)animated
{
    PCPageViewController *bottomPageController = [self bottomPageController];
    
    if (bottomPageController != nil) {
        
        CGRect currentPageFrame = _currentPageController.view.frame;
        CGRect nextPageFrame = CGRectMake(currentPageFrame.origin.x,  
                                          currentPageFrame.origin.y + currentPageFrame.size.height + 20, 
                                          currentPageFrame.size.width, 
                                          currentPageFrame.size.height);
        
        self.nextPageController = bottomPageController;
        _nextPageController.view.frame = nextPageFrame;
        [self addSubview:_nextPageController.view];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextPageNewFrame = _currentPageController.view.frame;
            CGRect currentPageNewFrame = CGRectMake(currentPageFrame.origin.x, 
                                                    currentPageFrame.origin.y - currentPageFrame.size.height, 
                                                    currentPageFrame.size.width, 
                                                    currentPageFrame.size.height);
            
            _nextPageController.view.frame = nextPageNewFrame;
            _currentPageController.view.frame = currentPageNewFrame;
            
        } completion:^(BOOL finished) {
            
            [_currentPageController.view removeFromSuperview];
            self.currentPageController = _nextPageController;
            
        }];
        
    } else {
        NSLog(@"Scroll Down Blocked");
    }
}

- (void)scrollToLeftElementAnimated:(BOOL)animated
{
    PCPageViewController *leftPageController = [self leftPageController];

    if (leftPageController != nil) {
        
        CGRect currentPageFrame = _currentPageController.view.frame;
        CGRect nextPageFrame = CGRectMake(currentPageFrame.origin.x - currentPageFrame.size.width - 20, 
                                                 currentPageFrame.origin.y, 
                                                 currentPageFrame.size.width, 
                                                 currentPageFrame.size.height);
        
        self.nextPageController = leftPageController;
        _nextPageController.view.frame = nextPageFrame;
        [self addSubview:_nextPageController.view];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextPageNewFrame = _currentPageController.view.frame;
            CGRect currentPageNewFrame = CGRectMake(currentPageFrame.origin.x + currentPageFrame.size.width, 
                                                    currentPageFrame.origin.y, 
                                                    currentPageFrame.size.width, 
                                                    currentPageFrame.size.height);
            
            _nextPageController.view.frame = nextPageNewFrame;
            _currentPageController.view.frame = currentPageNewFrame;
            
        } completion:^(BOOL finished) {
            
            [_currentPageController.view removeFromSuperview];
            self.currentPageController = _nextPageController;
            
        }];
        
    } else {
        NSLog(@"Scroll Left Blocked");
    }
}

- (void)scrollToRightElementAnimated:(BOOL)animated
{
    PCPageViewController *rightPageController = [self rightPageController];
    
    if (rightPageController != nil) {

        CGRect currentPageFrame = _currentPageController.view.frame;
        CGRect nextPageFrame = CGRectMake(currentPageFrame.origin.x + currentPageFrame.size.width + 20, 
                                          currentPageFrame.origin.y, 
                                          currentPageFrame.size.width, 
                                          currentPageFrame.size.height);
        
        self.nextPageController = rightPageController;
        _nextPageController.view.frame = nextPageFrame;
        [self addSubview:_nextPageController.view];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect nextPageNewFrame = _currentPageController.view.frame;
            CGRect currentPageNewFrame = CGRectMake(currentPageFrame.origin.x - currentPageFrame.size.width, 
                                                       currentPageFrame.origin.y, 
                                                       currentPageFrame.size.width, 
                                                       currentPageFrame.size.height);
            
            _nextPageController.view.frame = nextPageNewFrame;
            _currentPageController.view.frame = currentPageNewFrame;
            
        } completion:^(BOOL finished) {
            
            [_currentPageController.view removeFromSuperview];
            self.currentPageController = _nextPageController;
            
        }];
        
    } else {
        NSLog(@"Scroll Right Blocked");
    }
}

@end
