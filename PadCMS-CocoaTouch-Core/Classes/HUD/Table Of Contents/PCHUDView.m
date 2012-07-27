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

#import "PCHUDView.h"

#import "PCConfig.h"
#import "PCDefaultStyleElements.h"
#import "PCStyler.h"
#import "PCTOCGridViewCell.h"
#import "PCGridViewIndex.h"
#import "PCGridViewCell.h"
#import "RRTopBarView.h"

#define TopBarHeight 43
NSString *EnabledKey = @"Enabled";

@interface PCHUDView ()
{
    BOOL _topBarVisible;
    RRTopBarView *_topBarView;
    
    BOOL _topTOCVisible;
    UIButton *_topTOCButton;
    PCGridView *_topTOCView;
    UIView *_topTOCBackgroundView;
    
    BOOL _bottomTOCVisible;
    UIButton *_bottomTOCButton;
    PCGridView *_bottomTOCView;
    UIView *_bottomTOCBackgroundView;
    
    UIView *_tintView;
}

- (void)topTOCButtonAction:(UIButton *)sender;
- (void)bottomTOCButtonAction:(UIButton *)sender;
- (void)tintViewTapped:(UIGestureRecognizer *)recognizer;
- (void)animateTopTOC;
- (void)animateBottomTOC;

@end

@implementation PCHUDView
@synthesize delegate;
@synthesize dataSource;
@synthesize topBarView = _topBarView;
@synthesize topTOCButton = _topTOCButton;
@synthesize topTOCView = _topTOCView;
@synthesize bottomTOCButton = _bottomTOCButton;
@synthesize bottomTOCView = _bottomTOCView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _topTOCVisible = NO;
        _bottomTOCVisible = NO;
        
        _tintView = [[UIView alloc] initWithFrame:frame];
        _tintView.backgroundColor = [UIColor blackColor];
        _tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tintView.alpha = 0;
        [self addSubview:_tintView];
        
        UITapGestureRecognizer *tintViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                                       action:@selector(tintViewTapped:)];
        tintViewTapGestureRecognizer.numberOfTapsRequired = 1;
        tintViewTapGestureRecognizer.numberOfTouchesRequired = 1;
        [_tintView addGestureRecognizer:tintViewTapGestureRecognizer];
        [tintViewTapGestureRecognizer release];
        
        _topBarView = [[RRTopBarView alloc] initWithFrame:CGRectMake(0, -TopBarHeight, self.bounds.size.width, TopBarHeight)];
