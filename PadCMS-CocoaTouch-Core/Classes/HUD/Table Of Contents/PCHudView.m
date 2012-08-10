//
//  PCHUDView.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 7/16/12.
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

#import "PCHudView.h"

#import "PCConfig.h"
#import "PCDefaultStyleElements.h"
#import "PCGridViewCell.h"
#import "PCGridViewIndex.h"
#import "PCTocGridViewCell.h"
#import "PCTopBarView.h"
#import "PCGridViewIndex.h"
#import "PCSummaryView.h"
#import "PCSummaryGridViewCell.h"

#define TopBarHeight 43
#define SummaryViewXOffset -50
#define SummaryViewYOffset 20

NSString *EnabledKey = @"Enabled";

@interface PCHudView ()
{
    UIView *_tintView;
    PCTopBarView *_topBarView;
    PCSummaryView *_summaryView;
    PCTocView *_topTocView;
    PCTocView *_bottomTocView;
}

- (void)willTransitToc:(PCTocView *)tocView toState:(PCTocViewState)state;
- (void)didTransitToc:(PCTocView *)tocView toState:(PCTocViewState)state;

@end

@implementation PCHudView
@synthesize delegate;
@synthesize dataSource;
@synthesize topBarView = _topBarView;
@synthesize summaryView = _summaryView;
@synthesize topTocView = _topTocView;
@synthesize bottomTocView = _bottomTocView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // configure tint view
        _tintView = [[UIView alloc] initWithFrame:frame];
        _tintView.backgroundColor = [UIColor blackColor];
        _tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tintView.alpha = 0;
        [self addSubview:_tintView];
        
        // configure top bar
        _topBarView = [[PCTopBarView alloc] initWithFrame:CGRectMake(0, -TopBarHeight, self.bounds.size.width, TopBarHeight)];
        _topBarView.alpha = 0.75f;
        _topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_topBarView];
        
        // configure summary
        _summaryView = [[PCSummaryView alloc] initWithFrame:CGRectMake(0, 0, 400, 1000)];
        _summaryView.gridView.dataSource = self;
        _summaryView.gridView.delegate = self;
        
        // configure tocs
        NSDictionary *topTableOfContentsConfig = [PCConfig topTableOfContentsConfig];
        BOOL showTopTableOfContents = NO;
        
        if (topTableOfContentsConfig != nil) {
            showTopTableOfContents = [[topTableOfContentsConfig valueForKey:EnabledKey] boolValue];
        }
        
        if (showTopTableOfContents) {

            _topTocView = [[PCTocView topTocViewWithFrame:self.bounds] retain];
            _topTocView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            _topTocView.delegate = self;
            _topTocView.gridView.dataSource = self;
            _topTocView.gridView.delegate = self;
            [self addSubview:_topTocView];
            [_topTocView transitToState:PCTocViewStateHidden animated:NO];
            [_topTocView.gridView reloadData];
        }
        
        NSDictionary *bottomTableOfContentsConfig = [PCConfig bottomTableOfContentsConfig];
        BOOL showBottomTableOfContents = NO;
        
        if (bottomTableOfContentsConfig != nil) {
            showBottomTableOfContents = [[bottomTableOfContentsConfig valueForKey:EnabledKey] boolValue];
        }
        
        if (showBottomTableOfContents) {

            _bottomTocView = [[PCTocView bottomTocViewWithFrame:self.bounds] retain];
            _bottomTocView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            _bottomTocView.delegate = self;
            _bottomTocView.gridView.dataSource = self;
            _bottomTocView.gridView.delegate = self;
            [self addSubview:_bottomTocView];
            [_bottomTocView transitToState:PCTocViewStateHidden animated:NO];
            [_bottomTocView.gridView reloadData];
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_topTocView != nil) {
        CGSize topTocItemSize = [self topItemSize];
        _topTocView.bounds = CGRectMake(0,
                                           0,
                                           self.bounds.size.width,
                                           topTocItemSize.height + _topTocView.button.bounds.size.height);
        [_topTocView transitToState:_topTocView.state animated:YES];
    }
    
    if (_bottomTocView != nil) {
        CGSize bottomTocItemSize = [self bottomItemSize];
        _bottomTocView.bounds = CGRectMake(0,
                                           0,
                                           self.bounds.size.width,
                                           bottomTocItemSize.height + _bottomTocView.button.bounds.size.height);
        [_bottomTocView transitToState:_bottomTocView.state animated:YES];
    }
}

- (void)reloadData
{
    if (_summaryView != nil) {
        [_summaryView reloadData];
    }
    
    if (_topTocView != nil) {
        [_topTocView.gridView reloadData];
    }
    
    if (_bottomTocView != nil) {
        [_bottomTocView.gridView reloadData];
    }
}

