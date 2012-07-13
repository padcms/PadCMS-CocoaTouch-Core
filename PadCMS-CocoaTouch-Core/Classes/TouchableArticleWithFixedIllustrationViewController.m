//
//  TouchableArticleWithFixedIllustrationViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/9/12.
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
	[self.view removeGestureRecognizer:_tapGestureRecognizer];
	self.tapGestureRecognizer = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) return;
	[self loadBackground];
	
	PCPageElementBody* bodyElement = (PCPageElementBody*)[_page firstElementForType:PCPageElementTypeBody];
    if (bodyElement != nil)
    {
		PageElementViewController* bodyController = [[PageElementViewController alloc] initWithElement:bodyElement];
		bodyController.view.frame = CGRectOffset(bodyController.view.frame, 0.0f, (CGFloat)bodyElement.top);
		[bodyController loadElementView];
		self.bodyViewController = bodyController;
		[bodyController release];
		[self.view addSubview:self.bodyViewController.view];
		
        if(bodyElement)
			[_bodyViewController.view setHidden:bodyElement.showTopLayer == NO];
				 
	}
	
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	_tapGestureRecognizer.cancelsTouchesInView = NO;
	//_tapGestureRecognizer.delegate = self;
    [self.view  addGestureRecognizer:_tapGestureRecognizer];
	
}

-(void)tapAction:(id)sender
{
     [self.bodyViewController.view setHidden:!self.bodyViewController.view.hidden];
}

@end