//        _topBarView.hidden = YES;
        _topBarView.alpha = 0.75f;
        _topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_topBarView];
        
        _topBarVisible = NO;
        
        
        NSDictionary *topTableOfContentsConfig = [PCConfig topTableOfContentsConfig];
        BOOL showTopTableOfContents = NO;
        
        if (topTableOfContentsConfig != nil) {
            showTopTableOfContents = [[topTableOfContentsConfig valueForKey:EnabledKey] boolValue];
        }
        
        if (showTopTableOfContents) {
            // top table of contents
            _topTOCButton = [[UIButton alloc] init];
            _topTOCButton.frame = CGRectMake(70, 0, 50, 50);
            _topTOCButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            [_topTOCButton addTarget:self
                                          action:@selector(topTOCButtonAction:) 
                                forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_topTOCButton];
            
            
            _topTOCBackgroundView = [[UIView alloc] init];
//            _topTOCBackgroundView.backgroundColor = [UIColor redColor];
            _topTOCBackgroundView.alpha = 0.5f;
            _topTOCBackgroundView.backgroundColor = [UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:1.00f];
            _topTOCBackgroundView.frame = CGRectMake(0,
                                                     -(frame.size.height / 2),
                                                     frame.size.width,
                                                     frame.size.height / 2);
            _topTOCBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:_topTOCBackgroundView];
            
            
            _topTOCView = [[PCGridView alloc] initWithOrientation:PCGridViewOrientationHorizontal];
            _topTOCView.backgroundColor = [UIColor clearColor];
            _topTOCView.dataSource = self;
            _topTOCView.delegate = self;
            _topTOCView.frame = CGRectMake(0,
                                           -(frame.size.height / 2),
                                           frame.size.width,
                                           frame.size.height / 2);
            _topTOCView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:_topTOCView];
        }
        
        NSDictionary *bottomTableOfContentsConfig = [PCConfig bottomTableOfContentsConfig];
        BOOL showBottomTableOfContents = NO;
        
        if (bottomTableOfContentsConfig != nil) {
            showBottomTableOfContents = [[bottomTableOfContentsConfig valueForKey:EnabledKey] boolValue];
        }
        
        if (showBottomTableOfContents) {
            // bottom table of contents
            _bottomTOCButton = [[UIButton alloc] init];
            [_bottomTOCButton addTarget:self
                                             action:@selector(bottomTOCButtonAction:) 
                                   forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_bottomTOCButton];
            
            _bottomTOCBackgroundView = [[UIView alloc] init];
            _bottomTOCBackgroundView.backgroundColor = [UIColor blackColor];
            _bottomTOCBackgroundView.alpha = 0.5f;
            [self addSubview:_bottomTOCBackgroundView];
            
            
            _bottomTOCView = [[PCGridView alloc] initWithOrientation:PCGridViewOrientationHorizontal];
            _bottomTOCView.backgroundColor = [UIColor clearColor];
            _bottomTOCView.dataSource = self;
            _bottomTOCView.delegate = self;
            [self addSubview:_bottomTOCView];
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // top bar view
//    _topBarView.frame = CGRectMake(0, 0, self.bounds.size.width, TopBarHeight);
    
    // tint view
    _tintView.frame = CGRectMake(0, TopBarHeight, self.bounds.size.width, self.bounds.size.height - TopBarHeight);
    
    // bottom table of contents
    
    CGSize bottomItemSize = [self bottomItemSize];
    CGSize bottomButtonSize = _bottomTOCButton.bounds.size;
    CGSize viewSize = self.bounds.size;

    CGRect bottomTocButtonRect = CGRectZero;
    CGRect bottomTocRect = CGRectZero;
    
    if  (_bottomTOCVisible) {
        
        bottomTocButtonRect = CGRectMake(0, 
                                         viewSize.height - bottomButtonSize.height - bottomItemSize.height,
                                         bottomButtonSize.width,
                                         bottomButtonSize.height);
        bottomTocRect = CGRectMake(0,
                                   viewSize.height - bottomItemSize.height,
                                   viewSize.width, 
                                   bottomItemSize.height);
        
    } else {
        
        bottomTocButtonRect = CGRectMake(0, 
                                         viewSize.height - bottomButtonSize.height,
                                         bottomButtonSize.width,
                                         bottomButtonSize.height);
        bottomTocRect = CGRectMake(0, 
                                   viewSize.height, 
                                   viewSize.width,
                                   bottomItemSize.height);
        
    }
    
    _bottomTOCButton.frame = bottomTocButtonRect;
    _bottomTOCView.frame = bottomTocRect;
    _bottomTOCBackgroundView.frame = bottomTocRect;
}

- (void)topTOCButtonAction:(UIButton *)sender
{
    [self animateTopTOC];
}

- (void)bottomTOCButtonAction:(UIButton *)sender
{
    [self animateBottomTOC];
}

- (void)tintViewTapped:(UIGestureRecognizer *)recognizer
{
    if (_topTOCVisible) {
        [self animateTopTOC];
    }
    
    if  (_bottomTOCVisible) {
        [self animateBottomTOC];
    }
}

- (void)animateTopBar
{
    CGPoint visibleTopBarCenter = CGPointMake(_topBarView.bounds.size.width / 2, _topBarView.bounds.size.height / 2);
    CGPoint hiddenTopBarCenter = CGPointMake(_topBarView.bounds.size.width / 2, -_topBarView.bounds.size.height / 2);
    
    void (^animationBlock)() = nil;
    void (^animationCompletionBlock)(BOOL finish) = nil;

    if (_topBarVisible) {
        // hide top bar
        animationBlock = ^() {
            _topBarView.center = hiddenTopBarCenter;
        };
        
        animationCompletionBlock = ^(BOOL finish) {
            _topBarVisible = NO;
        };
        
    } else {
        // show top bar
        animationBlock = ^() {
            _topBarView.center = visibleTopBarCenter;
        };
        
        animationCompletionBlock = ^(BOOL finish) {
            _topBarVisible = YES;
        };

    }
    
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                     animations:animationBlock
                     completion:animationCompletionBlock];
}

