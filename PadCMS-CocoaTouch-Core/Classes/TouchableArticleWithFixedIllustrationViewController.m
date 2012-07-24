//
//  TouchableArticleWithFixedIllustrationViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "TouchableArticleWithFixedIllustrationViewController.h"
#import "PCPageElementBody.h"


@interface TouchableArticleWithFixedIllustrationViewController ()

@end

@implementation TouchableArticleWithFixedIllustrationViewController
@synthesize tapGestureRecognizer=_tapGestureRecognizer;

-(void)dealloc
{
	[self.view removeGestureRecognizer:_tapGestureRecognizer];
    [_tapGestureRecognizer release], _tapGestureRecognizer = nil;
	[super dealloc];
}

-(void)releaseViews
{
	[super releaseViews];
	[self.view removeGestureRecognizer:_tapGestureRecognizer];
	self.tapGestureRecognizer = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) [self showHUD];
	if (!_page.isComplete) return;
	[self loadBackground];
	
	PCPageElementBody* bodyElement = (PCPageElementBody*)[_page firstElementForType:PCPageElementTypeBody];
    if (bodyElement != nil)
    {
		PageElementViewController* bodyController = [[PageElementViewController alloc] initWithElement:bodyElement andFrame: CGRectOffset(self.view.bounds, 0.0f, (CGFloat)bodyElement.top)];
		self.bodyViewController = bodyController;
		[bodyController release];
		[self.view addSubview:self.bodyViewController.elementView];
		
        if(bodyElement)
			[_bodyViewController.elementView setHidden:bodyElement.showTopLayer == NO];
				 
	}
	
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	_tapGestureRecognizer.cancelsTouchesInView = NO;
	[self.view  addGestureRecognizer:_tapGestureRecognizer];
	
}

-(void)tapAction:(id)sender
{
     [self.bodyViewController.elementView setHidden:!self.bodyViewController.elementView.hidden];
}

@end
