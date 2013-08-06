//
//  PCFixedIllustrationArticleViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 10.02.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
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
