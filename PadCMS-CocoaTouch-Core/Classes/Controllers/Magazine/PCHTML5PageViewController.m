//
//  PCHTML5PageViewController.m
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCHTML5PageViewController.h"
#import "PCPageElementHTML5ViewController.h"
#import "PCRevision.h"

@implementation PCHTML5PageViewController

@synthesize html5ElementViewController = _html5ElementViewController;

-(void)loadView
{
    [super loadView];
}

- (void) loadFullView
{
    [super loadFullView];
    if (self.html5ElementViewController) {
        [self.html5ElementViewController loadFullView];
    }
}

- (void) unloadFullView
{
    [super unloadFullView];
    if (self.html5ElementViewController) {
        [self.html5ElementViewController unloadView];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];    
  
    PCPageElementHtml5* html5Element = (PCPageElementHtml5*)[page firstElementForType:PCPageElementTypeHtml5];
    if (html5Element != nil)
    {
        _html5ElementViewController = [[PCPageElementHTML5ViewController alloc] initWithElement:html5Element 
                                                                              withHomeDirectory:self.page.revision.contentDirectory];
      //  self.html5ElementViewController.managzineQuery = self.magazineViewController.downloadingQueue;
       [self.mainScrollView addSubview:self.html5ElementViewController.view];
        [self.mainScrollView setContentSize:[self.html5ElementViewController.view frame].size];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
