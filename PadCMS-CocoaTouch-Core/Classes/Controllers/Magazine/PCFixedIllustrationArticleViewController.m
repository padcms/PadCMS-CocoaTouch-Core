//
//  PCFixedIllustrationArticleViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 10.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCFixedIllustrationArticleViewController.h"
#import "PCScrollView.h"

@implementation PCFixedIllustrationArticleViewController

@synthesize articleView;

- (void)dealloc
{
    self.articleView = nil;
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:aPage])
    {
        articleView = nil;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect articleViewRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    
    if (CGRectEqualToRect(articleViewRect, CGRectZero))
        articleViewRect = [[self mainScrollView] bounds];
    
    self.articleView = [[[PCScrollView alloc] initWithFrame:articleViewRect] autorelease];
    [self.mainScrollView addSubview:self.articleView];
    
    //[self.mainScrollView setContentSize:self.backgroundView.frame.size];
    [self.bodyViewController.view removeFromSuperview];
    [self.articleView addSubview:self.bodyViewController.view];
    [self.articleView setContentSize:self.bodyViewController.view.frame.size];
}

-(void)loadView
{
    [super loadView];
    [self.articleView setContentSize:self.bodyViewController.view.frame.size];
    [self.mainScrollView setContentSize:self.mainScrollView.frame.size];
    
}

-(void)loadFullView
{
    [super loadFullView];
    [self.articleView setContentSize:self.bodyViewController.view.frame.size];
    [self.mainScrollView setContentSize:self.mainScrollView.frame.size];
}

@end