- (void)animateTopTOC
{
    CGPoint visibleTopTableOfContentsViewCenter = CGPointMake(_topTOCView.center.x,
                                                              _topTOCView.center.y + (self.bounds.size.height / 2) + TopBarHeight);
    CGPoint hiddenTopTableOfContentsViewCenter = CGPointMake(_topTOCView.center.x,
                                                             _topTOCView.center.y - (self.bounds.size.height / 2) - TopBarHeight);
    
    CGPoint visibleTopTableOfContentsButtonCenter = CGPointMake(_topTOCButton.center.x,
                                                                _topTOCButton.center.y + (self.bounds.size.height / 2) + TopBarHeight);
    CGPoint hiddenTopTableOfContentsButtonCenter = CGPointMake(_topTOCButton.center.x,
                                                               _topTOCButton.center.y - (self.bounds.size.height / 2) - TopBarHeight);
    
    void (^animationBlock)() = nil;
    void (^animationCompletionBlock)(BOOL finish) = nil;
    
    if (_topTOCVisible) {
        
        _tintView.alpha = 0.3f;
        
        [self willHideTOC:_topTOCView];

        animationBlock = ^() {
            _topTOCView.center = hiddenTopTableOfContentsViewCenter;
            _topTOCBackgroundView.center = hiddenTopTableOfContentsViewCenter;
            _topTOCButton.center = hiddenTopTableOfContentsButtonCenter;
            _tintView.alpha = 0;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _topTOCVisible = NO;
        };
        
        
    } else {
        
        _tintView.alpha = 0;
        
        [self willShowTOC:_topTOCView];

        animationBlock = ^() {
            _topTOCView.center = visibleTopTableOfContentsViewCenter;
            _topTOCBackgroundView.center = visibleTopTableOfContentsViewCenter;
            _topTOCButton.center = visibleTopTableOfContentsButtonCenter;
            _tintView.alpha = 0.3f;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _topTOCVisible = YES;
        };
    }
    
    [UIView animateWithDuration:0.3f 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:animationBlock 
                     completion:animationCompletionBlock];
}

- (void)animateBottomTOC
{
    CGPoint visibleBottomTableOfContentsViewCenter = CGPointMake(_bottomTOCView.center.x,
                                                                 _bottomTOCView.center.y - (_bottomTOCView.bounds.size.height));
    CGPoint hiddenBottomTableOfContentsViewCenter = CGPointMake(_bottomTOCView.center.x,
                                                                _bottomTOCView.center.y + (_bottomTOCView.bounds.size.height));
    
    CGPoint visibleBottomTableOfContentsButtonCenter = CGPointMake(_bottomTOCButton.center.x,
                                                                   _bottomTOCButton.center.y - (_bottomTOCView.bounds.size.height));
    CGPoint hiddenBottomTableOfContentsButtonCenter = CGPointMake(_bottomTOCButton.center.x,
                                                                  _bottomTOCButton.center.y + (_bottomTOCView.bounds.size.height));
    
    void (^animationBlock)() = nil;
    void (^animationCompletionBlock)(BOOL finish) = nil;
    
    if  (_bottomTOCVisible) {
        
        _tintView.alpha = 0.3f;
        
        [self willHideTOC:_bottomTOCView];

        animationBlock = ^() {
            _bottomTOCView.center = hiddenBottomTableOfContentsViewCenter;
            _bottomTOCBackgroundView.center = hiddenBottomTableOfContentsViewCenter;
            _bottomTOCButton.center = hiddenBottomTableOfContentsButtonCenter;
            _tintView.alpha = 0;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _bottomTOCVisible = NO;
        };
        
        
    } else {
        
        _tintView.alpha = 0;
        
        [self willShowTOC:_bottomTOCView];
        
        animationBlock = ^() {
            _bottomTOCView.center = visibleBottomTableOfContentsViewCenter;
            _bottomTOCBackgroundView.center = visibleBottomTableOfContentsViewCenter;
            _bottomTOCButton.center = visibleBottomTableOfContentsButtonCenter;
            _tintView.alpha = 0.3f;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _bottomTOCVisible = YES;
        };
    }
    
    [UIView animateWithDuration:0.3f 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:animationBlock 
                     completion:animationCompletionBlock];
}

