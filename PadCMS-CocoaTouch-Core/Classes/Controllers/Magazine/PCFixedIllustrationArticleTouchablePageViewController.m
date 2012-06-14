//
//  PCFixedIllustrationArticleTouchablePageViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 10.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCFixedIllustrationArticleTouchablePageViewController.h"

@implementation PCFixedIllustrationArticleTouchablePageViewController

- (void)dealloc
{
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:aPage])
    {
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.bodyViewController.view setHidden:YES];
}

-(void)loadView
{
    [super loadView];
    PCPageElementBody* bodyElement = (PCPageElementBody*)[self.page firstElementForType:PCPageElementTypeBody];
    if(bodyElement)
        [self.bodyViewController.view setHidden:bodyElement.showTopLayer == NO];

    [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
}
-(void)tapAction:(id)sender
{
    [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
    [self.bodyViewController.view setHidden:!self.bodyViewController.view.hidden];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
