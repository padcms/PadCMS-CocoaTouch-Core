//
//  PCCoverPageViewControllerViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 27.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCCoverPageViewControllerViewController.h"
#import "PCRevision.h"
#import "PCScrollView.h"

@interface PCCoverPageViewControllerViewController ()

@end

@implementation PCCoverPageViewControllerViewController

@synthesize advertViewController;

- (void)dealloc
{
    self.advertViewController = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    showVidioController = YES;
    PCPageElementBody* advertElement = (PCPageElementBody*)[page firstElementForType:PCPageElementTypeAdvert];
    if (advertElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:advertElement.resource];
        
        self.advertViewController = [[[PCPageElementViewController alloc] initWithResource:fullResource] autorelease];
        [self.advertViewController setTargetWidth:self.mainScrollView.bounds.size.width];
        [self.mainScrollView addSubview:self.advertViewController.view];
        [self.mainScrollView setContentSize:[self.advertViewController.view frame].size];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) loadFullView
{   
    [super loadFullView];
    PCPageElementVideo* videoElement = (PCPageElementVideo*)[page firstElementForType:PCPageElementTypeVideo];

    if ([[self magazineViewController] currentColumnViewController]==[self columnViewController])
    {
        if (showVidioController)
        {
            if (videoElement)
            {
                if (videoElement.stream)
                    [self showVideo:videoElement.stream];
                
                if (videoElement.resource)
                    [self showVideo:[self.page.revision.contentDirectory stringByAppendingPathComponent:videoElement.resource]];
            }
            showVidioController = NO;
        }
        
        PCPageElementAdvert* advertElement = (PCPageElementAdvert*)[page firstElementForType:PCPageElementTypeAdvert];
        if (advertElement != nil)
        {
            if (!self.advertViewController.view.hidden)
            {        
                [self.advertViewController loadFullViewImmediate];
                [self performSelector:@selector(hideAdvert:) withObject:nil afterDelay:advertElement.advertDuration];
            }
        }
    }
        
    return ;
}

-(void)hideAdvert:(id)sender
{
    
    [self.advertViewController.view removeFromSuperview];
    [self.advertViewController.view setHidden:YES];
}

@end
