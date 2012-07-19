//
//  RRTableOfContentsView.m
//  Created by Maxim Pervushin on 7/13/12.

#import "PCGridView.h"

#import "PCGridViewIndex.h"
#import "PCGridViewCell.h"


@interface PCGridView ()
{
    NSUInteger _itemsCount;
    CGSize _itemSize;
    PCGridViewOrientation _orientation;
    NSMutableArray *_reusableViews;
}

- (void)updateSubviews;
- (PCGridViewCell *)getSubviewForIndex:(NSUInteger)index;
- (void)enqueueReusableItemView:(PCGridViewCell *)itemView;
- (void)tapGesture:(UITapGestureRecognizer *)recognizer;
- (PCGridViewIndex *)indexForPoint:(CGPoint)point;

// delegate
- (void)didSelectCellAtIndex:(PCGridViewIndex *)index;
// data source
- (NSUInteger)numberOfRows;
- (CGSize)cellSize;
- (PCGridViewCell *)cellForIndex:(PCGridViewIndex *)index;

@end

@implementation PCGridView
@synthesize delegate;
@synthesize dataSource;

- (void)dealloc
{
    [_reusableViews release];
    [super dealloc];
}

- (id)initWithOrientation:(PCGridViewOrientation)orientation
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
    for (PCGridViewCell *item in items) {
        [self enqueueReusableItemView:item];
    }
    
    _itemsCount = [self numberOfRows];
    _itemSize = [self cellSize];
    
    CGSize contentSize = CGSizeZero;
    
    if (_orientation == PCGridViewOrientationHorizontal) {
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
        
        CGFloat x = _orientation == PCGridViewOrientationHorizontal ? index * _itemSize.width : 0;
        CGFloat y = _orientation == PCGridViewOrientationVertical ? index * _itemSize.height : 0;
        CGRect currentItemViewFrame = CGRectMake(x, y, _itemSize.width, _itemSize.height);
        
        if (CGRectIntersectsRect(visibleRect, currentItemViewFrame)) {
            
            PCGridViewCell *itemView = [self getSubviewForIndex:index];
            
            if (itemView == nil) {
                PCGridViewIndex *itemIndex =[[[PCGridViewIndex alloc] init] autorelease];
                itemIndex.row = index;
                itemView = [self cellForIndex:itemIndex]; 
                itemView.index = itemIndex;
            }
            
            if (itemView != nil) {
                itemView.frame = currentItemViewFrame;
                itemView.hidden = NO;
                
                if (![self.subviews containsObject:itemView]) {
                    [self addSubview:itemView];
                }
            }
            
        } else {
            
            PCGridViewCell *itemView = [self getSubviewForIndex:index];
            if (itemView != nil) {
                [self enqueueReusableItemView:itemView];
            }
            
        }
    }
}

- (PCGridViewCell *)getSubviewForIndex:(NSUInteger)index
{
    CGFloat x = _orientation == PCGridViewOrientationHorizontal ? index * _itemSize.width : 0;
    CGFloat y = _orientation == PCGridViewOrientationVertical ? index * _itemSize.height : 0;
    CGRect itemViewFrame = CGRectMake(x, y, _itemSize.width, _itemSize.height);
    
    NSArray *subviews = self.subviews;
    for (PCGridViewCell *subview in subviews) {
        
        if ([_reusableViews containsObject:subviews]) {
            continue;
        }
        
        if (CGRectEqualToRect(subview.frame, itemViewFrame)) {
            return subview;
        }
    }
    
    return nil;
}

- (void)enqueueReusableItemView:(PCGridViewCell *)itemView
{
    itemView.index = nil;
    itemView.hidden = YES;
    [_reusableViews addObject:itemView];
}

- (PCGridViewCell *)dequeueReusableItemView
{
    if (_reusableViews.count == 0) {
        return nil;
    }
    
    PCGridViewCell *reusableView = [_reusableViews objectAtIndex:0];
    [_reusableViews removeObject:reusableView];
    
    return reusableView;
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
                                 subview.backgroundColor = [UIColor whiteColor];
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.3f 
                                                  animations:^{
                                                      subview.backgroundColor = originalColor;
                                                  }];
                             }];
            
            PCGridViewIndex *index = [self indexForPoint:location];
            
            if (index != nil) {
                [self didSelectCellAtIndex:index];
            }
            
            break;
        }
    }
}

- (PCGridViewIndex *)indexForPoint:(CGPoint)point
{
    NSArray *subviews = self.subviews;
    for (PCGridViewCell *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            if (subview.index != nil) {
                return subview.index;
            }
            
            return nil;
        }
    }
    
    return nil;
}

#pragma mark - delegate

- (void)didSelectCellAtIndex:(PCGridViewIndex *)index
{
    if ([self.delegate respondsToSelector:@selector(gridView:didSelectCellAtIndex:)]) {
        [self.delegate gridView:self didSelectCellAtIndex:index];
    }
}

#pragma mark - data source

- (NSUInteger)numberOfRows
{
    if ([self.dataSource respondsToSelector:@selector(gridViewNumberOfRows:)]) {
        return [self.dataSource gridViewNumberOfRows:self];
    }
    
    return 0;
}

- (CGSize)cellSize
{
    if ([self.dataSource respondsToSelector:@selector(gridViewCellSize:)]) {
        return [self.dataSource gridViewCellSize:self];
    }
    
    return CGSizeZero;
}

- (PCGridViewCell *)cellForIndex:(PCGridViewIndex *)index
{
    if ([self.dataSource respondsToSelector:@selector(gridView:cellForIndex:)]) {
        return [self.dataSource gridView:self cellForIndex:index];
    }
    
    return nil;
}

@end
