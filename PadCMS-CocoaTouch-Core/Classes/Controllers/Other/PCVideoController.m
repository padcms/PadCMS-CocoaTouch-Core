//
//  PCVideoContoller.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 10.02.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
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

#import "PCVideoController.h"
#import "PCConfig.h"
#import "PCBrowserViewController.h"
#import "PCDownloadApiClient.h"
#import "MBProgressHUD.h"
#import "PCLocalizationManager.h"
#import "PCVideoManager.h"

@interface PCVideoController () 

- (BOOL) isConnectionEstablished;
- (void) videoHasFinishedPlaying:(NSNotification *) paramNotification;
- (void) videoHasChanged:(NSNotification *) paramNotification;
- (void) videoHasExitedFullScreen:(NSNotification *) paramNotification;
- (void) showHUD;
- (void) hideHUD;

@end

@implementation PCVideoController

@synthesize moviePlayer = _moviePlayer;
@synthesize url = _url;
@synthesize isVideoPlaying = _isVideoPlaying;
@synthesize delegate = _delegate;
@synthesize HUD = _HUD;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _moviePlayer = nil;
        _url = nil;
        _delegate = nil;
        _HUD = nil;
        _isVideoPlaying = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoHasFinishedPlaying:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoHasChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoHasExitedFullScreen:) name:MPMoviePlayerDidExitFullscreenNotification object:self.moviePlayer];
    }
    
    return  self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_moviePlayer release], _moviePlayer = nil;
    [_url release], _url = nil;
    [_HUD release], _HUD = nil;
    _isVideoPlaying = NO;
    
    [super dealloc];
}

- (BOOL) isConnectionEstablished
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


- (void) createVideoPlayer: (NSURL*)videoURL inRect:(CGRect)videoRect
{
  //  NSLog(@"url - %@", videoURL);
    
    if (_moviePlayer != nil)
    {
        [self stopPlayingVideo];
    }
    
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    
    _moviePlayer.view.frame = videoRect;
    _moviePlayer.view.autoresizingMask = UIViewContentModeScaleAspectFill;
    
    if ([[PCVideoManager sharedVideoManager] isVideoRectEqualToApplicationFrame:videoRect])
    {
        [_moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    }
    else
    {
        [_moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    [self showHUD];
}

- (void) playVideo
{
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    _isVideoPlaying = YES;
    
    if (_moviePlayer != nil)
    {
        NSLog(@"Successfully instantiated the movie player.");
        
        if ([[PCVideoManager sharedVideoManager] isVideoRectEqualToApplicationFrame:_moviePlayer.view.frame])
            [_moviePlayer play];
        else 
            _moviePlayer.shouldAutoplay = NO;
    }
    else
    {
        NSLog(@"Failed to instantiate the movie player.");
    }
}

- (void) stopPlayingVideo
{
    if (_moviePlayer != nil)
    {
        _isVideoPlaying = NO;
        [self hideHUD];
        [_moviePlayer stop];
        
        [_moviePlayer.view removeFromSuperview];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [_moviePlayer release], _moviePlayer = nil;
    }
}

-(void)showHUD
{
    if (!_HUD)
    {
        _HUD = [[MBProgressHUD alloc] initWithView:self.moviePlayer.view];
        _HUD.labelText = [PCLocalizationManager localizedStringForKey:@"LABEL_LOADING" value:@"Loading"]; 
    }
    
    [self.moviePlayer.view addSubview:self.HUD];
    [_HUD show:YES];
}

-(void)hideHUD
{
	if (self.HUD)
	{
        [_HUD hide:YES];
		[_HUD removeFromSuperview];
		[_HUD release];
		_HUD = nil;
	}
}

#pragma mark - notification functions
- (void) videoHasFinishedPlaying:(NSNotification *)paramNotification
{
    NSNumber *reason = [paramNotification.userInfo
                        valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    if (reason != nil)
    {
        NSInteger reasonAsInteger = [reason integerValue];
        switch (reasonAsInteger)
        {
            case MPMovieFinishReasonPlaybackEnded:
            {
                /* The movie ended normally */ 
                NSLog(@"MPMovieFinishReasonPlaybackEnded");
                break;
            } 
            case MPMovieFinishReasonPlaybackError:
            {
                /* An error happened and the movie ended */ 
                NSLog(@"MPMovieFinishReasonPlaybackError");
                break;
            } 
            case MPMovieFinishReasonUserExited:
            {
                /* The user exited the player */ 
                NSLog(@"MPMovieFinishReasonUserExited");
                break;
            }
        }
        [self stopPlayingVideo];
        return;
    }
}

-(void)videoHasChanged:(NSNotification *)paramNotification
{
    if (_moviePlayer.loadState & MPMovieLoadStatePlayable)
    {
        NSLog(@"MPMovieLoadStatePlayable");
        [self hideHUD];
    }
    if (_moviePlayer.loadState & MPMovieLoadStateUnknown)
    {
        NSLog(@"MPMovieLoadStateUnknown");
    }
    if (_moviePlayer.loadState & MPMovieLoadStateStalled)
    {
        NSLog(@"MPMovieLoadStateStalled");
    }
    if (_moviePlayer.loadState & MPMovieLoadStatePlaythroughOK)
    {
        NSLog(@"MPMovieLoadStatePlaythroughOK");
    }
}

-(void)videoHasExitedFullScreen:(NSNotification *)paramNotification
{
    [_moviePlayer play];
}

@end

