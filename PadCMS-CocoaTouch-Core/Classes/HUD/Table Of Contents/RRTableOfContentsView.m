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

@interface RRTableOfContentsView ()
{
    UIView *_topBarView;

    BOOL _topTableOfContentsVisible;
    UIButton *_topTableOfContentsButton;
    RRItemsView *_topTableOfContentsView;
    UIView *_topTableOfContentsBackgroundView;
    
    UIView *_tintView;
}

- (void)topTableOfContentsButtonAction:(UIButton *)sender;
- (void)tintViewTapped:(UIGestureRecognizer *)recognizer;
- (void)animateTopTableOfContents;

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

        _topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -43, self.bounds.size.width, 43)];
        _topBarView.backgroundColor = [UIColor blackColor];
        _topBarView.alpha = 0;
        _topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_topBarView];
        
        // top table of contents
        _topTableOfContentsButton = [[UIButton alloc] init];
//        _topTableOfContentsButton.hidden = YES;
        _topTableOfContentsButton.frame = CGRectMake(frame.size.width - 100, 0, 50, 50);
        _topTableOfContentsButton.backgroundColor = [UIColor redColor];
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
//        _topTableOfContentsView.alpha = 0.5f;
        _topTableOfContentsView.dataSource = self;
        _topTableOfContentsView.delegate = self;
        _topTableOfContentsView.frame = CGRectMake(0,
                                                   -(frame.size.height / 2),
                                                   frame.size.width,
                                                   frame.size.height / 2);
        _topTableOfContentsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_topTableOfContentsView];
        
    }
    
    return self;
}

- (void)topTableOfContentsButtonAction:(UIButton *)sender
{
    [self animateTopTableOfContents];
}

- (void)tintViewTapped:(UIGestureRecognizer *)recognizer
{
    if (_topTableOfContentsVisible) {
        [self animateTopTableOfContents];
        return;
    }
}

- (void)animateTopTableOfContents
{
    CGPoint visibleTopBarViewCenter = CGPointMake(_topBarView.center.x,
                                                  _topBarView.center.y + 43);
    CGPoint hiddenTopBarViewCenter = CGPointMake(_topBarView.center.x,
                                                 _topBarView.center.y - 43);

    
    CGPoint visibleTopTableOfContentsViewCenter = CGPointMake(_topTableOfContentsView.center.x,
                                                              _topTableOfContentsView.center.y + (self.bounds.size.height / 2) + 43);
    CGPoint hiddenTopTableOfContentsViewCenter = CGPointMake(_topTableOfContentsView.center.x,
                                                             _topTableOfContentsView.center.y - (self.bounds.size.height / 2) - 43);
    
    CGPoint visibleTopTableOfContentsButtonCenter = CGPointMake(_topTableOfContentsButton.center.x,
                                                                _topTableOfContentsButton.center.y + (self.bounds.size.height / 2) + 43);
    CGPoint hiddenTopTableOfContentsButtonCenter = CGPointMake(_topTableOfContentsButton.center.x,
                                                               _topTableOfContentsButton.center.y - (self.bounds.size.height / 2) - 43);
    
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

- (void)reloadData
{
    [_topTableOfContentsView reloadData];
}

- (void)hideTableOfContents
{
    if (_topTableOfContentsVisible) {
        [self animateTopTableOfContents];
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

    if ([self.dataSource respondsToSelector:@selector(tableOfContentsView:imageForIndex:)]) {
        [item setImage:[self.dataSource tableOfContentsView:self imageForIndex:index.row]];
    }
    
    return item;
}

- (NSUInteger)itemsViewItemsCount:(RRItemsView *)itemsView
{
    if ([self.dataSource respondsToSelector:@selector(tableOfContentsViewItemsCount:)]) {
        return [self.dataSource tableOfContentsViewItemsCount:self];
    }
    
    return 0;
}

- (CGSize)itemsViewItemSize:(RRItemsView *)itemsView
{
    return CGSizeMake(150, self.bounds.size.height / 2);
}

- (void)setTableOfContentsButtonsVisible:(BOOL)visible
{
    [UIView animateWithDuration:0.3f animations:^{
        _topTableOfContentsButton.hidden = !visible; 
    }];
}

@end
