//
//  PCVideoManager.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Igor Getmanenko on 26.07.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCVideoManager.h"
#import "PCBrowserViewController.h"
#import "PCVideoController.h"

@interface PCVideoManager()
{
    PCBrowserViewController *_browserViewController;
    PCVideoController *_videoController;
    NSString *_videoPath;
    CGRect _videoFrame;
}
@property (nonatomic, retain) PCBrowserViewController *browserViewController;
@property (nonatomic, retain) PCVideoController *videoController;
@property (nonatomic, retain) NSString *videoPath;
@property (nonatomic, assign) CGRect videoFrame;

@end

@implementation PCVideoManager

@synthesize browserViewController = _browserViewController;
@synthesize videoController = _videoController;
@synthesize videoPath = _videoPath;
@synthesize videoFrame = _videoFrame;

- (id)init
{
    self = [super init];
    if (self)
    {
        _browserViewController = nil;
        _videoPath = nil;
        _videoController = nil;
        _videoFrame = CGRectZero;
    }
    return self;
}

- (void)showVideo:(NSString *)videoPath inRect:(CGRect)videoFrame
{
    
}

@end
