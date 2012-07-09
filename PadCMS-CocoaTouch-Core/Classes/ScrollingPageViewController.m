//
//  ScrollingPageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "ScrollingPageViewController.h"
#import "PCScrollView.h"

@interface ScrollingPageViewController ()
@property (nonatomic, retain) PCScrollView* paneScrollView;
@end

@implementation ScrollingPageViewController
@synthesize paneScrollView=_paneScrollView;

-(void)dealloc
{
	[_paneScrollView release], _paneScrollView = nil;
	[super dealloc];
}

-(void)releaseViews
{
	self.paneScrollView = nil;
}


-(void)loadFullView
{
	[super loadFullView];
	CGRect scrollPaneRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    
    if (CGRectEqualToRect(scrollPaneRect, CGRectZero)) {
        scrollPaneRect = self.view.bounds;
    }
    
    _paneScrollView = [[PCScrollView alloc] initWithFrame:scrollPaneRect];
    _paneScrollView.delegate = self;
    _paneScrollView.contentSize = CGSizeZero;
    _paneScrollView.showsVerticalScrollIndicator = NO;
    _paneScrollView.showsHorizontalScrollIndicator = NO;
    
    PCPageElement* scrollingPaneElement = [_page firstElementForType:PCPageElementTypeScrollingPane];
    if (scrollingPaneElement != nil)
    {
        NSString *fullResource = [_page.revision.contentDirectory stringByAppendingPathComponent:scrollingPaneElement.resource];
        
		UIImage* scrollingPaneImage = [UIImage imageWithContentsOfFile:fullResource];
		UIImageView* imageView = [[UIImageView alloc] initWithImage:scrollingPaneImage];
		
        [_paneScrollView addSubview:imageView];
        [_paneScrollView setContentSize:imageView.frame.size];
        [_paneScrollView setContentInset:UIEdgeInsetsMake(0, -_paneScrollView.frame.origin.x, 0, 0)];
		[imageView release];
    }
    
    [_paneScrollView setUserInteractionEnabled:YES];
    [self.view addSubview: _paneScrollView];
    [self.view bringSubviewToFront: _paneScrollView];
    
    if (_paneScrollView.frame.size.width > self.view.frame.size.width)
    {
        CGRect scrollingPaneRect = _paneScrollView.frame;
        scrollingPaneRect.size.width = self.view.frame.size.width;
        _paneScrollView.frame = scrollingPaneRect;
    }
    
    if (_paneScrollView.contentSize.width > _paneScrollView.frame.size.width)
    {
        _paneScrollView.contentSize = CGSizeMake(_paneScrollView.frame.size.width, _paneScrollView.contentSize.height);
    }
    
       
}

@end
