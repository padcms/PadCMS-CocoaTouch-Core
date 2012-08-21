//
//  RRView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/20/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _RRViewState {
    RRViewStateInvalid = -1,
    RRViewStateHidden = 0,
    RRViewStateVisible = 1,
    RRViewStateActive = 2
} RRViewState;


@class RRView;

@protocol RRViewDelegate <NSObject>

- (void)view:(RRView *)view transitToState:(RRViewState)state animated:(BOOL)animated;

@end


@interface RRView : UIView

@property (assign, nonatomic) id<RRViewDelegate> statesDelegate;
@property (readonly, nonatomic) RRViewState state;

- (void)transitToState:(RRViewState)state animated:(BOOL)animated;

@end
