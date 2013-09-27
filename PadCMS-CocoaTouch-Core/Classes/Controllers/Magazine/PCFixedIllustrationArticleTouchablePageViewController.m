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
#import "PCScrollView.h"
#import "PCGalleryWithOverlaysViewController.h"

@interface PCFixedIllustrationArticleTouchablePageViewController ()
- (void)deviceOrientationDidChange;
- (BOOL)isOrientationChanged:(UIDeviceOrientation)orientation;
- (void)showGallery;
- (void)hideGallery;
@end

@implementation PCFixedIllustrationArticleTouchablePageViewController

@synthesize galleryWithOverlaysViewController;

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
    
    PCPageElementBody* bodyElement = (PCPageElementBody*)[self.page firstElementForType:PCPageElementTypeBody];
    
    if(bodyElement)
    {
        [self.bodyViewController.view setHidden:!bodyElement.showTopLayer];
        [self changeVideoLayout:self.bodyViewController.view.hidden];
    }
    
    [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
    
    if (bodyElement && bodyElement.showGalleryOnRotate && [self.page elementsForType:PCPageElementTypeGallery].count > 0)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        currentMagazineOrientation = [[UIDevice currentDevice] orientation];
        if(currentMagazineOrientation==UIDeviceOrientationUnknown)
        {
            UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            if(UIInterfaceOrientationIsLandscape(currentOrientation))
            {
                currentMagazineOrientation = currentOrientation == UIInterfaceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
            } else
                if(UIInterfaceOrientationIsPortrait(currentOrientation))
                {
                    currentMagazineOrientation = currentOrientation == UIInterfaceOrientationPortrait ? UIDeviceOrientationPortrait : UIDeviceOrientationPortraitUpsideDown;
                } 
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        NSLog(@"registered");

        galleryWithOverlaysViewController = [[PCGalleryWithOverlaysViewController alloc] initWithPage:self.page];
    }
    galleryIsShowed = NO;
}

-(void)loadView
{
    [super loadView];
    /*PCPageElementBody* bodyElement = (PCPageElementBody*)[self.page firstElementForType:PCPageElementTypeBody];
    if(bodyElement)
        [self.bodyViewController.view setHidden:!bodyElement.showTopLayer];
    
    [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];*/
}

-(void)tapAction:(id)sender
{
    CGPoint tapLocation = [sender locationInView:[sender view]];
    
    BOOL firstCheck = (!self.bodyViewController.view.hidden&&
                       ((NSArray*)[super activeZonesAtPoint:tapLocation]).count == 0);
    
    BOOL secondCheck = (self.bodyViewController.view.hidden && ![self.page hasPageActiveZonesOfType:PCPDFActiveZoneActionButton]);
    
    [UIView transitionWithView: mainScrollView
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         
         if (firstCheck)
         {
             CGPoint tapLocationWithOffset;
             tapLocationWithOffset.x = self.articleView.contentOffset.x + tapLocation.x;
             tapLocationWithOffset.y = self.articleView.contentOffset.y + tapLocation.y;
             NSArray* actions = [self activeZonesAtPoint:tapLocationWithOffset];
             for (PCPageActiveZone* action in actions)
                 if ([self pdfActiveZoneAction:action])
                     break;
             if (actions.count == 0)
             {
                 self.bodyViewController.view.hidden = YES;
                 [self changeVideoLayout:self.bodyViewController.view.hidden];
             }
         }
         
         else if (secondCheck)
         {
             [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
             [self.bodyViewController.view setHidden:!self.bodyViewController.view.hidden];
             [self changeVideoLayout:self.bodyViewController.view.hidden];
         }
         
         
     } completion: ^(BOOL isFinished) {
         
     }];
    
    if (!firstCheck && ! secondCheck) {
        [super tapAction:sender];
    }
}

-(BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    [super pdfActiveZoneAction:activeZone];
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
    {
        [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
        [self.bodyViewController.view setHidden:!self.bodyViewController.view.hidden];
        [self changeVideoLayout:self.bodyViewController.view.hidden];
        return YES;
    }
    return NO;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - private

/*
- (void) showGalleryWithID:(NSInteger)ID initialPhotoID:(NSInteger)photoID
{
    if (galleryWithOverlaysViewController)
    {
        galleryWithOverlaysViewController.delegate = self;
        galleryWithOverlaysViewController.horizontalOrientation = self.magazineViewController.revision.horizontalOrientation;
        galleryWithOverlaysViewController.galleryID = ID;
        [self hideSubviews];
        [self.magazineViewController showGalleryViewController:galleryViewController];
        if (photoID > 0)
        {
            [galleryViewController setCurrentPhoto:photoID - 1];
            [galleryViewController showPhotoAtIndex:photoID - 1];
        }
    }
}
*/
-(void)showGallery
{
    if(!galleryIsShowed)
    {
        if ([self.magazineViewController.mainViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) 
        {
            [self.magazineViewController.mainViewController presentViewController:self.galleryWithOverlaysViewController animated:YES completion:nil];
            NSLog(@"Show overlayed gallery");
        } 
        else 
        {
            [self.magazineViewController.mainViewController presentModalViewController:self.galleryWithOverlaysViewController animated:YES];
        }
        galleryIsShowed = YES;
    }
}

-(void)hideGallery
{
    if (galleryIsShowed)
    {
        if ([self.magazineViewController.mainViewController.modalViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
        {
            [self.magazineViewController.mainViewController.modalViewController dismissViewControllerAnimated:YES completion:nil];
        } 
        else
        {
            [self.magazineViewController.mainViewController.modalViewController dismissModalViewControllerAnimated:YES];
        }
        galleryIsShowed = NO;
    }
}

-(void)deviceOrientationDidChange
{
    NSLog(@"Notification DEV");
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
        {
            if (self.columnViewController.currentPageViewController == self && self.columnViewController.magazineViewController.currentColumnViewController == self.columnViewController)
            {
                if (galleryIsShowed)
                {
                    [self hideGallery];
                }
                else
                {
                    [self showGallery];
                }
            }
        }
    }
    else if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
    {
        if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
        {
            if (self.columnViewController.currentPageViewController == self && self.columnViewController.magazineViewController.currentColumnViewController == self.columnViewController)
            {
                if (galleryIsShowed)
                {
                    [self hideGallery];
                }
                else
                {
                    [self showGallery];
                }
            }
        }
    }
}

- (BOOL)isOrientationChanged:(UIDeviceOrientation)orientation
{
    UIDeviceOrientation tempOrientation;
    tempOrientation = currentMagazineOrientation;
    
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsPortrait(tempOrientation));
    }
    else if (UIDeviceOrientationIsPortrait(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsLandscape(tempOrientation));
    }
    return NO;
}

@end
