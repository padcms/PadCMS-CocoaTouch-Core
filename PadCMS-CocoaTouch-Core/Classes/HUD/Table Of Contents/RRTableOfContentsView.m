//
//  RRTableOfContentsView.m
//  ReusingScrollViewDemo
//
//  Created by Maxim Pervushin on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RRTableOfContentsView.h"

#import "RRItemsViewIndex.h"
#import "RRItemsViewItem.h"
#import "RRTableOfContentsItem.h"
#import "PCStyler.h"
#import "PCConfig.h"
#import "PCDefaultStyleElements.h"

#define TopBarHeight 43
NSString *EnabledKey = @"Enabled";

@interface RRTableOfContentsView ()
{
    UIView *_topBarView;
    
    BOOL _topTableOfContentsVisible;
    UIButton *_topTableOfContentsButton;
    RRItemsView *_topTableOfContentsView;
    UIView *_topTableOfContentsBackgroundView;
    
    BOOL _bottomTableOfContentsVisible;
    UIButton *_bottomTableOfContentsButton;
    RRItemsView *_bottomTableOfContentsView;
    UIView *_bottomTableOfContentsBackgroundView;
    
    UIView *_tintView;
}

- (void)topTableOfContentsButtonAction:(UIButton *)sender;
- (void)bottomTableOfContentsButtonAction:(UIButton *)sender;
- (void)tintViewTapped:(UIGestureRecognizer *)recognizer;
- (void)animateTopTableOfContents;
- (void)animateBottomTableOfContents;

@end

