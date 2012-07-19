//
//  RRTableOfContentsView.h
//  ReusingScrollViewDemo
//
//  Created by Maxim Pervushin on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCGridView.h"

@class PCHUDView;


@protocol PCHUDViewDelegate <NSObject>
@optional
- (void)hudView:(PCHUDView *)hudView didSelectIndex:(NSUInteger)index;
@optional
- (void)hudView:(PCHUDView *)hudView willShowTOC:(PCGridView *)tocView;
@optional
- (void)hudView:(PCHUDView *)hudView willHideTOC:(PCGridView *)tocView;

@end


@protocol PCHUDViewDataSource <NSObject>

- (CGSize)hudView:(PCHUDView *)hudView itemSizeInTOC:(PCGridView *)tocView;
- (UIImage *)hudView:(PCHUDView *)hudView tocImageForIndex:(NSUInteger)index;
- (NSUInteger)hudViewTOCItemsCount:(PCHUDView *)hudView;

@end 


@interface PCHUDView : UIView <PCGridViewDelegate, PCGridViewDataSource>

@property (assign, nonatomic) id<PCHUDViewDelegate> delegate;
@property (assign, nonatomic) id<PCHUDViewDataSource> dataSource;

@property (readonly) UIButton *topTOCButton;
@property (readonly) PCGridView *topTOCView;
@property (readonly) UIButton *bottomTOCButton;
@property (readonly) PCGridView *bottomTOCView;

- (void)reloadData;
- (void)hideTOCs;
- (void)stylizeElementsWithOptions:(NSDictionary *)options;

@end
