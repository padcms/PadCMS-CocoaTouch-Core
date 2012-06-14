//
//  PCPageWithOverlayViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 15.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageWithOverlayViewController.h"
#import "PCRevisionViewController.h"
#import "PCRevision.h"
#import "PCScrollView.h"

@implementation PCPageWithOverlayViewController

@synthesize overlayViewController;

-(void)dealloc
{
    self.overlayViewController = nil;
    [super dealloc];
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    PCPageElement* overlayElement = (PCPageElement*)[page firstElementForType:PCPageElementTypeOverlay];
    if (overlayElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:overlayElement.resource];
        
        self.overlayViewController = [[[PCPageElementViewController alloc] initWithResource:fullResource] autorelease];
        [self.overlayViewController setTargetWidth:self.mainScrollView.bounds.size.width];

        [self.mainScrollView addSubview:self.overlayViewController.view];
        [self.mainScrollView setContentSize:[self.overlayViewController.view frame].size];
    }

    [self.overlayViewController.view setHidden:YES];
}

- (void) loadFullView
{
    [super loadFullView];
    [self.overlayViewController loadFullViewImmediate];

}

- (void) unloadFullView
{
    [super unloadFullView];
    [self.overlayViewController unloadView];
}

-(void)tapAction:(id)sender
{
    [self.overlayViewController.view setHidden:!self.overlayViewController.view.hidden];
}

@end
