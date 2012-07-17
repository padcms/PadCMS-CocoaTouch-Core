//
//  RRTableOfContentsView.m
//  Created by Maxim Pervushin on 7/13/12.

#import "RRItemsView.h"

#import "RRItemsViewIndex.h"
#import "RRItemsViewItem.h"


@interface RRItemsView ()
{
    NSUInteger _itemsCount;
    CGSize _itemSize;
    RRItemsViewOrientation _orientation;
    NSMutableArray *_reusableViews;
}

- (void)updateSubviews;
- (NSUInteger)dataSourceItemsCount;
- (CGSize)dataSourceItemSize;
- (RRItemsViewItem *)dataSourceItemViewForIndex:(RRItemsViewIndex *)index;
- (RRItemsViewItem *)getSubviewForIndex:(NSUInteger)index;
- (void)enqueueReusableItemView:(RRItemsViewItem *)itemView;
- (void)tapGesture:(UITapGestureRecognizer *)recognizer;
- (RRItemsViewIndex *)indexForPoint:(CGPoint)point;

@end

@implementation RRItemsView
@synthesize dataSource;
@synthesize delegate;

- (void)dealloc
{
    [_reusableViews release];
    [super dealloc];
}

- (id)initWithOrientation:(RRItemsViewOrientation)orientation
{
    self = [self initWithFrame:CGRectZero];
    
    if (self != nil) {
        _itemsCount = 0;
        _itemSize = CGSizeZero;
        _orientation = orientation;
        _reusableViews = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] 
                                                        initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    [self updateSubviews];
}

- (void)reloadData
{
    NSArray *items = self.subviews;
    for (RRItemsViewItem *item in items) {
        [self enqueueReusableItemView:item];
    }

    _itemsCount = [self dataSourceItemsCount];
    _itemSize = [self dataSourceItemSize];
    
    CGSize contentSize = CGSizeZero;
    
    if (_orientation == RRItemsViewOrientationHorizontal) {
        contentSize = CGSizeMake(_itemsCount * _itemSize.width, _itemSize.height);
    } else {
        contentSize = CGSizeMake(_itemSize.width, _itemsCount * _itemSize.height);
    }
    
    self.contentSize = contentSize;
    
    [self updateSubviews];
}

- (void)updateSubviews
{
    CGRect visibleRect = CGRectMake(self.contentOffset.x, 
                                    self.contentOffset.y, 
                                    self.bounds.size.width, 
                                    self.bounds.size.height); 
    
    for (NSUInteger index = 0; index < _itemsCount; ++index) {
        
        CGFloat x = _orientation == RRItemsViewOrientationHorizontal ? index * _itemSize.width : 0;
        CGFloat y = _orientation == RRItemsViewOrientationVertical ? index * _itemSize.height : 0;
        CGRect currentItemViewFrame = CGRectMake(x, y, _itemSize.width, _itemSize.height);
        
        if (CGRectIntersectsRect(visibleRect, currentItemViewFrame)) {
            
            RRItemsViewItem *view = [self getSubviewForIndex:index];
            
            if (view == nil) {
                RRItemsViewIndex *itemIndex =[[[RRItemsViewIndex alloc] init] autorelease];
                itemIndex.row = index;
                view = [self dataSourceItemViewForIndex:itemIndex]; 

                if (view != nil) {
                    view.index = itemIndex;
                    view.frame = currentItemViewFrame;
                    
                    if (![self.subviews containsObject:view]) {
                        [self addSubview:view];
                    }
                }
            }
            
        } else {
            
            RRItemsViewItem *view = [self getSubviewForIndex:index];
            if (view != nil) {
                [self enqueueReusableItemView:view];
            }
            
        }
    }
}

- (RRItemsViewItem *)getSubviewForIndex:(NSUInteger)index
{
    CGFloat x = _orientation == RRItemsViewOrientationHorizontal ? index * _itemSize.width : 0;
    CGFloat y = _orientation == RRItemsViewOrientationVertical ? index * _itemSize.height : 0;
    CGRect itemViewFrame = CGRectMake(x, y, _itemSize.width, _itemSize.height);
    
    NSArray *subviews = self.subviews;
    for (RRItemsViewItem *subview in subviews) {
        
        if ([_reusableViews containsObject:subviews]) {
            continue;
        }
        
        if (CGRectEqualToRect(subview.frame, itemViewFrame)) {
            return subview;
        }
    }
    
    return nil;
}

- (void)enqueueReusableItemView:(RRItemsViewItem *)itemView
{
    itemView.index = nil;
    itemView.hidden = YES;
//    [itemView clearContent];
    [_reusableViews addObject:itemView];
}

- (RRItemsViewItem *)dequeueReusableItemView
{
    if (_reusableViews.count == 0) {
        return nil;
    }
    
    RRItemsViewItem *reusableView = [_reusableViews objectAtIndex:0];
    reusableView.hidden = NO;
    [_reusableViews removeObject:reusableView];
    
    return reusableView;
}

- (NSUInteger)dataSourceItemsCount
{
    if ([self.dataSource respondsToSelector:@selector(itemsViewItemsCount:)]) {
        return [self.dataSource itemsViewItemsCount:self];
    }
    
    return 0;
}

- (CGSize)dataSourceItemSize
{
    if ([self.dataSource respondsToSelector:@selector(itemsViewItemSize:)]) {
        return [self.dataSource itemsViewItemSize:self];
    }
    
    return CGSizeZero;
}

- (RRItemsViewItem *)dataSourceItemViewForIndex:(RRItemsViewIndex *)index
{
    if ([self.dataSource respondsToSelector:@selector(itemsView:itemViewForIndex:)]) {
        return [self.dataSource itemsView:self itemViewForIndex:index];
    }
    
    return nil;
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, location)) {
            UIColor *originalColor = subview.backgroundColor;
            
            [UIView animateWithDuration:0.3f 
                             animations:^{
                                 subview.backgroundColor = [UIColor blueColor];
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.3f 
                                                  animations:^{
                                                      subview.backgroundColor = originalColor;
                                                  }];
                             }];
            
            RRItemsViewIndex *index = [self indexForPoint:location];
            
            if (index != nil &&
                [self.delegate respondsToSelector:@selector(itemsView:itemSelectedAtIndex:)]) {
                [self.delegate itemsView:self itemSelectedAtIndex:index];
            }
            
            break;
        }
    }
}

- (RRItemsViewIndex *)indexForPoint:(CGPoint)point
{
    NSArray *subviews = self.subviews;
    for (RRItemsViewItem *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            if (subview.index != nil) {
                return subview.index;
            }
            
            return nil;
        }
    }
    
    return nil;
}

@end
