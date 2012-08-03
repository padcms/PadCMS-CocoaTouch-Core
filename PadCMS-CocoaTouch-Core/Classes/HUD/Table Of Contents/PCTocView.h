//
//  PCTocView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/30/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCTocView;
@class PCGridView;

typedef enum _PCTocViewState {
    PCTocViewStateInvalid = -1,
    PCTocViewStateHidden = 0,
    PCTocViewStateVisible = 1,
    PCTocViewStateActive = 2
} PCTocViewState;


@protocol PCTocViewDelegate <NSObject>

- (BOOL)tocView:(PCTocView *)tocView transitToState:(PCTocViewState)state animated:(BOOL)animated;

@end


@interface PCTocView : UIView

@property (assign) id<PCTocViewDelegate> delegate;
@property (readonly, nonatomic) PCTocViewState state;
@property (readonly, nonatomic) UIView *backgroundView;
@property (readonly, nonatomic) UIButton *button;
@property (readonly, nonatomic) PCGridView *gridView;

- (void)transitToState:(PCTocViewState)state animated:(BOOL)animated;
- (CGPoint)centerForState:(PCTocViewState)state containerBounds:(CGRect)containerBounds;

+ (PCTocView *)topTocViewWithFrame:(CGRect)frame;
+ (PCTocView *)bottomTocViewWithFrame:(CGRect)frame;

@end
