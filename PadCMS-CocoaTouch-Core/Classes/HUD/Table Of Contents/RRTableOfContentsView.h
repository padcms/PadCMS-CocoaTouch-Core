//
//  RRTableOfContentsView.h
//  ReusingScrollViewDemo
//
//  Created by Maxim Pervushin on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RRItemsView.h"

@class RRTableOfContentsView;


@protocol RRTableOfContentsViewDelegate <NSObject>

@optional
- (void)tableOfContentsView:(RRTableOfContentsView *)tableOfContentsView 
           indexDidSelected:(NSUInteger)index;
@optional
- (void)tableOfContentsViewWillShowTableOfContents:(RRTableOfContentsView *)tableOfContentsView;
@optional
- (void)tableOfContentsViewWillHideTableOfContents:(RRTableOfContentsView *)tableOfContentsView;

@end


@protocol RRTableOfContentsViewDataSource <NSObject>

- (CGSize)tableOfContentsViewTopItemSize:(RRTableOfContentsView *)tableOfContentsView;
- (CGSize)tableOfContentsViewBottomItemSize:(RRTableOfContentsView *)tableOfContentsView;

- (UIImage *)tableOfContentsView:(RRTableOfContentsView *)tableOfContentsView 
                   imageForIndex:(NSUInteger)index;
- (NSUInteger)tableOfContentsViewItemsCount:(RRTableOfContentsView *)tableOfContentsView;

@end 


@interface RRTableOfContentsView : UIView<RRItemsViewDelegate, RRItemsViewDataSource>

@property (assign, nonatomic) id<RRTableOfContentsViewDataSource> dataSource;
@property (assign, nonatomic) id<RRTableOfContentsViewDelegate> delegate;

- (void)reloadData;
- (void)hideTableOfContents;
- (void)setTableOfContentsButtonsVisible:(BOOL)visible;
- (void)stylizeElementsWithOptions:(NSDictionary *)options;

@end
