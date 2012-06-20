//
//  PCScrollView.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/1/12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

#import "PCScrollView.h"

#import "PCConfig.h"
#import "PCStyler.h"

#define HorizontalScrollButtonWidth 27
#define HorizontalScrollButtonHeight 60
#define VerticalScrollButtonWidth 60
#define VerticalScrollButtonHeight 27
#define ScrollShowingThreshold 3

#define ScrollUpButtonBackgroundImage @"scroll-up-button-background.png"
#define ScrollUpButtonForegroundImage @"scroll-up-button-foreground.png"
#define ScrollDownButtonBackgroundImage @"scroll-down-button-background.png"
#define ScrollDownButtonForegroundImage @"scroll-down-button-foreground.png"
#define ScrollLeftButtonBackgroundImage @"scroll-left-button-background.png"
#define ScrollLeftButtonForegroundImage @"scroll-left-button-foreground.png"
#define ScrollRightButtonBackgroundImage @"scroll-right-button-background.png"
#define ScrollRightButtonForegroundImage @"scroll-right-button-foreground.png"

NSMutableSet *ViewsToIgnoreTouches = nil;

@interface PCScrollView ()
{
    UIButton *_scrollUpButton;
    UIButton *_scrollDownButton;
    UIButton *_scrollLeftButton;
    UIButton *_scrollRightButton;
}

- (void)createScrollButtonsIfNotExists;
- (void)destroyScrollButtonsIfExists;
- (void)layoutScrollButtons;

- (void)scrollUpButtonTapped:(UIButton *)sender;
- (void)scrollDownButtonTapped:(UIButton *)sender;
- (void)scrollLeftButtonTapped:(UIButton *)sender;
- (void)scrollRightButtonTapped:(UIButton *)sender;

@end


@implementation PCScrollView

@synthesize horizontalScrollButtonsEnabled = _horizontalScrollButtonsEnabled;
@synthesize verticalScrollButtonsEnabled = _verticalScrollButtonsEnabled;
@synthesize scrollButtonsTintColor = _scrollButtonsTintColor;

- (void)dealloc
{
    [self destroyScrollButtonsIfExists];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _horizontalScrollButtonsEnabled = NO;
        _verticalScrollButtonsEnabled = NO;
        _scrollButtonsTintColor = [UIColor clearColor];
        _scrollUpButton = nil;
        _scrollDownButton = nil;
        _scrollLeftButton = nil;
        _scrollRightButton = nil;
    }
    return self;
}

- (void)createScrollButtonsIfNotExists
{
    if (_verticalScrollButtonsEnabled) {
        
        if (_scrollUpButton == nil) {
            _scrollUpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [_scrollUpButton setImage:[UIImage imageNamed:ScrollUpButtonForegroundImage] 
                             forState:UIControlStateNormal];
            [_scrollUpButton setBackgroundImage:[UIImage imageNamed:ScrollUpButtonBackgroundImage] 
                                       forState:UIControlStateNormal];
            [_scrollUpButton addTarget:self action:@selector(scrollUpButtonTapped:)
                      forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_scrollUpButton];
        }
        
        if (_scrollDownButton == nil) {
            _scrollDownButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            [_scrollDownButton setImage:[UIImage imageNamed:ScrollDownButtonForegroundImage] 
                               forState:UIControlStateNormal];
            [_scrollDownButton setBackgroundImage:[UIImage imageNamed:ScrollDownButtonBackgroundImage] 
                                         forState:UIControlStateNormal];
            [_scrollDownButton addTarget:self action:@selector(scrollDownButtonTapped:)
                        forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_scrollDownButton];
        }
        
    }
    
    if (_horizontalScrollButtonsEnabled) {
        
        if (_scrollLeftButton == nil) {
            _scrollLeftButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];;
            [_scrollLeftButton setImage:[UIImage imageNamed:ScrollLeftButtonForegroundImage] 
                               forState:UIControlStateNormal];
            [_scrollLeftButton setBackgroundImage:[UIImage imageNamed:ScrollLeftButtonBackgroundImage] 
                                         forState:UIControlStateNormal];
            [_scrollLeftButton addTarget:self action:@selector(scrollLeftButtonTapped:)
                        forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_scrollLeftButton];
        }
        
        if (_scrollRightButton == nil) {
            _scrollRightButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];;
            [_scrollRightButton setImage:[UIImage imageNamed:ScrollRightButtonForegroundImage] 
                                forState:UIControlStateNormal];
            [_scrollRightButton setBackgroundImage:[UIImage imageNamed:ScrollRightButtonBackgroundImage] 
                                          forState:UIControlStateNormal];
            [_scrollRightButton addTarget:self action:@selector(scrollRightButtonTapped:)
                         forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_scrollRightButton];
        }
        
    }
    
    if ([PCConfig isScrollViewScrollButtonsDisabled]) {
        _scrollUpButton.hidden = YES;
        _scrollDownButton.hidden = YES;
        _scrollLeftButton.hidden = YES;
        _scrollRightButton.hidden = YES;
    }
}

