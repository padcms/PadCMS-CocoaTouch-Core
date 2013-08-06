//
//  PCCoverPageViewControllerViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 27.03.12.
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
