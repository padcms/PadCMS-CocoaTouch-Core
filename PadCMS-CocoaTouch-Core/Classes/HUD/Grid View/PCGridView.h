
#import <UIKit/UIKit.h>

@class PCGridView;
@class PCGridViewCell;
@class PCGridViewIndex;

@protocol MFGridViewDelegate <UIScrollViewDelegate>
@optional
- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index;

@end


@protocol MFGridViewDataSource <NSObject>

- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView;
- (NSUInteger)gridViewNumberOfColumns:(PCGridView *)gridView;
- (CGSize)gridViewCellSize:(PCGridView *)gridView;
- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index;

@end


@interface PCGridView : UIScrollView

@property (assign, nonatomic) id<MFGridViewDelegate> delegate;
@property (assign, nonatomic) id<MFGridViewDataSource> dataSource;

- (void)reloadData;
- (PCGridViewCell *)dequeueReusableCell;

@end
