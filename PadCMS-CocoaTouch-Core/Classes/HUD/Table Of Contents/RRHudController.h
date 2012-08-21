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

@interface RRHudController : NSObject <PCHudViewDataSource, PCHudViewDelegate, PCTopBarViewDelegate>

@property (retain, nonatomic) PCRevision *revision;
@property (assign) BOOL previewMode;
@property (readonly, nonatomic) PCHudView *hudView;

- (void)update;
- (void)handleTap;
- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
