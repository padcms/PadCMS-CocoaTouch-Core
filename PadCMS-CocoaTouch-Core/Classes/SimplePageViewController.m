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
#import "PCPageActiveZone.h"

@interface SimplePageViewController ()

-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer;

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
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	tapGestureRecognizer.delegate = self;
    [self.view  addGestureRecognizer:tapGestureRecognizer];
    
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
    if (([_page hasPageActiveZonesOfType:PCPDFActiveZoneVideo] && 
        ![_page hasPageActiveZonesOfType:PCPDFActiveZoneActionVideo]) || 
        _page.revision.coverPage == _page)
    {
        PCPageElementVideo *videoElement = (PCPageElementVideo*)[self.page firstElementForType:PCPageElementTypeVideo];
        if (videoElement && !(_page.revision.coverPage == _page && [[PCVideoManager sharedVideoManager] isStartVideoShown]))
        {
            [self showVideo:videoElement];
            [[PCVideoManager sharedVideoManager] setIsStartVideoShown:YES];
        }
    }
}

- (void)showVideo:(PCPageElementVideo*)videoElement
{
    [self showVideo:videoElement inRect:CGRectZero];
}

- (void)showVideo:(PCPageElementVideo*)videoElement inRect:(CGRect)videoFrame
{    
    CGRect videoRect = videoFrame;
    
    if (CGRectEqualToRect(videoRect, CGRectZero))
    {
        videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
        
        if (CGRectEqualToRect(videoRect, CGRectZero))
        {
            videoRect = self.view.frame;
            if ((videoRect.size.width < videoRect.size.height) && (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])))
            {
                videoRect = CGRectMake(videoRect.origin.y, videoRect.origin.x, videoRect.size.height, videoRect.size.width);
            }
        }
    }
    
    [[PCVideoManager sharedVideoManager] setDelegate:self];

    if (videoElement.stream)
        [[PCVideoManager sharedVideoManager] showVideo:videoElement.stream inRect:videoRect];
    
    if (videoElement.resource)
    {
        NSURL *videoURL = [NSURL fileURLWithPath:[_page.revision.contentDirectory stringByAppendingPathComponent:videoElement.resource]];
        [[PCVideoManager sharedVideoManager] showVideo:[videoURL relativeString] inRect:videoRect];
    }
}

-(BOOL)pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneNavigation])
    {
        NSString* mashinName = [activeZone.URL lastPathComponent];
        NSArray* components = [mashinName componentsSeparatedByString:@"#"];
        NSString* addeditional = nil;
        if ([components count] > 1)
        {
            mashinName = [components objectAtIndex:0];
            addeditional = [components objectAtIndex:1];
        }
        
		PCPage* targetPage = [_page.revision pageWithMachineName:mashinName];
        [self.delegate gotoPage:targetPage];
        return YES;
    }
    //if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo]||[activeZone.URL hasPrefix:PCPDFActiveZoneVideo])
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo])
    {
        PCPageElementVideo *video = (PCPageElementVideo *)[self.page firstElementForType:PCPageElementTypeVideo];
        [self showVideo:video];
        return YES;
    }
    if ([activeZone.URL hasPrefix:@"http://"])
    {
        if (![[PCVideoManager sharedVideoManager] isVideoURL:activeZone.URL])
        {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:activeZone.URL]])
            {
                NSLog(@"Failed to open url:%@",[activeZone.URL description]);
            }
        }
        else
        {
            NSLog(@"url - %@", activeZone.URL);
            PCPageElementVideo *video = [[PCPageElementVideo alloc] init];
            video.stream = activeZone.URL;
            CGRect videoRect = activeZone.rect;
            CGSize pageSize = self.view.bounds.size;
            if ((pageSize.width < pageSize.height) && (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])))
            {
                pageSize = CGSizeMake(pageSize.height, pageSize.width);
            }
            videoRect.origin.y = pageSize.height - videoRect.origin.y - videoRect.size.height;
            [self showVideo:video inRect:videoRect];
        }
        return YES;
    }
  
    return NO;
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
    if (_backgroundViewController)
    {
        for (PCPageActiveZone *activeZone in _backgroundViewController.element.activeZones)
        {
            if ([[PCVideoManager sharedVideoManager] isVideoURL:activeZone.URL] || [activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo])
            {
                [_backgroundViewController.elementView.scrollView addSubview:videoView];
                [_backgroundViewController.elementView.scrollView bringSubviewToFront:videoView];
                return;
            }
        }
    }
    [_bodyViewController.elementView.scrollView addSubview:videoView];
    [_bodyViewController.elementView.scrollView bringSubviewToFront:videoView];
}

- (void)videoControllerWillDismiss
{
    
}

#pragma mark UIGestureRecognizerDelegate methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *) touch {
	
	if (([touch.view isKindOfClass:[UIButton class]]) &&
		(gestureRecognizer == tapGestureRecognizer)) {
		return NO;
	}
	return YES;
}

-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    NSLog(@"tap - %@", NSStringFromCGPoint(point));
    NSArray* actions = [self activeZonesAtPoint:point];
    for (PCPageActiveZone* action in actions)
        if ([self pdfActiveZoneAction:action])
            break;
    if (actions.count == 0)
    {
        //      [self.delegate tapAction:gestureRecognizer];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    NSArray* actions = [self activeZonesAtPoint:point];
    if (actions&&[actions count]>0)
        return YES;
    //   [self.delegate tapAction:gestureRecognizer];
    
    return NO;
}

@end
