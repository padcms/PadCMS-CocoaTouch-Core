//
//  PCKioskSubview.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskSubview.h"

@implementation PCKioskSubview

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize downloadInProgress = _downloadInProgress;
@synthesize downloadingRevisionIndex = _downloadingRevisionIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.downloadInProgress = FALSE;
    }
    return self;
}

+ (NSInteger) subviewTag
{
    return 0;
}

- (void) createView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizesSubviews = YES;
    self.clipsToBounds = YES;
}

- (void) selectRevisionWithIndex:(NSInteger)index
{
}

- (void) updateRevisionWithIndex:(NSInteger)index
{
}

- (void) reloadRevisions
{
}

- (void) downloadStartedWithRevisionIndex:(NSInteger)index
{
    self.downloadInProgress = TRUE;
    self.downloadingRevisionIndex = index;
}

- (void) downloadProgressUpdatedWithRevisionIndex:(NSInteger)index andProgress:(float)progress andRemainingTime:(NSString *)time
{
}

- (void) downloadFinishedWithRevisionIndex:(NSInteger)index
{
    self.downloadInProgress = FALSE;
}

- (void) downloadFailedWithRevisionIndex:(NSInteger)index
{
    self.downloadInProgress = FALSE;
}

- (void) downloadCanceledWithRevisionIndex:(NSInteger)index
{
    self.downloadInProgress = FALSE;
}

- (void) deviceOrientationDidChange
{
}

@end
