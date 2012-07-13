//
//  SimplePageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "SimplePageViewController.h"
#import "PCPageElement.h"
#import "PCPageElementBody.h"



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
	self.backgroundViewController = nil;
	self.bodyViewController = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) return;
	[self loadBackground];	
	PCPageElementBody* bodyElement = (PCPageElementBody*)[_page firstElementForType:PCPageElementTypeBody];
    if (bodyElement != nil)
    {
		PageElementViewController* elementController = [[PageElementViewController alloc] initWithElement:bodyElement];
		elementController.view.frame = self.view.bounds;
		elementController.view.frame = CGRectOffset(elementController.view.frame, 0.0f, (CGFloat)bodyElement.top);
		[elementController loadElementView];
		self.bodyViewController = elementController;
		[elementController release];
		[self.view addSubview:self.bodyViewController.scrollView];
		
	}

}

-(void)loadBackground
{
	PCPageElement* backgroundElement = [_page firstElementForType:PCPageElementTypeBackground];
    if (backgroundElement != nil)
	{
		PageElementViewController* elementController = [[PageElementViewController alloc] initWithElement:backgroundElement];
		elementController.view.frame = self.view.bounds;
		[elementController loadElementView];
		self.backgroundViewController = elementController;
		[elementController release];
		[self.view addSubview:self.backgroundViewController.scrollView];
		
		
		
	}

}

@end
