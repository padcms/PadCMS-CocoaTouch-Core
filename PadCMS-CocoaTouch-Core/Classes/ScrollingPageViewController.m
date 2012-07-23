//
//  ScrollingPageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "ScrollingPageViewController.h"
#import "PCScrollView.h"

@interface ScrollingPageViewController ()
@property (nonatomic, retain) PageElementViewController* scrollingPanController;
@end

@implementation ScrollingPageViewController
@synthesize scrollingPanController=_scrollingPanController;

-(void)dealloc
{
	[_scrollingPanController release], _scrollingPanController = nil;
	[super dealloc];
}

-(void)releaseViews
{
	[super releaseViews];
	self.scrollingPanController = nil;
}


-(void)loadFullView
{
	[super loadFullView];
	    
       
    PCPageElement* scrollingPaneElement = [_page firstElementForType:PCPageElementTypeScrollingPane];
    if (scrollingPaneElement != nil)
    {
		CGRect scrollPaneRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
		
		if (CGRectEqualToRect(scrollPaneRect, CGRectZero)) {
			scrollPaneRect = self.view.bounds;
		}

		PageElementViewController* scrollingPanController = [[PageElementViewController alloc] initWithElement:scrollingPaneElement andFrame:scrollPaneRect];
		self.scrollingPanController = scrollingPanController;
		[scrollingPanController release];
		
       // [_paneScrollView setContentInset:UIEdgeInsetsMake(0, -_paneScrollView.frame.origin.x, 0, 0)];
		
		if (_scrollingPanController.elementView.frame.size.width > self.view.frame.size.width)
		{
			CGRect scrollingPaneRect = _scrollingPanController.elementView.frame;
			scrollingPaneRect.size.width = self.view.frame.size.width;
			_scrollingPanController.elementView.frame = scrollingPaneRect;
		}
		
		[self.view addSubview:_scrollingPanController.elementView];
		
	
		
    }
    
       
    
    
/*    if (_paneScrollView.contentSize.width > _paneScrollView.frame.size.width)
    {
        _paneScrollView.contentSize = CGSizeMake(_paneScrollView.frame.size.width, _paneScrollView.contentSize.height);
    }*/
    
	
       
}

@end
