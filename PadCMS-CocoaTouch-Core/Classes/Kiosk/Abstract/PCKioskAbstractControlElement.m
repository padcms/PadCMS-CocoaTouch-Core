//
//  PCKioskControlElement.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskAbstractControlElement.h"

@implementation PCKioskAbstractControlElement

@synthesize revisionIndex = _revisionIndex;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize downloadInProgress = _downloadInProgress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.downloadInProgress = FALSE;
    }
    return self;
}

- (void) load
{
}

- (void) downloadStarted;
{
    self.downloadInProgress = TRUE;
}

- (void) downloadProgressUpdatedWithProgress:(float)progress andRemainingTime:(NSString *)time
{
}

- (void) downloadFinished;
{
    self.downloadInProgress = FALSE;
}

- (void) downloadFailed;
{
    self.downloadInProgress = FALSE;
}

- (void) downloadCanceled
{
    self.downloadInProgress = FALSE;
}

- (void) update
{
}

@end
