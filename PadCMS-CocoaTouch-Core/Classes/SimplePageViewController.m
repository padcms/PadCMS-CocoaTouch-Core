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
@synthesize bodyView=_bodyView;
@synthesize backgroundView=_backgroundView;

-(void)dealloc
{
	[_backgroundView release], _backgroundView = nil;
	[_bodyView release], _bodyView = nil;
	[super dealloc];
}

-(void)releaseViews
{
	self.backgroundView = nil;
	self.bodyView = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) return;
	[self loadBackground];	
	PCPageElementBody* bodyElement = (PCPageElementBody*)[_page firstElementForType:PCPageElementTypeBody];
    if (bodyElement != nil)
    {
        NSString *fullResource = [_page.revision.contentDirectory stringByAppendingPathComponent:bodyElement.resource];
        UIImage* bodyImage = [UIImage imageWithContentsOfFile:fullResource];
		UIImageView* imageView = [[UIImageView alloc] initWithImage:bodyImage];
		imageView.frame = CGRectOffset(imageView.frame, 0.0f, (CGFloat)bodyElement.top);
		self.bodyView = imageView;
		[imageView release];
		[self.view addSubview:_bodyView];
	}

}

-(void)loadBackground
{
	PCPageElement* backgroundElement = [_page firstElementForType:PCPageElementTypeBackground];
    if (backgroundElement != nil)
	{
		NSString *fullResource = [_page.revision.contentDirectory stringByAppendingPathComponent:backgroundElement.resource];
		UIImage* backgroundImage = [UIImage imageWithContentsOfFile:fullResource];
		UIImageView* imageView = [[UIImageView alloc] initWithImage:backgroundImage];
		self.backgroundView = imageView;
		[imageView release];
		[self.view addSubview:_backgroundView];
	}

}

@end
