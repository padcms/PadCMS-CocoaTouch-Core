//
//  PCVideoManager.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Igor Getmanenko on 26.07.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

#import "PCVideoManager.h"
#import "PCBrowserViewController.h"
#import "PCVideoController.h"
#import "PCDownloadApiClient.h"
#import "PCLocalizationManager.h"
#import "PCConfig.h"
#import "PCMacros.h"

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

- (id) init;
- (BOOL)isConnectionEstablished;
- (void)showVideoController:(NSURL *)videoURL inRect:(CGRect)videoFrame;
- (void)showBrowserViewController:(NSURL *)videoURL inRect:(CGRect)videoFrame;

@end

@implementation PCVideoManager

@synthesize browserViewController = _browserViewController;
@synthesize videoController = _videoController;
@synthesize videoPath = _videoPath;
@synthesize videoFrame = _videoFrame;
@synthesize delegate = _delegate;

+ (id)sharedVideoManager 
{
    static PCVideoManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


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
    NSLog(@"url - %@, frame - %@", videoPath, NSStringFromCGRect(videoFrame));
    
    if (![videoPath hasPrefix:@"file://"] && ![self isConnectionEstablished] )
    {
        return;
    }
    
    else if ([videoPath hasPrefix:@"file://"])
    {
        NSURL *videoURL = [NSURL URLWithString:videoPath];
        NSString *tempVideoURLString = [videoURL path];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempVideoURLString];
        if (!fileExists)
        {
            NSRange pathRange = [tempVideoURLString rangeOfString:@"/element"];
            tempVideoURLString = [tempVideoURLString substringFromIndex:pathRange.location];
            tempVideoURLString = [[[PCConfig serverURLString] stringByAppendingString:@"/resources/none"] stringByAppendingString:tempVideoURLString];
            [self showVideoController:[NSURL URLWithString:tempVideoURLString] inRect:videoFrame];
            return;
        }
        [self showVideoController:[NSURL fileURLWithPath:tempVideoURLString] inRect:videoFrame];
        return;
    }
    
    else if ([[videoPath pathExtension] isEqualToString:@"mp4"]||[[videoPath pathExtension] isEqualToString:@"avi"])
    {
        [self showVideoController:[NSURL URLWithString:videoPath] inRect:videoFrame];
        return;
    }
    
    else if ([videoPath hasPrefix:@"http://"])
    {
        if ([videoPath hasPrefix:@"http://youtube.com"] || [videoPath hasPrefix:@"http://www.youtube.com"] ||
            [videoPath hasPrefix:@"http://youtu.be"] || [videoPath hasPrefix:@"http://www.youtu.be"] || 
            [videoPath hasPrefix:@"http://dailymotion.com"] || [videoPath hasPrefix:@"http://www.dailymotion.com"] ||
            [videoPath hasPrefix:@"http://vimeo.com"] || [videoPath hasPrefix:@"http://www.vimeo.com"])
        {
            [self showBrowserViewController:[NSURL URLWithString:videoPath] inRect:videoFrame];
            return;
        }
        
        else 
        {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:videoPath]])
            {
                NSLog(@"Failed to open url:%@",[videoPath description]);
            }
            return;
        }
    }
}

- (void)showVideoController:(NSURL *)videoURL inRect:(CGRect)videoFrame
{
    if(_videoController)
    {
        [_videoController release], _videoController = nil;
    }
    _videoController = [[PCVideoController alloc] init];
    [_videoController createVideoPlayer:videoURL inRect:videoFrame];
    [_delegate videoControllerWillShow:self.videoController.moviePlayer];
    [_videoController playVideo];
}

- (void)showBrowserViewController:(NSURL *)videoURL inRect:(CGRect)videoFrame
{    
    if(_browserViewController)
    {
        [_browserViewController release], _browserViewController = nil;
    }
    _browserViewController = [[PCBrowserViewController alloc] init];
    _browserViewController.videoRect = videoFrame;
    [_delegate videoControllerWillShow:self.browserViewController];
    [_browserViewController presentURL:[videoURL absoluteString]];
}

- (void)dismissVideo
{
    
}

- (BOOL)isConnectionEstablished
{
	AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;    
	if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable) 
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
                                                                                                       value:@"You must be connected to the Internet."]
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                       value:@"OK"]
                                              otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
    
    return YES;
}

- (BOOL)isVideoURL:(NSString *)URLString
{
    if ([URLString hasPrefix:@"http://youtube.com"] || [URLString hasPrefix:@"http://www.youtube.com"] ||
        [URLString hasPrefix:@"http://youtu.be"] || [URLString hasPrefix:@"http://www.youtu.be"] || 
        [URLString hasPrefix:@"http://dailymotion.com"] || [URLString hasPrefix:@"http://www.dailymotion.com"] ||
        [URLString hasPrefix:@"http://vimeo.com"] || [URLString hasPrefix:@"http://www.vimeo.com"])
    {
        return YES;
    }
    return NO;
}

@end
