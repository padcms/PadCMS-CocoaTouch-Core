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
@synthesize bodyScrollView=_bodyScrollView;
@synthesize tapGestureRecognizer=_tapGestureRecognizer;

-(void)dealloc
{
	[self.view removeGestureRecognizer:_tapGestureRecognizer];
    [_tapGestureRecognizer release], _tapGestureRecognizer = nil;
	[_bodyScrollView release], _bodyScrollView = nil;
	[super dealloc];
}

-(void)releaseViews
{
	[self.view removeGestureRecognizer:_tapGestureRecognizer];
	self.tapGestureRecognizer = nil;
	self.bodyScrollView = nil;
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
		UIScrollView* bodyScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		bodyScrollView.backgroundColor = [UIColor clearColor];
		bodyScrollView.showsVerticalScrollIndicator = NO;
		bodyScrollView.contentSize = bodyElement.size;
		[bodyScrollView addSubview:imageView];
		self.bodyScrollView = bodyScrollView;
		[self.view addSubview:_bodyScrollView];
		[bodyScrollView release];

		if(bodyElement)
			[_bodyScrollView setHidden:bodyElement.showTopLayer == NO];
				 
	}
	
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	_tapGestureRecognizer.cancelsTouchesInView = NO;
	//_tapGestureRecognizer.delegate = self;
    [self.view  addGestureRecognizer:_tapGestureRecognizer];
	
}

-(void)tapAction:(id)sender
{
     [self.bodyScrollView setHidden:!self.bodyScrollView.hidden];}




@end
