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

@interface AbstractBasePageViewController ()

@end

@implementation AbstractBasePageViewController
@synthesize page = _page;
@synthesize delegate=_delegate;
@synthesize actionButtons=_actionButtons;

-(void)dealloc
{
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
    }
    return self;
}

- (void)loadView
{
	UIView *view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
	view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.view = view;
	tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	tapGestureRecognizer.delegate = self;
    [self.view  addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)loadFullView
{
	
}

-(void)releaseViews
{
	self.actionButtons = nil;
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
	
	NSAssert([galleryActiveZones lastObject],@"No active zones for gallery");
	
	CGRect frame = [self activeZoneRectForType:[(PCPageActiveZone*)[galleryActiveZones lastObject] URL]];
	
	UIButton* galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	galleryButton.frame = frame;
//	galleryButton.backgroundColor = [UIColor redColor];
	[galleryButton addTarget:self.delegate action:@selector(showGallery) forControlEvents:UIControlEventTouchUpInside];
	[self.actionButtons addObject:galleryButton];
	[self.view addSubview:galleryButton];
	
}

-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    NSArray* actions = [self activeZonesAtPoint:point];
    for (PCPageActiveZone* action in actions)
        if ([self pdfActiveZoneAction:action])
            break;
    if (actions.count == 0)
    {
     //   [self.magazineViewController tapAction:gestureRecognizer];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *) touch {
	
	if (([touch.view isKindOfClass:[UIButton class]]) &&
		(gestureRecognizer == tapGestureRecognizer)) {
		return NO;
	}
	return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    NSArray* actions = [self activeZonesAtPoint:point];
    if (actions&&[actions count]>0)
        return YES;
    
    return NO;
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
    }
    //if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo]||[activeZone.URL hasPrefix:PCPDFActiveZoneVideo])
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo])
    {
        NSArray* videoElements = [self.page elementsForType:PCPageElementTypeVideo];
        PCPageElementVideo* video = nil;
        if ([videoElements count]>1)
        {
            NSArray* comps = [activeZone.URL componentsSeparatedByString:PCPDFActiveZoneActionVideo];
            if (comps&&[comps count]>1)
            {
				
                NSString* num = [comps objectAtIndex:1];
                int number = [num intValue]-1;
                video = [videoElements objectAtIndex:number];
            }
            else
            {
                video = [videoElements objectAtIndex:0];
            }
        }
        else 
        {
            if ([videoElements count]>0)
                video = [videoElements objectAtIndex:0];
        }
        
        if (video)
        {
            if (video.stream)
                [self showVideo:video.stream];
			
            if (video.resource)
                [self showVideo:[_page.revision.contentDirectory stringByAppendingPathComponent:video.resource]];
            
            return YES;
        }
    }
    
       
    if ([activeZone.URL hasPrefix:@"http://"])
    {
        if ([[activeZone.URL pathExtension] isEqualToString:@"mp4"]||[[activeZone.URL pathExtension] isEqualToString:@"avi"])
        {
            [self showVideo:activeZone.URL];
            return YES;
        }
        
        else if ([activeZone.URL hasPrefix:@"http://youtube.com"] || [activeZone.URL hasPrefix:@"http://www.youtube.com"] ||
				 [activeZone.URL hasPrefix:@"http://youtu.be"] || [activeZone.URL hasPrefix:@"http://www.youtu.be"] || 
				 [activeZone.URL hasPrefix:@"http://dailymotion.com"] || [activeZone.URL hasPrefix:@"http://www.dailymotion.com"] ||
				 [activeZone.URL hasPrefix:@"http://vimeo.com"] || [activeZone.URL hasPrefix:@"http://www.vimeo.com"])
        {
            CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
     //       [self showVideoWebView:activeZone.URL inRect:videoRect];            
            return YES;
        }
        
        else 
        {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:activeZone.URL]])
            {
                NSLog(@"Failed to open url:%@",[activeZone.URL description]);
            }
        }
    }
    return NO;
}


- (void) showVideo:(NSString *)resourcePath
{      
    if (resourcePath == nil) return;
    
    if([[resourcePath pathExtension] isEqualToString:@""])
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:PCVCPushVideoScreenNotification object:resourcePath];
        
        CGRect mainScreenRect = [[UIScreen mainScreen] bounds];
        if (!webBrowserViewController)
        {
            webBrowserViewController = [[PCBrowserViewController alloc] init];
        }
        webBrowserViewController.videoRect = mainScreenRect;
        [self.view addSubview:webBrowserViewController.view];
        [webBrowserViewController presentURL:resourcePath];
    }
    else
    {
        NSURL* videoURL = nil;
        if ([resourcePath hasPrefix:@"http://"]||[resourcePath hasPrefix:@"https://"])
        {
            videoURL = [NSURL URLWithString:resourcePath];
        }
        else
        {
            videoURL = [NSURL fileURLWithPath:resourcePath];
        }
        if (videoURL)
            [[NSNotificationCenter defaultCenter] postNotificationName:PCVCFullScreenMovieNotification object:videoURL];
    }
}


@end
