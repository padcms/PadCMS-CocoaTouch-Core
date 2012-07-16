//
//  RRTableOfContentsView.m
//  Created by Maxim Pervushin on 7/13/12.

#import "RRItemsView.h"

#import "RRItemsViewIndex.h"
#import "RRItemsViewItem.h"


@interface RRItemsView ()
{
    RRItemsViewOrientation _orientation;
    NSMutableArray *_reusableViews;
}

- (void)updateSubviews;
- (NSUInteger)itemsCount;
- (CGSize)itemSize;
- (RRItemsViewItem *)getSubviewForIndex:(NSUInteger)index;
- (void)enqueueReusableItemView:(RRItemsViewItem *)itemView;
- (void)tapGesture:(UITapGestureRecognizer *)recognizer;
- (RRItemsViewIndex *)indexForPoint:(CGPoint)point;

@end

@implementation RRItemsView
@synthesize dataSource = _dataSource;
@synthesize delegate/* = _delegate*/;

- (void)dealloc
{
    [_reusableViews release];
    [super dealloc];
}

- (id)initWithOrientation:(RRItemsViewOrientation)orientation
{
    self = [self initWithFrame:CGRectZero];
    
    if (self != nil) {
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
        self.backgroundColor = [UIColor greenColor];
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
    NSUInteger itemsCount = [self itemsCount];
    CGSize itemSize = [self itemSize];
    
    CGSize contentSize = CGSizeZero;
    
    if (_orientation == RRItemsViewOrientationHorizontal) {
        contentSize = CGSizeMake(itemsCount * itemSize.width, itemSize.height);
    } else {
        contentSize = CGSizeMake(itemSize.width, itemsCount * itemSize.height);
    }
    
    self.contentSize = contentSize;
}

- (void)updateSubviews
{
    // TODO: cache itemsCount and itemSize. Update only on reloadData;
    NSUInteger itemsCount = [self itemsCount];
    CGSize itemSize = [self itemSize];
    
    CGRect visibleRect = CGRectMake(self.contentOffset.x, 
                                    self.contentOffset.y, 
                                    self.bounds.size.width, 
                                    self.bounds.size.height); 
    
    for (NSUInteger index = 0; index < itemsCount; ++index) {
        CGFloat x = _orientation == RRItemsViewOrientationHorizontal ? index * itemSize.width : 0;
        CGFloat y = _orientation == RRItemsViewOrientationVertical ? index * itemSize.height : 0;
        CGRect currentItemViewFrame = CGRectMake(x, y, itemSize.width, itemSize.height);
        
        if (CGRectIntersectsRect(visibleRect, currentItemViewFrame)) {
            RRItemsViewItem *view = [self getSubviewForIndex:index];
            
            if (view == nil && [_dataSource respondsToSelector:@selector(itemsView:itemViewForIndex:)]) {
                RRItemsViewIndex *itemIndex =[[RRItemsViewIndex alloc] init];
                itemIndex.row = index;
                view = [_dataSource itemsView:self itemViewForIndex:itemIndex];
                view.index = itemIndex;
                [itemIndex release];
                if (view != nil) {
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
    // TODO: cache itemsCount and itemSize. Update only on reloadData;
    CGSize itemSize = [self itemSize];
    
    CGFloat x = _orientation == RRItemsViewOrientationHorizontal ? index * itemSize.width : 0;
    CGFloat y = _orientation == RRItemsViewOrientationVertical ? index * itemSize.height : 0;
    CGRect itemViewFrame = CGRectMake(x, y, itemSize.width, itemSize.height);
    
    NSArray *subviews = self.subviews;
    for (RRItemsViewItem *subview in subviews) {
        if (CGRectEqualToRect(subview.frame, itemViewFrame)) {
            return subview;
        }
    }
    
    return nil;
}

- (void)enqueueReusableItemView:(RRItemsViewItem *)itemView
{
    itemView.index = nil;
    [itemView clearContent];
    [_reusableViews addObject:itemView];
}

- (RRItemsViewItem *)dequeueReusableItemView
{
    if (_reusableViews.count == 0) {
        return nil;
    }
    
    RRItemsViewItem *reusableView = [_reusableViews objectAtIndex:0];
    [_reusableViews removeObject:reusableView];
    
    return reusableView;
}

- (NSUInteger)itemsCount
{
    if ([_dataSource respondsToSelector:@selector(itemsViewItemsCount:)]) {
        return [_dataSource itemsViewItemsCount:self];
    }
    
    return 0;
}

- (CGSize)itemSize
{
    if ([_dataSource respondsToSelector:@selector(itemsViewItemSize:)]) {
        return [_dataSource itemsViewItemSize:self];
    }
    
    return CGSizeZero;
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
