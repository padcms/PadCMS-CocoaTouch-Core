//
//  TopBarView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/27/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCTopBarView;

@protocol PCTopBarViewDelegate <NSObject>

- (void)topBarView:(PCTopBarView *)topBarView backButtonTapped:(UIButton *)button;
- (void)topBarView:(PCTopBarView *)topBarView summaryButtonTapped:(UIButton *)button;
- (void)topBarView:(PCTopBarView *)topBarView subscriptionsButtonTapped:(UIButton *)button;
- (void)topBarView:(PCTopBarView *)topBarView shareButtonTapped:(UIButton *)button;
- (void)topBarView:(PCTopBarView *)topBarView helpButtonTapped:(UIButton *)button;
- (void)topBarView:(PCTopBarView *)topBarView searchText:(NSString *)searchText;

@end


@interface PCTopBarView : UIView <UITextFieldDelegate>

@property (assign) id<PCTopBarViewDelegate> delegate;

- (void)setSummaryButtonHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)hideKeyboard;

@end
