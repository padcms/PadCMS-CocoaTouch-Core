//
//  TouchableArticleWithFixedIllustrationViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "TouchableArticleWithFixedIllustrationViewController.h"
#import "PCPageElementBody.h"
#import "PCPageActiveZone.h"
#import "PCScrollView.h"

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createVideoFrame];
}

-(void)tapAction:(id)sender
{
    CGPoint tapLocation = [sender locationInView:[sender view]];
    
    if (!self.bodyViewController.elementView.hidden&& 
        ((NSArray*)[super activeZonesAtPoint:tapLocation]).count == 0)
    {
        CGPoint tapLocationWithOffset;
        tapLocationWithOffset.x = self.bodyViewController.elementView.scrollView.contentOffset.x + tapLocation.x;
        tapLocationWithOffset.y = self.bodyViewController.elementView.scrollView.contentOffset.y + tapLocation.y;
        NSArray* actions = [self activeZonesAtPoint:tapLocationWithOffset];
        for (PCPageActiveZone* action in actions)
            if ([self pdfActiveZoneAction:action])
                break;
        if (actions.count == 0)
        {
            self.bodyViewController.elementView.hidden = YES;
            [self changeVideoLayout:self.bodyViewController.elementView.hidden];
        }
    }
    
    else if (self.bodyViewController.elementView.hidden && ![self.page hasPageActiveZonesOfType:PCPDFActiveZoneActionButton])
    {
        //[self.articleView setScrollEnabled:self.bodyViewController.elementView.hidden];
        [self.bodyViewController.elementView setHidden:!self.bodyViewController.elementView.hidden];
        [self changeVideoLayout:self.bodyViewController.elementView.hidden];
    }
    
    else
    {
        [super tapAction:sender];
    }
}

-(BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    [super pdfActiveZoneAction:activeZone];
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
    {
        //[self.articleView setScrollEnabled:self.bodyViewController.elementView.hidden];
        [self.bodyViewController.elementView setHidden:!self.bodyViewController.elementView.hidden];
        [self changeVideoLayout:self.bodyViewController.elementView.hidden];
        return YES;
    }
    return NO;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
