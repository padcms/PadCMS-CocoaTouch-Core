//
//  PCFixedIllustrationArticleTouchablePageViewController.m
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
