//
//  RRHudController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/21/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PCHudView.h"
#import "PCTopBarView.h"

@class PCRevision;
@class PCTocItem;
@class PCTopBarView;
@class RRHudController;

@protocol RRHudControllerDelegate <NSObject>

- (void)hudControllerDismissAllPopups:(RRHudController *)hudController;
- (void)hudController:(RRHudController *)hudController selectedTocItem:(PCTocItem *)tocItem;
- (void)hudController:(RRHudController *)hudController
           topBarView:(PCTopBarView *)topBarView
         buttonTapped:(UIButton *)button;

@end


@interface RRHudController : NSObject <PCHudViewDataSource, PCHudViewDelegate, PCTopBarViewDelegate>

@property (assign) id<RRHudControllerDelegate> delegate;
@property (retain, nonatomic) PCRevision *revision;
@property (assign) BOOL previewMode;
@property (readonly, nonatomic) PCHudView *hudView;

- (void)update;
- (void)tap;

@end
