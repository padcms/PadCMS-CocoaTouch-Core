//
//  RRShareView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/14/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCShareView;


@protocol PCShareViewDelegate <NSObject>
@optional
- (void)shareViewFacebookShare:(PCShareView *)shareView;
@optional
- (void)shareViewTwitterShare:(PCShareView *)shareView;
@optional
- (void)shareViewMailShare:(PCShareView *)shareView;

@end


@interface PCShareView : UIView

@property (assign, nonatomic) id<PCShareViewDelegate> delegate;
@property (readonly, nonatomic) BOOL presented;

+ (PCShareView *)configuredShareView;

- (void)presentInView:(UIView *)view atPoint:(CGPoint)point;
- (void)dismiss;

@end
