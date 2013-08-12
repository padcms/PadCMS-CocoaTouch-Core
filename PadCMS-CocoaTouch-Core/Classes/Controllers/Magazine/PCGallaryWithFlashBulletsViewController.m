//
//  PCGallaryWithFlashBullets.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.03.12.
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

#import "PCGallaryWithFlashBulletsViewController.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"
#import "PCFlashButton.h"
#import "PCRevision.h"
#import "PCScrollView.h"

@implementation PCGallaryWithFlashBulletsViewController

-(void)dealloc
{
    [popapCopntrollers release];
    popapCopntrollers = nil;
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:(PCPage *)aPage])
    {
        popapCopntrollers = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* popaps = [page elementsForType:PCPageElementTypePopup];
    
    for (PCPageElement* popapElement in popaps)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:popapElement.resource];
        
        PCPageElementViewController* popapcontroller = [[[PCPageElementViewController alloc] initWithResource:fullResource] autorelease];
        [popapcontroller setTargetWidth:self.mainScrollView.bounds.size.width];
        
        [popapcontroller.view setHidden:YES];
        [self.mainScrollView addSubview:popapcontroller.view];
        [popapCopntrollers addObject:popapcontroller];
    }
    
    for (PCPageElement* element in [self.page elementsForType:PCPageElementTypeGallery])
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            NSLog(@"pdfActiveZone.URL=%@",pdfActiveZone.URL);
            if ([pdfActiveZone.URL hasPrefix:PCPDFActiveZonePopup])
            {
                
                NSArray* components = [pdfActiveZone.URL componentsSeparatedByString:PCPDFActiveZonePopup];
                NSUInteger index = 0;
                
                if ([components count] > 1)
                {
                    index = [[components objectAtIndex:1] intValue]-1;
                }

                
                PCFlashButton* popupButton = [PCFlashButton buttonWithType:UIButtonTypeCustom];
                [popupButton setTag:index];
                [popupButton addTarget:self action:@selector(popapAction:) forControlEvents:UIControlEventTouchUpInside];
                [[PCStyler defaultStyler] stylizeElement:popupButton withStyleName:PCFlashButtonKey withOptions:nil];
                
                CGRect rect = pdfActiveZone.rect;
                if (!CGRectEqualToRect(rect, CGRectZero))
                {
                    CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
                    float scale = pageSize.width/element.size.width;
                    rect.size.width *= scale;
                    rect.size.height *= scale;
                    rect.origin.x *= scale;
                    rect.origin.y *= scale;
                    rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
                }

                [popupButton setFrame:rect];
                //[self.mainScrollView addSubview:popupButton];
            }
        }
    }
}



- (void) loadFullView
{
    [super loadFullView];
    for (PCPageElementViewController* popapcontroller in popapCopntrollers)
        [popapcontroller loadFullViewImmediate];
}

- (void) unloadFullView
{
    [super unloadFullView];
    for (PCPageElementViewController* popapcontroller in popapCopntrollers)
        [popapcontroller unloadView];
}

-(void)popapAction:(id)sender
{
    NSUInteger index = [sender tag];
    if (index<[popapCopntrollers count])
    {
        for (unsigned i=0;i<[popapCopntrollers count];i++)
        {
            PCPageElementViewController* popapcontroller = [popapCopntrollers objectAtIndex:i];
            if (i!=index)
            {
                popapcontroller.view.hidden = YES;
            }
            else 
            {
                if (popapcontroller.view.hidden)
                {
                    popapcontroller.view.alpha = 0.0;
                    [UIView beginAnimations:nil context:NULL];
                    popapcontroller.view.hidden = NO;
                    [UIView setAnimationDuration:.5];
                    popapcontroller.view.alpha = 1.0;
                    [UIView commitAnimations];
                }
                else 
                {
                    popapcontroller.view.hidden = YES;
                }
            }
        }
    }
}

@end
