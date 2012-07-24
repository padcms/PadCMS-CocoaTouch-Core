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

@end