- (void)showSummaryInView:(UIView *)view atPoint:(CGPoint)point animated:(BOOL)animated
{
    if (_summaryView == nil) {
        return;
    }
        
    CGSize containerViewSize = view.bounds.size;
    CGSize summaryViewSize = _summaryView.bounds.size;
    
    if (animated) {
        _summaryView.hidden = NO;
        _summaryView.alpha = 0;
        [view addSubview:_summaryView];
        _summaryView.frame = CGRectMake(point.x + SummaryViewXOffset,
                                        point.y + SummaryViewYOffset,
                                        summaryViewSize.width,
                                        containerViewSize.height - point.y - 100);

        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                         animations:^{
                             _summaryView.alpha = 1;
                         } completion:nil];
    } else {
        _summaryView.alpha = 1;
        [view addSubview:_summaryView];
        _summaryView.frame = CGRectMake(point.x + SummaryViewXOffset,
                                        point.y + SummaryViewYOffset,
                                        summaryViewSize.width,
                                        containerViewSize.height - point.y - 100);
        _summaryView.hidden = NO;
    }
}

- (void)hideSummaryAnimated:(BOOL)animated
{
    if (_summaryView == nil) {
        return;
    }

    if (animated) {
        _summaryView.alpha = 1;
        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                         animations:^{
                             _summaryView.alpha = 0;
                         } completion:^(BOOL finished) {
                             [_summaryView removeFromSuperview];
                             _summaryView.hidden = YES;
                         }];
    } else {
        [_summaryView removeFromSuperview];
        _summaryView.hidden = YES;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(_topBarView.frame, point)) {
        return YES;
    }
    
    if (_topTocView != nil && CGRectContainsPoint(_topTocView.frame, point)) {
        return [_topTocView pointInside:[self convertPoint:point toView:_topTocView] withEvent:event];
    }
    
    if (_bottomTocView != nil && CGRectContainsPoint(_bottomTocView.frame, point)) {
        return [_bottomTocView pointInside:[self convertPoint:point toView:_bottomTocView] withEvent:event];
    }
    
    if (_summaryView != nil && CGRectContainsPoint(_summaryView.frame, point)) {
        return [_summaryView pointInside:[self convertPoint:point toView:_summaryView] withEvent:event];
    }
    
    return NO;
}

#pragma mark - PCGridViewDelegate

- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index;
{
    if (gridView == _summaryView.gridView) {
        [self didSelectIndex:index.row];
    } else {
        [self didSelectIndex:index.column];
    }
}

#pragma mark - PCGridViewDataSource

- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index
{
    PCGridViewCell *item = [gridView dequeueReusableCell];
    
    if (gridView == _topTocView.gridView || gridView == _bottomTocView.gridView) {
       
        if (item == nil) {
            item = [[[PCTocGridViewCell alloc] init] autorelease];
        }
        
        [(PCTocGridViewCell *)item setImage:[self imageForIndex:index.column]];
        
    } else if (gridView == _summaryView.gridView) {
        
        if (item == nil) {
            item = [[[PCSummaryGridViewCell alloc] init] autorelease];
        }
        
        [(PCSummaryGridViewCell *)item setImage:[self summaryImageForIndex:index.row]
                                           text:[self summaryTextForIndex:index.row]];
    
    }
    
    return item;
}

- (NSUInteger)gridViewNumberOfColumns:(PCGridView *)gridView
{
    if (gridView == _topTocView.gridView || gridView == _bottomTocView.gridView) {
        return [self itemsCount];
    } else if (gridView == _summaryView.gridView) {
        return 1;
    }

    return 0;
}

- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView
{
    if (gridView == _topTocView.gridView || gridView == _bottomTocView.gridView) {
        return 1;
    } else if (gridView == _summaryView.gridView) {
        return [self itemsCount];
    }
    
    return 0;
}

- (CGSize)gridViewCellSize:(PCGridView *)gridView
{
    if (gridView == _topTocView.gridView) {
        return [self topItemSize];
    } else if (gridView == _bottomTocView.gridView) {
        return [self bottomItemSize];
    } else if (gridView == _summaryView.gridView) {
        return [self summaryItemSize];
    }
    
    return CGSizeZero;
}

#pragma mark - delegate

- (void)didSelectIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(hudView:didSelectIndex:)]) {
        [self.delegate hudView:self didSelectIndex:index];
    }
}

- (void)willTransitToc:(PCTocView *)tocView toState:(PCTocViewState)state
{
    if ([self.delegate respondsToSelector:@selector(hudView:willTransitToc:toState:)]) {
        [self.delegate hudView:self willTransitToc:tocView toState:state];
    }
}

- (void)didTransitToc:(PCTocView *)tocView toState:(PCTocViewState)state
{
    if ([self.delegate respondsToSelector:@selector(hudView:didTransitToc:toState:)]) {
        [self.delegate hudView:self didTransitToc:tocView toState:state];
    }
}

#pragma mark - data source