- (void)destroyScrollButtonsIfExists
{
    if (_scrollUpButton != nil) {
        [_scrollUpButton release];
    }
    
    if (_scrollDownButton != nil) {
        [_scrollDownButton release];
    }
    
    if (_scrollLeftButton != nil) {
        [_scrollLeftButton release];
    }
    
    if (_scrollRightButton != nil) {
        [_scrollRightButton release];
    }
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([ViewsToIgnoreTouches containsObject:view]) {
        return NO;
    }
    
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if ([ViewsToIgnoreTouches containsObject:subview]) {
            self.delaysContentTouches = YES;
            break;
        } else {
            self.delaysContentTouches = NO;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutScrollButtons];
}

- (void)setHorizontalScrollButtonsEnabled:(BOOL)horizontalScrollButtonsEnabled
{
    _horizontalScrollButtonsEnabled = horizontalScrollButtonsEnabled;
    
    [self layoutScrollButtons];
}

- (void)setVerticalScrollButtonsEnabled:(BOOL)verticalScrollButtonsEnabled
{
    _verticalScrollButtonsEnabled = verticalScrollButtonsEnabled;
    
    [self layoutScrollButtons];
}

- (void)setScrollButtonsTintColor:(UIColor *)scrollButtonsTintColor
{
    if (_scrollButtonsTintColor != scrollButtonsTintColor) {
        [_scrollButtonsTintColor release];
        _scrollButtonsTintColor = [scrollButtonsTintColor retain]; 
    }
    
    if (_scrollUpButton != nil) {
        UIImage *newBackgroundImage = [PCStyler colorizeImage:[UIImage imageNamed:ScrollUpButtonBackgroundImage] 
                                                        color:_scrollButtonsTintColor
                                                      overlay:nil];
        
        [_scrollUpButton setBackgroundImage:newBackgroundImage forState:UIControlStateNormal];
    }
    
    if (_scrollDownButton != nil) {
        UIImage *newBackgroundImage = [PCStyler colorizeImage:[UIImage imageNamed:ScrollDownButtonBackgroundImage] 
                                                        color:_scrollButtonsTintColor
                                                      overlay:nil];
        
        [_scrollDownButton setBackgroundImage:newBackgroundImage forState:UIControlStateNormal];
    }
    
    if (_scrollLeftButton != nil) {
        UIImage *newBackgroundImage = [PCStyler colorizeImage:[UIImage imageNamed:ScrollLeftButtonBackgroundImage] 
                                                        color:_scrollButtonsTintColor
                                                      overlay:nil];
        
        [_scrollLeftButton setBackgroundImage:newBackgroundImage forState:UIControlStateNormal];
    }
    
    if (_scrollRightButton != nil) {
        UIImage *newBackgroundImage = [PCStyler colorizeImage:[UIImage imageNamed:ScrollRightButtonBackgroundImage] 
                                                        color:_scrollButtonsTintColor
                                                      overlay:nil];
        
        [_scrollRightButton setBackgroundImage:newBackgroundImage forState:UIControlStateNormal];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    [self layoutScrollButtons];
}

- (void)layoutScrollButtons
{
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    CGFloat contentWidth = self.contentSize.width;
    CGFloat contentHeight = self.contentSize.height;
    CGFloat offsetX = self.contentOffset.x;
    CGFloat offsetY = self.contentOffset.y;
    
    [self createScrollButtonsIfNotExists];
    
    if (_verticalScrollButtonsEnabled) {
        
        CGFloat topIndicatorButtonLeft = (selfWidth - VerticalScrollButtonWidth) / 2 + offsetX;
        CGFloat topIndicatorButtonTop = offsetY;
        _scrollUpButton.frame = CGRectMake(topIndicatorButtonLeft, 
                                           topIndicatorButtonTop, 
                                           VerticalScrollButtonWidth, 
                                           VerticalScrollButtonHeight);
        
        BOOL shouldHideTopIndicator = topIndicatorButtonTop - ScrollShowingThreshold <= 0 ? YES : NO;
        if (shouldHideTopIndicator || [PCConfig isScrollViewScrollButtonsDisabled]) {
            _scrollUpButton.hidden = YES;
        } else {
            _scrollUpButton.hidden = NO;
            [self bringSubviewToFront:_scrollUpButton];
        }
        
        CGFloat bottomIndicatorButtonLeft = (selfWidth - VerticalScrollButtonWidth) / 2 + offsetX;
        CGFloat bottomIndicatorButtonTop = selfHeight - VerticalScrollButtonHeight + offsetY;
        _scrollDownButton.frame = CGRectMake(bottomIndicatorButtonLeft, 
                                             bottomIndicatorButtonTop, 
                                             VerticalScrollButtonWidth, 
                                             VerticalScrollButtonHeight);
        
        BOOL shouldHideBottomIndicator = bottomIndicatorButtonTop + VerticalScrollButtonHeight >= contentHeight - ScrollShowingThreshold ? YES : NO;
        if (shouldHideBottomIndicator || [PCConfig isScrollViewScrollButtonsDisabled]) {
            _scrollDownButton.hidden = YES;
        } else {
            _scrollDownButton.hidden = NO;
            [self bringSubviewToFront:_scrollDownButton];
        }
    }
    
    if (_horizontalScrollButtonsEnabled) {
        
        CGFloat leftIndicatorButtonLeft = offsetX;
        CGFloat leftIndicatorButtonTop = (selfHeight - HorizontalScrollButtonHeight) / 2 + offsetY;
        _scrollLeftButton.frame = CGRectMake(leftIndicatorButtonLeft, 
                                             leftIndicatorButtonTop, 
                                             HorizontalScrollButtonWidth, 
                                             HorizontalScrollButtonHeight);
        
        BOOL shouldHideLeftIndicator = leftIndicatorButtonLeft - ScrollShowingThreshold <= 0 ? YES : NO;
        if (shouldHideLeftIndicator || [PCConfig isScrollViewScrollButtonsDisabled]) {
            _scrollLeftButton.hidden = YES;
        } else {
            _scrollLeftButton.hidden = NO;
            [self bringSubviewToFront:_scrollLeftButton];
        }
        
        CGFloat rightIndicatorButtonLeft = selfWidth - HorizontalScrollButtonWidth + offsetX;
        CGFloat rightIndicatorButtonTop = (selfHeight - HorizontalScrollButtonHeight) / 2 + offsetY;
        _scrollRightButton.frame = CGRectMake(rightIndicatorButtonLeft, 
                                              rightIndicatorButtonTop, 
                                              HorizontalScrollButtonWidth, 
                                              HorizontalScrollButtonHeight);
        
        BOOL shouldHideRightIndicator = rightIndicatorButtonLeft + HorizontalScrollButtonWidth >= contentWidth - ScrollShowingThreshold ? YES : NO;
        if (shouldHideRightIndicator || [PCConfig isScrollViewScrollButtonsDisabled]) {
            _scrollRightButton.hidden = YES;
        } else {
            _scrollRightButton.hidden = NO;
            [self bringSubviewToFront:_scrollRightButton];
        }
    }
}

- (void)scrollUpButtonTapped:(UIButton *)sender
{
    [self scrollUp];
}

- (void)scrollDownButtonTapped:(UIButton *)sender
{
    [self scrollDown];
}

- (void)scrollLeftButtonTapped:(UIButton *)sender
{
    [self scrollLeft];
}

- (void)scrollRightButtonTapped:(UIButton *)sender
{
    [self scrollRight];
}

#pragma mark - public methods

- (void)scrollLeft
{
    if (self.decelerating) {
        return;
    }
    
    CGPoint currentContentOffset = self.contentOffset;
    CGSize viewFrameSize = self.bounds.size;
    CGPoint desirableContentOffset = CGPointMake(currentContentOffset.x - viewFrameSize.width,
                                                 currentContentOffset.y);
    
    CGRect rect = CGRectMake(desirableContentOffset.x, desirableContentOffset.y, 
                             viewFrameSize.width, viewFrameSize.height);
    [self scrollRectToVisible:rect animated:YES];
}

- (void)scrollRight
{
    if (self.decelerating) {
        return;
    }
    
    CGPoint currentContentOffset = self.contentOffset;
    CGSize viewFrameSize = self.bounds.size;
    CGPoint desirableContentOffset = CGPointMake(currentContentOffset.x + viewFrameSize.width,
                                                 currentContentOffset.y);
    
    CGRect rect = CGRectMake(desirableContentOffset.x, desirableContentOffset.y, 
                             viewFrameSize.width, viewFrameSize.height);
    
    [self scrollRectToVisible:rect animated:YES];
}

- (void)scrollUp
{
    if (self.decelerating) {
        return;
    }
    
    CGPoint currentContentOffset = self.contentOffset;
    CGSize viewFrameSize = self.bounds.size;
    CGPoint desirableContentOffset = CGPointMake(currentContentOffset.x,
                                                 currentContentOffset.y - viewFrameSize.height);
    
    CGRect rect = CGRectMake(desirableContentOffset.x, desirableContentOffset.y, 
                             viewFrameSize.width, viewFrameSize.height);
    
    [self scrollRectToVisible:rect animated:YES];
}

- (void)scrollDown
{
    if (self.decelerating) {
        return;
    }
    
    CGPoint currentContentOffset = self.contentOffset;
    CGSize viewFrameSize = self.bounds.size;
    CGPoint desirableContentOffset = CGPointMake(currentContentOffset.x,
                                                 currentContentOffset.y + viewFrameSize.height);
    
    CGRect rect = CGRectMake(desirableContentOffset.x, desirableContentOffset.y, 
                             viewFrameSize.width, viewFrameSize.height);
    
    [self scrollRectToVisible:rect animated:YES];
}

#pragma mark - public class methods

+ (void)addViewToIgnoreTouches:(UIView *)view
{
    if (ViewsToIgnoreTouches == nil) {
        ViewsToIgnoreTouches = [[NSMutableSet alloc] init];
    }
    [ViewsToIgnoreTouches addObject:view];
}

+ (void)removeViewFromIgnoreTouches:(UIView *)view
{
    if (ViewsToIgnoreTouches != nil) {
        [ViewsToIgnoreTouches removeObject:view];
    }
}

+ (void)removeAllViewsToIgnoreTouches
{
    if (ViewsToIgnoreTouches != nil) {
        [ViewsToIgnoreTouches removeAllObjects];
    }
}

@end
