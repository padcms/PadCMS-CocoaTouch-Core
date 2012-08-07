
#import <UIKit/UIKit.h>

@class PCGridView;
@class PCGridViewCell;
@class PCGridViewIndex;

@protocol PCGridViewDelegate <UIScrollViewDelegate>
@optional
- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index;

@end


@protocol PCGridViewDataSource <NSObject>

- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView;
- (NSUInteger)gridViewNumberOfColumns:(PCGridView *)gridView;
- (CGSize)gridViewCellSize:(PCGridView *)gridView;
- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index;

@end


@interface PCGridView : UIScrollView

@property (assign, nonatomic) id<PCGridViewDelegate> delegate;
@property (assign, nonatomic) id<PCGridViewDataSource> dataSource;

- (void)reloadData;
- (PCGridViewCell *)dequeueReusableCell;

@end
