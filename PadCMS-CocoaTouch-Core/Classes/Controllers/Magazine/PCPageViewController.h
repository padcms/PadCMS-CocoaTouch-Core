//
//  PCPageViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
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

#import <Foundation/Foundation.h>
#import "PCData.h"
#import "PCRevisionViewController.h"
#import "PCColumnViewController.h"
#import "PCPageElementViewController.h"
#import "PCVideoController.h"
#import "PCGalleryViewController.h"

@class PCRevisionViewController;
@class PCColumnViewController;
@class MBProgressHUD;
@class PCScrollView;

/**
 @class PCPageViewController
 @brief Page View Controller
 */

@interface PCPageViewController : UIViewController <UIGestureRecognizerDelegate, PCGalleryViewControllerDelegate>
{
    PCPage* page;
    PCPageElementViewController* backgroundViewController;
    PCScrollView* mainScrollView;
    PCPageElementViewController* bodyViewController;
    UIButton* galleryButton;
    UIButton* videoButton;
    PCRevisionViewController* magazineViewController;
    PCColumnViewController* columnViewController;
    PCGalleryViewController* galleryViewController;
    UITapGestureRecognizer* tapGestureRecognizer;
    BOOL isVisible;
    MBProgressHUD *HUD;
	BOOL isLoaded;
	UIWebView *videoWebView;
}

@property (nonatomic,assign) PCRevisionViewController* magazineViewController;///< Main magazine view controller 
@property (nonatomic,assign) PCColumnViewController* columnViewController;///< Main column view controller

@property (nonatomic,retain) PCPage* page;///< Page data model
@property (nonatomic,retain) PCPageElementViewController* backgroundViewController;///< Background view
@property (nonatomic,retain) PCScrollView* mainScrollView;///<  Main scroll view
@property (nonatomic,retain) PCPageElementViewController* bodyViewController;///< Body view 
@property (nonatomic,retain) UIButton* galleryButton;///< Gallery button
@property (nonatomic,retain) UIButton* videoButton;///< Video button
@property (nonatomic,retain) PCGalleryViewController* galleryViewController;
@property (nonatomic,assign) BOOL isVisible;
@property (nonatomic,retain) UIWebView *videoWebView;

/**
 @brief Initiolize page view controller with Page
 @param page - page data model
 */
- (id)initWithPage:(PCPage *)page;

/**
 @brief Return active zone rect for zone type 
 @param zoneType - active zone type
 */
- (CGRect)activeZoneRectForType:(NSString*)zoneType;

//- (CGRect) getActiveZoneRectFor:(PCPageElement *) pageElement type:(NSString*)zoneType viewController:(UIViewController*) viewController;

- (BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone;
- (NSArray*) activeZonesAtPoint:(CGPoint)point;

- (void) loadFullView;
- (void) unloadFullView;
- (void) showVideo:(NSString *)resourcePath;
- (void) showHUD;
- (void) changeVideoLayout: (BOOL)isVideoEnabled;

- (void) tapAction:(UIGestureRecognizer *)gestureRecognizer;


@end
