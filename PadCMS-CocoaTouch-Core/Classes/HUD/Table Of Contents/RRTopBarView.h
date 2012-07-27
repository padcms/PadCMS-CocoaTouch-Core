//
//  TopBarView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/27/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRTopBarView;

@protocol RRTopBarViewDelegate <NSObject>

- (void)topBarView:(RRTopBarView *)topBarView backButtonTapped:(UIButton *)button;
- (void)topBarView:(RRTopBarView *)topBarView summaryButtonTapped:(UIButton *)button;
- (void)topBarView:(RRTopBarView *)topBarView subscriptionsButtonTapped:(UIButton *)button;
- (void)topBarView:(RRTopBarView *)topBarView shareButtonTapped:(UIButton *)button;
- (void)topBarView:(RRTopBarView *)topBarView helpButtonTapped:(UIButton *)button;
- (void)topBarView:(RRTopBarView *)topBarView searchText:(NSString *)searchText;

@end

@interface RRTopBarView : UIView <UITextFieldDelegate>

@property (assign) id<RRTopBarViewDelegate> delegate;

- (void)setSummaryButtonHidden:(BOOL)hidden animated:(BOOL)animated;

@end
