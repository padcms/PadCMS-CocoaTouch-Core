//
//  PCPageViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
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

- (void) loadFullView;
- (void) unloadFullView;
- (void) showVideo:(NSString *)resourcePath;
- (void) showHUD;

- (void) tapAction:(UIGestureRecognizer *)gestureRecognizer;


@end
