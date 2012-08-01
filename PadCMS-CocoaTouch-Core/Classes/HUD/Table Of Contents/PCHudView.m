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
#import "PCTOCGridViewCell.h"
#import "PCTopBarView.h"
#import "PCGridViewIndex.h"

#define TopBarHeight 43
NSString *EnabledKey = @"Enabled";

@interface PCHudView ()
{
    UIView *_tintView;
    PCTopBarView *_topBarView;
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
    if (_topTocView != nil) {
        [_topTocView.gridView reloadData];
    }
    
    if (_bottomTocView != nil) {
        [_bottomTocView.gridView reloadData];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, point) && subview.alpha > 0.01f) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - PCGridViewDelegate

- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index;
{
    [self didSelectIndex:index.column];
}

#pragma mark - PCGridViewDataSource

- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index
{
    PCTOCGridViewCell *item = (PCTOCGridViewCell *)[gridView dequeueReusableCell];
    
    if (item == nil) {
        item = [[[PCTOCGridViewCell alloc] init] autorelease];
    }
    
    [item setImage:[self imageForIndex:index.column]];
    
    return item;
}

- (NSUInteger)gridViewNumberOfColumns:(PCGridView *)gridView
{
    return [self itemsCount];
}

- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView
{
    return 1;
}

- (CGSize)gridViewCellSize:(PCGridView *)gridView
{
    if (gridView == _topTocView.gridView) {
        return [self topItemSize];
    } else if (gridView == _bottomTocView.gridView) {
        return [self bottomItemSize];
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

- (CGSize)topItemSize
{
    if ([self.dataSource respondsToSelector:@selector(hudView:itemSizeInTOC:)]) {
        return [self.dataSource hudView:self itemSizeInTOC:_topTocView.gridView];
    }

    return CGSizeZero;
}

- (CGSize)bottomItemSize
{
    if ([self.dataSource respondsToSelector:@selector(hudView:itemSizeInTOC:)]) {
        return [self.dataSource hudView:self itemSizeInTOC:_bottomTocView.gridView];
    }
    
    return CGSizeZero;
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
    if ([self.dataSource respondsToSelector:@selector(hudViewTOCItemsCount:)]) {
        return [self.dataSource hudViewTOCItemsCount:self];
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