@implementation RRTableOfContentsView
@synthesize dataSource;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _topTableOfContentsVisible = NO;
        _bottomTableOfContentsVisible = NO;
        
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
        
        _topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -TopBarHeight, self.bounds.size.width, TopBarHeight)];
        _topBarView.backgroundColor = [UIColor blackColor];
        _topBarView.alpha = 0;
        _topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_topBarView];
        
        
        NSDictionary *topTableOfContentsConfig = [PCConfig topTableOfContentsConfig];
        BOOL showTopTableOfContents = NO;
        
        if (topTableOfContentsConfig != nil) {
            showTopTableOfContents = [[topTableOfContentsConfig valueForKey:EnabledKey] boolValue];
        }
        
        if (showTopTableOfContents) {
            // top table of contents
            _topTableOfContentsButton = [[UIButton alloc] init];
            _topTableOfContentsButton.frame = CGRectMake(frame.size.width - 100, 0, 50, 50);
            //        _topTableOfContentsButton.backgroundColor = [UIColor redColor];
            _topTableOfContentsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            [_topTableOfContentsButton addTarget:self
                                          action:@selector(topTableOfContentsButtonAction:) 
                                forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_topTableOfContentsButton];
            
            
            
            _topTableOfContentsBackgroundView = [[UIView alloc] init];
            _topTableOfContentsBackgroundView.backgroundColor = [UIColor redColor];
            _topTableOfContentsBackgroundView.alpha = 0.5f;
            _topTableOfContentsBackgroundView.frame = CGRectMake(0,
                                                                 -(frame.size.height / 2),
                                                                 frame.size.width,
                                                                 frame.size.height / 2);
            _topTableOfContentsBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:_topTableOfContentsBackgroundView];
            
            
            _topTableOfContentsView = [[RRItemsView alloc] initWithOrientation:RRItemsViewOrientationHorizontal];
            _topTableOfContentsView.backgroundColor = [UIColor clearColor];
            _topTableOfContentsView.dataSource = self;
            _topTableOfContentsView.delegate = self;
            _topTableOfContentsView.frame = CGRectMake(0,
                                                       -(frame.size.height / 2),
                                                       frame.size.width,
                                                       frame.size.height / 2);
            _topTableOfContentsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:_topTableOfContentsView];
        }
        
        NSDictionary *bottomTableOfContentsConfig = [PCConfig bottomTableOfContentsConfig];
        BOOL showBottomTableOfContents = NO;
        
        if (bottomTableOfContentsConfig != nil) {
            showBottomTableOfContents = [[bottomTableOfContentsConfig valueForKey:EnabledKey] boolValue];
        }
        
        if (showBottomTableOfContents) {
            // bottom table of contents
            _bottomTableOfContentsButton = [[UIButton alloc] init];
//            _bottomTableOfContentsButton.frame = CGRectMake(100, self.bounds.size.height - 50, 50, 50);
//            _bottomTableOfContentsButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            

            [_bottomTableOfContentsButton addTarget:self
                                             action:@selector(bottomTableOfContentsButtonAction:) 
                                   forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_bottomTableOfContentsButton];
            
            
            
            _bottomTableOfContentsBackgroundView = [[UIView alloc] init];
            _bottomTableOfContentsBackgroundView.backgroundColor = [UIColor blackColor];
            _bottomTableOfContentsBackgroundView.alpha = 0.5f;
//            _bottomTableOfContentsBackgroundView.frame = CGRectMake(0,
//                                                                    frame.size.height,
//                                                                    frame.size.width,
//                                                                    frame.size.height / 3);
//            _bottomTableOfContentsBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//            _bottomTableOfContentsBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:_bottomTableOfContentsBackgroundView];
            
            
            _bottomTableOfContentsView = [[RRItemsView alloc] initWithOrientation:RRItemsViewOrientationHorizontal];
            _bottomTableOfContentsView.backgroundColor = [UIColor clearColor];
            _bottomTableOfContentsView.dataSource = self;
            _bottomTableOfContentsView.delegate = self;
//            _bottomTableOfContentsView.frame = CGRectMake(0,
//                                                          frame.size.height,
//                                                          frame.size.width,
//                                                          frame.size.height / 3);
//            _bottomTableOfContentsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//            _bottomTableOfContentsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

            [self addSubview:_bottomTableOfContentsView];
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // bottom table of contents
    
    CGSize bottomItemSize = [self bottomItemSize];
    CGSize bottomButtonSize = _bottomTableOfContentsButton.bounds.size;
    CGSize viewSize = self.bounds.size;

    CGRect bottomTocButtonRect = CGRectZero;
    CGRect bottomTocRect = CGRectZero;
    
    if (_bottomTableOfContentsVisible) {
        
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
    
    _bottomTableOfContentsButton.frame = bottomTocButtonRect;
    _bottomTableOfContentsView.frame = bottomTocRect;
    _bottomTableOfContentsBackgroundView.frame = bottomTocRect;
}

- (void)topTableOfContentsButtonAction:(UIButton *)sender
{
    [self animateTopTableOfContents];
}

- (void)bottomTableOfContentsButtonAction:(UIButton *)sender
{
    [self animateBottomTableOfContents];
}

- (void)tintViewTapped:(UIGestureRecognizer *)recognizer
{
    if (_topTableOfContentsVisible) {
        [self animateTopTableOfContents];
    }
    
    if (_bottomTableOfContentsVisible) {
        [self animateBottomTableOfContents];
    }
}

- (void)animateTopTableOfContents
{
    CGPoint visibleTopBarViewCenter = CGPointMake(_topBarView.center.x,
                                                  _topBarView.center.y + TopBarHeight);
    CGPoint hiddenTopBarViewCenter = CGPointMake(_topBarView.center.x,
                                                 _topBarView.center.y - TopBarHeight);
    
    
    CGPoint visibleTopTableOfContentsViewCenter = CGPointMake(_topTableOfContentsView.center.x,
                                                              _topTableOfContentsView.center.y + (self.bounds.size.height / 2) + TopBarHeight);
    CGPoint hiddenTopTableOfContentsViewCenter = CGPointMake(_topTableOfContentsView.center.x,
                                                             _topTableOfContentsView.center.y - (self.bounds.size.height / 2) - TopBarHeight);
    
    CGPoint visibleTopTableOfContentsButtonCenter = CGPointMake(_topTableOfContentsButton.center.x,
                                                                _topTableOfContentsButton.center.y + (self.bounds.size.height / 2) + TopBarHeight);
    CGPoint hiddenTopTableOfContentsButtonCenter = CGPointMake(_topTableOfContentsButton.center.x,
                                                               _topTableOfContentsButton.center.y - (self.bounds.size.height / 2) - TopBarHeight);
    
    void (^animationBlock)() = nil;
    void (^animationCompletionBlock)(BOOL finish) = nil;
    
    if (_topTableOfContentsVisible) {
        
        _tintView.alpha = 0.3f;
        
        if ([self.delegate respondsToSelector:@selector(tableOfContentsViewWillHideTableOfContents:)]) {
            [self.delegate tableOfContentsViewWillHideTableOfContents:self];
        }
        
        animationBlock = ^() {
            _topBarView.center = hiddenTopBarViewCenter;
            _topTableOfContentsView.center = hiddenTopTableOfContentsViewCenter;
            _topTableOfContentsBackgroundView.center = hiddenTopTableOfContentsViewCenter;
            _topTableOfContentsButton.center = hiddenTopTableOfContentsButtonCenter;
            _tintView.alpha = 0;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _topTableOfContentsVisible = NO;
        };
        
        
    } else {
        
        _tintView.alpha = 0;
        
        if ([self.delegate respondsToSelector:@selector(tableOfContentsViewWillShowTableOfContents:)]) {
            [self.delegate tableOfContentsViewWillShowTableOfContents:self];
        }
        
        animationBlock = ^() {
            _topBarView.center = visibleTopBarViewCenter;
            _topTableOfContentsView.center = visibleTopTableOfContentsViewCenter;
            _topTableOfContentsBackgroundView.center = visibleTopTableOfContentsViewCenter;
            _topTableOfContentsButton.center = visibleTopTableOfContentsButtonCenter;
            _tintView.alpha = 0.3f;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _topTableOfContentsVisible = YES;
        };
    }
    
    [UIView animateWithDuration:0.3f 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:animationBlock 
                     completion:animationCompletionBlock];
}

- (void)animateBottomTableOfContents
{
    CGPoint visibleTopBarViewCenter = CGPointMake(_topBarView.center.x,
                                                  _topBarView.center.y + TopBarHeight);
    CGPoint hiddenTopBarViewCenter = CGPointMake(_topBarView.center.x,
                                                 _topBarView.center.y - TopBarHeight);
    
    
    CGPoint visibleBottomTableOfContentsViewCenter = CGPointMake(_bottomTableOfContentsView.center.x,
                                                                 _bottomTableOfContentsView.center.y - (_bottomTableOfContentsView.bounds.size.height));
    CGPoint hiddenBottomTableOfContentsViewCenter = CGPointMake(_bottomTableOfContentsView.center.x,
                                                                _bottomTableOfContentsView.center.y + (_bottomTableOfContentsView.bounds.size.height));
    
    CGPoint visibleBottomTableOfContentsButtonCenter = CGPointMake(_bottomTableOfContentsButton.center.x,
                                                                   _bottomTableOfContentsButton.center.y - (_bottomTableOfContentsView.bounds.size.height));
    CGPoint hiddenBottomTableOfContentsButtonCenter = CGPointMake(_bottomTableOfContentsButton.center.x,
                                                                  _bottomTableOfContentsButton.center.y + (_bottomTableOfContentsView.bounds.size.height));
    
    void (^animationBlock)() = nil;
    void (^animationCompletionBlock)(BOOL finish) = nil;
    
    if (_bottomTableOfContentsVisible) {
        
        _tintView.alpha = 0.3f;
        
        if ([self.delegate respondsToSelector:@selector(tableOfContentsViewWillHideTableOfContents:)]) {
            [self.delegate tableOfContentsViewWillHideTableOfContents:self];
        }
        
        animationBlock = ^() {
            _topBarView.center = hiddenTopBarViewCenter;
            _bottomTableOfContentsView.center = hiddenBottomTableOfContentsViewCenter;
            _bottomTableOfContentsBackgroundView.center = hiddenBottomTableOfContentsViewCenter;
            _bottomTableOfContentsButton.center = hiddenBottomTableOfContentsButtonCenter;
            _tintView.alpha = 0;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _bottomTableOfContentsVisible = NO;
        };
        
        
    } else {
        
        _tintView.alpha = 0;
        
        if ([self.delegate respondsToSelector:@selector(tableOfContentsViewWillShowTableOfContents:)]) {
            [self.delegate tableOfContentsViewWillShowTableOfContents:self];
        }
        
        animationBlock = ^() {
            _topBarView.center = visibleTopBarViewCenter;
            _bottomTableOfContentsView.center = visibleBottomTableOfContentsViewCenter;
            _bottomTableOfContentsBackgroundView.center = visibleBottomTableOfContentsViewCenter;
            _bottomTableOfContentsButton.center = visibleBottomTableOfContentsButtonCenter;
            _tintView.alpha = 0.3f;
        };
        
        animationCompletionBlock = ^(BOOL finished) {
            _bottomTableOfContentsVisible = YES;
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
    if (_topTableOfContentsView != nil) {
        [_topTableOfContentsView reloadData];
    }
    
    if (_bottomTableOfContentsView != nil) {
        [_bottomTableOfContentsView reloadData];
    }
}

- (void)hideTableOfContents
{
    if (_topTableOfContentsVisible) {
        [self animateTopTableOfContents];
    }
    
    if (_bottomTableOfContentsVisible) {
        [self animateBottomTableOfContents];
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

- (void)setTableOfContentsButtonsVisible:(BOOL)visible
{
    [UIView animateWithDuration:0.3f animations:^{
        _topTableOfContentsButton.hidden = !visible; 
    }];
}

- (void)stylizeElementsWithOptions:(NSDictionary *)options
{
    [[PCStyler defaultStyler] stylizeElement:_topTableOfContentsButton withStyleName:PCTopTocButtonKey withOptions:options];
    
    [_topTableOfContentsButton setFrame:CGRectMake(self.frame.size.width - _topTableOfContentsButton.frame.size.width - 20, 
                                                   0,
                                                   _topTableOfContentsButton.frame.size.width,
                                                   _topTableOfContentsButton.frame.size.height)];
    
    
    [[PCStyler defaultStyler] stylizeElement:_bottomTableOfContentsButton withStyleName:PCTocButtonKey withOptions:options];
    
    [_bottomTableOfContentsButton setFrame:CGRectMake(0, 
                                                      MAX(self.frame.size.height, self.frame.size.width) - _bottomTableOfContentsButton.frame.size.height,
                                                      _bottomTableOfContentsButton.frame.size.width,
                                                      _bottomTableOfContentsButton.frame.size.height)];
}

#pragma mark - RRItemsViewDelegate

- (void)itemsView:(RRItemsView *)itemsView itemSelectedAtIndex:(RRItemsViewIndex *)index
{
    if ([self.delegate respondsToSelector:@selector(tableOfContentsView:indexDidSelected:)]) {
        [self.delegate tableOfContentsView:self indexDidSelected:index.row];
    }
}

#pragma mark - RRItemsViewDataSource

- (RRItemsViewItem *)itemsView:(RRItemsView *)itemsView itemViewForIndex:(RRItemsViewIndex *)index
{
    RRTableOfContentsItem *item = (RRTableOfContentsItem *)[itemsView dequeueReusableItemView];
    
    if (item == nil) {
        item = [[[RRTableOfContentsItem alloc] init] autorelease];
    }
    
    [item setImage:[self imageForIndex:index.row]];
    
    return item;
}

- (NSUInteger)itemsViewItemsCount:(RRItemsView *)itemsView
{
    return [self itemsCount];
}

- (CGSize)itemsViewItemSize:(RRItemsView *)itemsView
{
    if (itemsView == _topTableOfContentsView) {
        return [self topItemSize];
    } else if (itemsView == _bottomTableOfContentsView) {
        return [self bottomItemSize];
    }
    
    return CGSizeZero;
}

#pragma mark - delegate
#pragma mark TODO: delegate methods

#pragma mark - data source

- (CGSize)topItemSize
{
    if ([self.dataSource respondsToSelector:@selector(tableOfContentsViewTopItemSize:)]) {
        return [self.dataSource tableOfContentsViewTopItemSize:self];
    }
    
    return CGSizeZero;
}

- (CGSize)bottomItemSize
{
    if ([self.dataSource respondsToSelector:@selector(tableOfContentsViewBottomItemSize:)]) {
        
        CGSize size = [self.dataSource tableOfContentsViewBottomItemSize:self];
        
//        _bottomTableOfContentsView.frame = CGRectMake(_bottomTableOfContentsView.bounds.origin.x,
//                                                      0,
//                                                      _bottomTableOfContentsView.bounds.size.width,
//                                                      size.height);
        
//        _bottomTableOfContentsBackgroundView.frame = _bottomTableOfContentsView.frame;
        
//        _bottomTableOfContentsButton.frame = CGRectMake(_bottomTableOfContentsButton.frame.origin.x, 
//                                                        self.bounds.size.height - _bottomTableOfContentsButton.frame.size.height, 
//                                                        _bottomTableOfContentsButton.frame.size.width, 
//                                                        _bottomTableOfContentsButton.frame.size.height);
        return size;
    }
    
    return CGSizeZero;
}

- (UIImage *)imageForIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(tableOfContentsView:imageForIndex:)]) {
        return [self.dataSource tableOfContentsView:self imageForIndex:index];
    }
    
    return nil;
}

- (NSUInteger)itemsCount
{
    if ([self.dataSource respondsToSelector:@selector(tableOfContentsViewItemsCount:)]) {
        return [self.dataSource tableOfContentsViewItemsCount:self];
    }
    
    return 0;
}

@end