- (void)reloadData
{
    if (_topTOCView != nil) {
        [_topTOCView reloadData];
    }
    
    if (_bottomTOCView != nil) {
        [_bottomTOCView reloadData];
    }
}

- (void)hideTOCs
{
    if (_topTOCVisible) {
        [self animateTopTOC];
    }
    
    if  (_bottomTOCVisible) {
        [self animateBottomTOC];
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

- (void)stylizeElementsWithOptions:(NSDictionary *)options
{
    UIImage *topTocMenuButtonBackgroundImage = [UIImage imageNamed:@"topTocMenuButtonBackground.png"];
    _topTOCButton.bounds = CGRectMake(0,
                                      0,
                                      topTocMenuButtonBackgroundImage.size.width,
                                      topTocMenuButtonBackgroundImage.size.height);
    [_topTOCButton setBackgroundImage:topTocMenuButtonBackgroundImage forState:UIControlStateNormal];
    _topTOCButton.backgroundColor = [UIColor clearColor];
    
//    [[PCStyler defaultStyler] stylizeElement:_topTOCButton withStyleName:PCTopTocButtonKey withOptions:options];
//    
//    [_topTOCButton setFrame:CGRectMake(self.frame.size.width - _topTOCButton.frame.size.width - 20, 
//                                                   0,
//                                                   _topTOCButton.frame.size.width,
//                                                   _topTOCButton.frame.size.height)];
    
    
    [[PCStyler defaultStyler] stylizeElement:_bottomTOCButton withStyleName:PCTocButtonKey withOptions:options];
    
    [_bottomTOCButton setFrame:CGRectMake(0, 
                                                      MAX(self.frame.size.height, self.frame.size.width) - _bottomTOCButton.frame.size.height,
                                                      _bottomTOCButton.frame.size.width,
                                                      _bottomTOCButton.frame.size.height)];
}

#pragma mark - RRItemsViewDelegate

- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index
{
    [self didSelectIndex:index.row];
}

#pragma mark - RRItemsViewDataSource

- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index
{
    PCTOCGridViewCell *item = (PCTOCGridViewCell *)[gridView dequeueReusableItemView];
    
    if (item == nil) {
        item = [[[PCTOCGridViewCell alloc] init] autorelease];
    }
    
    [item setImage:[self imageForIndex:index.row]];
    
    return item;
}

- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView
{
    return [self itemsCount];
}

- (CGSize)gridViewCellSize:(PCGridView *)gridView
{
    if (gridView == _topTOCView) {
        return [self topItemSize];
    } else if (gridView == _bottomTOCView) {
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

- (void)willShowTOC:(PCGridView *)tocView
{
    if ([self.delegate respondsToSelector:@selector(hudView:willShowTOC:)]) {
        [self.delegate hudView:self willShowTOC:tocView];
    }
}

- (void)willHideTOC:(PCGridView *)tocView
{
    if ([self.delegate respondsToSelector:@selector(hudView:willHideTOC:)]) {
        [self.delegate hudView:self willHideTOC:tocView];
    }
}

#pragma mark - data source

- (CGSize)topItemSize
{
    if ([self.dataSource respondsToSelector:@selector(hudView:itemSizeInTOC:)]) {
        return [self.dataSource hudView:self itemSizeInTOC:_topTOCView];
    }

    return CGSizeZero;
}

- (CGSize)bottomItemSize
{
    if ([self.dataSource respondsToSelector:@selector(hudView:itemSizeInTOC:)]) {
        return [self.dataSource hudView:self itemSizeInTOC:_bottomTOCView];
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

- (void)setTopBarVisible:(BOOL)visible
{
    if (visible != _topBarVisible) {
        [self animateTopBar];
    }
}

- (BOOL)isTopBarVisible
{
    return _topBarVisible;
}

@end
