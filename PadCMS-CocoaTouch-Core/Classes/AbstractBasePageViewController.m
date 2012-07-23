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
	galleryButton.backgroundColor = [UIColor redColor];
	[galleryButton addTarget:self.delegate action:@selector(showGallery) forControlEvents:UIControlEventTouchUpInside];
	[self.actionButtons addObject:galleryButton];
	[self.view addSubview:galleryButton];
	
}



@end
