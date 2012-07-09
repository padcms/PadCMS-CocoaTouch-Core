//
//  AbstractBasePageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "AbstractBasePageViewController.h"
#import "PCPageActiveZone.h"


@interface AbstractBasePageViewController ()

@end

@implementation AbstractBasePageViewController
@synthesize page = _page;


-(void)dealloc
{
	[_page release], _page = nil;
	[super dealloc];
}
-(id)initWithPage:(PCPage *)page
{
	if (self = [super initWithNibName:nil bundle:nil])
    {
        _page = [page retain];
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



@end
