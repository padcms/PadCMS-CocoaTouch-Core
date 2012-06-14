//
//  PCVideoContoller.h
//  Pad CMS
//
//  Created by Igor Getmanenko on 10.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

//notifications
#define PCVCFullScreenMovieNotification @"PCFullScreenMovie"
#define PCVCPushVideoScreenNotification @"PCPushVideoScreen"

@class PCVideoController;

@protocol PCVideoControllerDelegate <NSObject>

- (void)videoControllerShow:(PCVideoController *)videoController;
- (void)videoControllerHide:(PCVideoController *)videoController;

@end

@interface PCVideoController : NSObject
{
    MPMoviePlayerController *_moviePlayer;
    NSURL *_url;
    BOOL _isVideoPlaying;
}

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) BOOL isVideoPlaying;
@property (nonatomic, assign, readwrite) id <PCVideoControllerDelegate> delegate;

- (id) init;

@end
