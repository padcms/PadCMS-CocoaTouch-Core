//
//  PCStorControllerDelegate.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 6/21/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCStoreControllerDelegate

@required

- (void)displayIssues;

- (void) updateRevisionWithIndex:(NSInteger)index;

- (void) downloadStartedWithRevisionIndex:(NSInteger)index;

- (void) downloadFinishedWithRevisionIndex:(NSInteger)index;

- (void) downloadFailedWithRevisionIndex:(NSInteger)index;
 
- (void) downloadCanceledWithRevisionIndex:(NSInteger)index;

- (void) downloadingProgressChangedWithRevisionIndex:(NSInteger)index andProgess:(float) progress;

- (void) deviceOrientationDidChange;

- (void) reloadSubviews;


@optional

-(void)showActivityIndicator;
-(void)hideActivityIndicator;

@end
