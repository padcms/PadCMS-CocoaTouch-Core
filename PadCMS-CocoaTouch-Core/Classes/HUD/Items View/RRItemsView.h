//  Created by Maxim Pervushin on 7/13/12.

#import <UIKit/UIKit.h>

@class RRItemsView;
@class RRItemsViewIndex;
@class RRItemsViewItem;

typedef enum _RRItemsViewOrientation {
    RRItemsViewOrientationHorizontal = 0,
    RRItemsViewOrientationVertical = 1
} RRItemsViewOrientation;


@protocol RRItemsViewDataSource <NSObject>

- (NSUInteger)itemsViewItemsCount:(RRItemsView *)itemsView;
- (CGSize)itemsViewItemSize:(RRItemsView *)itemsView;
- (RRItemsViewItem *)itemsView:(RRItemsView *)itemsView itemViewForIndex:(RRItemsViewIndex *)index;

@end


@protocol RRItemsViewDelegate <UIScrollViewDelegate>
@optional
- (void)itemsView:(RRItemsView *)itemsView itemSelectedAtIndex:(RRItemsViewIndex *)index;

@end


@interface RRItemsView : UIScrollView

@property (assign, nonatomic) id<RRItemsViewDataSource> dataSource;
@property (assign, nonatomic) id<RRItemsViewDelegate> delegate;

- (id)initWithOrientation:(RRItemsViewOrientation)orientation;
- (void)reloadData;
- (RRItemsViewItem *)dequeueReusableItemView;

@end
