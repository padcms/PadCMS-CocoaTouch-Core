//  Created by Maxim Pervushin on 7/13/12.

#import <UIKit/UIKit.h>

@class PCGridView;
@class PCGridViewIndex;
@class PCGridViewCell;

typedef enum _PCGridViewOrientation {
    PCGridViewOrientationHorizontal = 0,
    PCGridViewOrientationVertical = 1
} PCGridViewOrientation;


@protocol PCGridViewDelegate <UIScrollViewDelegate>
@optional
- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index;

@end


@protocol PCGridViewDataSource <NSObject>

- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView;
- (CGSize)gridViewCellSize:(PCGridView *)gridView;
- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index;

@end


@interface PCGridView : UIScrollView

@property (assign, nonatomic) id<PCGridViewDelegate> delegate;
@property (assign, nonatomic) id<PCGridViewDataSource> dataSource;

- (id)initWithOrientation:(PCGridViewOrientation)orientation;
- (void)reloadData;
- (PCGridViewCell *)dequeueReusableItemView;

@end