- (CGSize)summaryItemSize
{
    if ([self.dataSource respondsToSelector:@selector(hudView:itemSizeInToc:)]) {
        return [self.dataSource hudView:self itemSizeInToc:_summaryView.gridView];
    }
    
    return CGSizeZero;
}

- (CGSize)topItemSize
{
    if ([self.dataSource respondsToSelector:@selector(hudView:itemSizeInToc:)]) {
        return [self.dataSource hudView:self itemSizeInToc:_topTocView.gridView];
    }

    return CGSizeZero;
}

- (CGSize)bottomItemSize
{
    if ([self.dataSource respondsToSelector:@selector(hudView:itemSizeInToc:)]) {
        return [self.dataSource hudView:self itemSizeInToc:_bottomTocView.gridView];
    }
    
    return CGSizeZero;
}

- (UIImage *)summaryImageForIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(hudView:summaryImageForIndex:)]) {
        return [self.dataSource hudView:self summaryImageForIndex:index];
    }
    
    return nil;
}

- (NSString *)summaryTextForIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(hudView:summaryTextForIndex:)]) {
        return [self.dataSource hudView:self summaryTextForIndex:index];
    }
    
    return nil;
}

- (UIImage *)imageForIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(hudView:tocImageForIndex:)]) {
        return [self.dataSource hudView:self tocImageForIndex:index];
    }
    
    return nil;
}

- (NSUInteger)itemsCount
{
    if ([self.dataSource respondsToSelector:@selector(hudViewTocItemsCount:)]) {
        return [self.dataSource hudViewTocItemsCount:self];
    }
    
    return 0;
}

#pragma mark - PCTocViewDelegate

- (BOOL)tocView:(PCTocView *)tocView transitToState:(PCTocViewState)state animated:(BOOL)animated
{
    if (tocView == _topTocView) {
        
        void (^transitionBlock)(void) = ^(void) {
            
            [self willTransitToc:tocView toState:state];
            
            CGRect selfBounds = self.bounds;
            CGSize topBarViewSize = _topBarView.bounds.size;
            CGRect activeFrame = CGRectZero;
            
            if (state == PCTocViewStateActive) {
                activeFrame = CGRectMake(0,
                                         topBarViewSize.height,
                                         selfBounds.size.width,
                                         selfBounds.size.height - topBarViewSize.height);
                _topBarView.center = CGPointMake(topBarViewSize.width / 2,
                                                 topBarViewSize.height / 2);

            } else {
                activeFrame = CGRectMake(0,
                                         0,
                                         selfBounds.size.width,
                                         selfBounds.size.height);
                _topBarView.center = CGPointMake(topBarViewSize.width / 2,
                                                 -(topBarViewSize.height / 2));
            }
            
            tocView.center = [tocView centerForState:state containerBounds:activeFrame];
        };
        
        void (^completionBlock)(BOOL) = ^(BOOL finished) {
            [self didTransitToc:tocView toState:state];
        };
        
        if (animated) {
            [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                             animations:transitionBlock
                             completion:completionBlock];
        } else {
            transitionBlock();
            completionBlock(YES);
        }
        
        return YES;
        
    } else if (tocView == _bottomTocView) {
        
        void (^transitionBlock)(void) = ^(void) {
            [self willTransitToc:tocView toState:state];

            CGRect selfBounds = self.bounds;
            CGSize topBarViewSize = _topBarView.bounds.size;
            CGRect activeFrame = CGRectZero;
            
            if (state == PCTocViewStateActive) {
                activeFrame = CGRectMake(0,
                                         topBarViewSize.height,
                                         selfBounds.size.width,
                                         selfBounds.size.height - topBarViewSize.height);
            } else if (state == PCTocViewStateVisible) {
                activeFrame = CGRectMake(0,
                                         topBarViewSize.height,
                                         selfBounds.size.width,
                                         selfBounds.size.height - topBarViewSize.height);
                _topBarView.center = CGPointMake(topBarViewSize.width / 2,
                                                 topBarViewSize.height / 2);
            } else {
                activeFrame = CGRectMake(0,
                                         0,
                                         selfBounds.size.width,
                                         selfBounds.size.height);
                _topBarView.center = CGPointMake(topBarViewSize.width / 2,
                                                 -(topBarViewSize.height / 2));
            }
            
            // do not show empty toc
            if (state == PCTocViewStateVisible && [self itemsCount] == 0) {
                tocView.center = [tocView centerForState:PCTocViewStateHidden containerBounds:activeFrame];
            } else {
                tocView.center = [tocView centerForState:state containerBounds:activeFrame];
            }
        };
        
        void (^completionBlock)(BOOL) = ^(BOOL finished) {
            [self didTransitToc:tocView toState:state];
        };

        if (animated) {
            [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                             animations:transitionBlock
                             completion:completionBlock];
        } else {
            transitionBlock();
            completionBlock(YES);
        }

        return YES;
    }
    
    return NO;
}

@end
