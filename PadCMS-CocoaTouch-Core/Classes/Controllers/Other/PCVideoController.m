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
//#import "Reachability.h"
#import "PCConfig.h"
#import "PCBrowserViewController.h"
#import "PCDownloadApiClient.h"

@interface PCVideoController () 

- (BOOL) isConnectionEstablished;
- (void) fullScreenMovie:(NSNotification *) notification;
- (void) pushVideoScreen:(NSNotification *) notification;
- (void) startPlayingVideo;
- (void) stopPlayingVideo;
- (void) videoHasFinishedPlaying:(NSNotification *) paramNotification;
- (void) videoHasChanged:(NSNotification *) paramNotification;
- (void) videoHasExitedFullScreen:(NSNotification *) paramNotification;

@end

@implementation PCVideoController

@synthesize moviePlayer = _moviePlayer;
@synthesize url = _url;
@synthesize isVideoPlaying = _isVideoPlaying;
@synthesize delegate = _delegate;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _moviePlayer = nil;
        _url = nil;
        _delegate = nil;
        _isVideoPlaying = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenMovie:) name:PCVCFullScreenMovieNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushVideoScreen:) name:PCVCPushVideoScreenNotification object:nil];
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
    _isVideoPlaying = NO;
    
    [super dealloc];
}

- (BOOL) isConnectionEstablished
{
	AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;    
	if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable) 
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous devez être connecté à Internet pour partager ce contenu." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
    
    return YES;
}

- (void) fullScreenMovie:(NSNotification*) notification
{   
	self.url = (NSURL *)notification.object;
	NSLog(@"url = %@", self.url);
    if (![[self.url absoluteString] hasPrefix:@"file://"] &&  ![self isConnectionEstablished] )
    {
        return;
    }
    
    if ([[self.url absoluteString] hasPrefix:@"file://"])
    {
        NSString* videoPath = [self.url absoluteString];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
        if (!fileExists)
        {
            NSRange pathRange = [videoPath rangeOfString:@"/element"];
            videoPath = [videoPath substringFromIndex:pathRange.location];
            videoPath = [[[PCConfig serverURLString] stringByAppendingString:@"/resources/none"] stringByAppendingString:videoPath];
            self.url = [NSURL URLWithString:videoPath];
        }
    }
    
    [self startPlayingVideo];
}

- (void) pushVideoScreen:(NSNotification*) notification
{
	NSString* theURL = (NSString*)notification.object;
    if (![theURL hasPrefix:@"file://"] &&  ![self isConnectionEstablished] )
    {
        return;
    }	
    
	PCBrowserViewController* bvc = [[PCBrowserViewController alloc] initWithNibName:nil bundle:nil];
	[bvc view];
	[bvc presentURL:theURL];
    
//    [self.delegate videoControllerWillShow:bvc animated:YES];
    
	[bvc release];
}


- (void) startPlayingVideo
{
    if (self.isVideoPlaying)
    {
        return;
    }
    
    
    if (self.moviePlayer != nil)
    {
        [self stopPlayingVideo];
    }
    
    MPMoviePlayerController *newMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.url];
    self.moviePlayer = newMoviePlayer;
    [newMoviePlayer release];
    [self.moviePlayer prepareToPlay];
    
    if ([self.delegate respondsToSelector:@selector(videoControllerShow:)]) 
    {
        [self.delegate videoControllerShow:self];
    }
    
    self.isVideoPlaying = YES;
    
    if (self.moviePlayer != nil)
    {
        
        NSLog(@"Successfully instantiated the movie player.");

        [self.moviePlayer play];
        [self.moviePlayer setFullscreen:YES animated:YES];
        [self.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    }
    else
    {
        NSLog(@"Failed to instantiate the movie player.");
    }
}

- (void) stopPlayingVideo
{
    if (self.moviePlayer != nil)
    {
        self.isVideoPlaying = NO;
        [self.moviePlayer stop];
        [self.moviePlayer setControlStyle:MPMovieControlStyleEmbedded];

        if ([self.delegate respondsToSelector:@selector(videoControllerHide:)]) 
        {
            [self.delegate videoControllerHide:self];
        }
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
    if (self.moviePlayer.loadState & MPMovieLoadStatePlayable)
    {
        NSLog(@"MPMovieLoadStatePlayable");
        return;
    }
    if (self.moviePlayer.loadState & MPMovieLoadStateUnknown)
    {
        NSLog(@"MPMovieLoadStateUnknown");
    }
    if (self.moviePlayer.loadState & MPMovieLoadStateStalled)
    {
        NSLog(@"MPMovieLoadStateStalled");
    }
    if (self.moviePlayer.loadState & MPMovieLoadStatePlaythroughOK)
    {
        NSLog(@"MPMovieLoadStatePlaythroughOK");
    }
}

-(void)videoHasExitedFullScreen:(NSNotification *)paramNotification
{
    [self stopPlayingVideo];
}

@end

