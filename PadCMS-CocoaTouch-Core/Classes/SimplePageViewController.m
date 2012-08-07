//
//  SimplePageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "SimplePageViewController.h"
#import "PCPageElement.h"
#import "PCPageElementBody.h"
#import "PCPageElementVideo.h"
#import "PCScrollView.h"

@interface SimplePageViewController ()

@end

@implementation SimplePageViewController
@synthesize bodyViewController=_bodyViewController;
@synthesize backgroundViewController=_backgroundViewController;

-(void)dealloc
{
	[_backgroundViewController release], _backgroundViewController = nil;
	[_bodyViewController release], _bodyViewController = nil;
	[super dealloc];
}

-(void)releaseViews
{
	[super releaseViews];
	self.backgroundViewController = nil;
	self.bodyViewController = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) [self showHUD];
	if (!_page.isComplete) return;
	[self loadBackground];	
	PCPageElementBody* bodyElement = (PCPageElementBody*)[_page firstElementForType:PCPageElementTypeBody];
    if (bodyElement != nil)
    {
		PageElementViewController* elementController = [[PageElementViewController alloc] initWithElement:bodyElement andFrame:CGRectOffset(self.view.bounds, 0.0f, (CGFloat)bodyElement.top)];
		self.bodyViewController = elementController;
		[elementController release];
		[self.view addSubview:self.bodyViewController.elementView];
	}
	[self createActionButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createVideoFrame];
}

-(void)loadBackground
{
	PCPageElement* backgroundElement = [_page firstElementForType:PCPageElementTypeBackground];
    if (backgroundElement != nil)
	{
		PageElementViewController* elementController = [[PageElementViewController alloc] initWithElement:backgroundElement andFrame:self.view.bounds];
		self.backgroundViewController = elementController;
		[elementController release];
		[self.view addSubview:self.backgroundViewController.elementView];

	}
}

- (void)createVideoFrame
{
    /*NSLog(@"page.id - %d, elements - %@", _page.identifier, _page.elements);
    if ([_page hasPageActiveZonesOfType:PCPDFActiveZoneVideo] && 
        ![_page hasPageActiveZonesOfType:PCPDFActiveZoneActionVideo])
    {*/
        PCPageElementVideo *videoElement = (PCPageElementVideo*)[self.page firstElementForType:PCPageElementTypeVideo];
    if (videoElement)
        [self showVideo:videoElement];
    //}
}

- (void)showVideo:(PCPageElementVideo*)videoElement
{    
    CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
    
    if (CGRectEqualToRect(videoRect, CGRectZero))
    {
        videoRect = self.view.frame;
        if ((videoRect.size.width < videoRect.size.height) && (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])))
        {
            videoRect = CGRectMake(videoRect.origin.y, videoRect.origin.x, videoRect.size.height, videoRect.size.width);
        }
    }
    
    ((PCVideoManager *)[PCVideoManager sharedVideoManager]).delegate = self;
    
    if (videoElement.stream)
        [[PCVideoManager sharedVideoManager] showVideo:videoElement.stream inRect:videoRect];
    
    if (videoElement.resource)
    {
        NSURL *videoURL = [NSURL fileURLWithPath:[_page.revision.contentDirectory stringByAppendingPathComponent:videoElement.resource]];
        [[PCVideoManager sharedVideoManager] showVideo:[videoURL relativeString] inRect:videoRect];
    }
}

#pragma mark PCVideoManagerDelegate methods

- (void)videoControllerWillShow:(id)videoControllerToShow
{
    UIView *videoView = ((UIViewController*)videoControllerToShow).view;
    NSLog(@"videoView - %@", videoView);
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    if (CGRectEqualToRect(videoView.frame, appRect) || 
        (videoView.frame.size.width == appRect.size.height && videoView.frame.size.height == appRect.size.width))
    {
        [self showFullscreenVideo:videoView];
        return;
    }
    if (_backgroundViewController && !CGRectEqualToRect([_backgroundViewController.element rectForElementType:PCPageElementTypeVideo], CGRectZero))
    {
        [_backgroundViewController.elementView.scrollView addSubview:videoView];
        [_backgroundViewController.elementView.scrollView bringSubviewToFront:videoView];
    }
    else 
    {
        [_bodyViewController.elementView.scrollView addSubview:videoView];
        [_bodyViewController.elementView.scrollView bringSubviewToFront:videoView];
    }
}

- (void)videoControllerWillDismiss
{
    
}

@end
