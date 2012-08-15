//
//  AbstractBasePageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "AbstractBasePageViewController.h"
#import "PCPageActiveZone.h"
#import "PCPageElementBody.h"
#import "PCPageElementVideo.h"
#import "PCBrowserViewController.h"
#import "PCVideoController.h"
#import "MBProgressHUD.h"
#import "PCVideoManager.h"
#import "PCStyler.h"

@interface AbstractBasePageViewController ()

@end

@implementation AbstractBasePageViewController
@synthesize page = _page;
@synthesize delegate=_delegate;
@synthesize actionButtons=_actionButtons;

-(void)dealloc
{
	[self hideHUD];
	[self.page removeObserver:self forKeyPath:@"isComplete"];
	_delegate = nil;
	[_page release], _page = nil;
	[_actionButtons release], _actionButtons = nil;
	[super dealloc];
}
-(id)initWithPage:(PCPage *)page
{
	if (self = [super initWithNibName:nil bundle:nil])
    {
        _page = [page retain];
		_scale = [UIScreen mainScreen].scale;
		_actionButtons = [[NSMutableArray alloc] init];
		[self.page addObserver:self forKeyPath:@"isComplete" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)loadView
{
	UIView *view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
	view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	view.backgroundColor = _page.backgroundColor;
	self.view = view;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)loadFullView
{
	if (!_page.isComplete) [self showHUD];
}

-(void)releaseViews
{
	self.actionButtons = nil;
}

- (void)changeVideoLayout: (BOOL)isVideoEnabled
{
    if (webBrowserViewController)
    {
        if (isVideoEnabled)
        {
            [self.view bringSubviewToFront:webBrowserViewController.view];
        }
        else 
        {
           // [self.view insertSubview:webBrowserViewController.view aboveSubview:self.backgroundViewController.view];    
        }
    }
}

- (CGRect)activeZoneRectForType:(NSString*)zoneType
{
    for (PCPageElement* element in self.page.elements)
    {
        CGRect rect = [element rectForElementType:zoneType];
        if (!CGRectEqualToRect(rect, CGRectZero))
        {
            CGSize pageSize = self.view.bounds.size;
            float scale = pageSize.width/element.size.width;
            rect.size.width *= scale;
            rect.size.height *= scale;
            rect.origin.x *= scale;
            rect.origin.y *= scale;
            rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
            return rect;
        }
    }
    return CGRectZero;
}


-(NSArray*)activeZonesAtPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
    
    for (PCPageElement* element in self.page.elements)
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            CGRect rect = pdfActiveZone.rect;
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                CGSize pageSize = self.view.bounds.size;
                float scale = pageSize.width/element.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
//				UIView* testView = [[UIView alloc] initWithFrame:rect];
//                testView.backgroundColor = [UIColor redColor];
//                [self.view addSubview:testView];
                if (CGRectContainsPoint(rect, point))
                {
                    [activeZones addObject:pdfActiveZone];
                }
			}
        }
    }
    return [activeZones autorelease];
}

-(void)createActionButtons
{
	for (UIView* view in _actionButtons) {
		[view removeFromSuperview];
	}
	[self createGalleryButton];
}

-(void)createGalleryButton
{
	if ([[self.page elementsForType:PCPageElementTypeGallery]count]==0) return;
	NSMutableArray* galleryActiveZones = [[NSMutableArray alloc] init];
	
	PCPageElement* backgroundElement = [_page firstElementForType:PCPageElementTypeBackground];
	
	for (PCPageActiveZone* activeZone in backgroundElement.activeZones) {
		if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionPhotos])
		{
			[galleryActiveZones addObject:activeZone];	
		}
	}
	
	if (![galleryActiveZones lastObject])
	{
		PCPageElementBody* bodyElement = (PCPageElementBody*)[_page firstElementForType:PCPageElementTypeBody];
		
		// Base controller must ignore gallery in page with template that show gallery when device orientation changed
		if (bodyElement && bodyElement.showGalleryOnRotate) return;
		
		for (PCPageActiveZone* activeZone in bodyElement.activeZones) {
			if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionPhotos])
			{
				[galleryActiveZones addObject:activeZone];	
			}
		}
		
	}
	
	//NSAssert([galleryActiveZones lastObject],@"No active zones for gallery");
	UIButton* galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	if ([galleryActiveZones lastObject])
	{
		CGRect frame = [self activeZoneRectForType:[(PCPageActiveZone*)[galleryActiveZones lastObject] URL]];
		galleryButton.frame = frame;
	}
	else
	{
		NSMutableDictionary* buttonOption = [NSMutableDictionary dictionary];
	
        if (self.page.color)
           [buttonOption setObject:self.page.color forKey:PCButtonTintColorOptionKey];
		[buttonOption setObject:[NSValue valueWithCGRect:self.view.bounds] forKey:PCButtonParentViewFrameKey];
        [[PCStyler defaultStyler] stylizeElement:galleryButton withStyleName:PCGalleryEnterButtonKey withOptions:buttonOption];
        [galleryButton setFrame:CGRectMake(self.view.frame.size.width - galleryButton.frame.size.width, 0, galleryButton.frame.size.width, galleryButton.frame.size.height)];
        [[PCStyler defaultStyler] stylizeElement:galleryButton withStyleName:PCGalleryEnterButtonKey withOptions:buttonOption];
		NSLog(@"Gallery Button frame = %@", NSStringFromCGRect(galleryButton.frame));
	}
	
	
	
	[galleryActiveZones release];
	
//	galleryButton.backgroundColor = [UIColor redColor];
	[galleryButton addTarget:self.delegate action:@selector(showGallery) forControlEvents:UIControlEventTouchUpInside];
	[self.actionButtons addObject:galleryButton];
	[self.view addSubview:galleryButton];
	
}

- (void) showFullscreenVideo:(UIView *)videoView
{
    [self.delegate showVideo:videoView];
}

-(void)showHUD
{
	
	if (self.page.isComplete) return;
    if (HUD)
    {
        return;
        _page.progressDelegate = nil;
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    self.page.isUpdateProgress = YES;
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    _page.progressDelegate = HUD;
    [HUD show:YES];
	
}

-(void)hideHUD
{
	if (HUD)
	{
		[HUD hide:YES];
		self.page.isUpdateProgress = NO;
		_page.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
}

-(void) observeValueForKeyPath: (NSString *)keyPath ofObject: (id) object
                        change: (NSDictionary *) change context: (void *) context
{
	if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) 
	{
		BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
		if (newValue)
		{
			[self hideHUD];
			[self loadFullView];
		}
	}
}


@end
