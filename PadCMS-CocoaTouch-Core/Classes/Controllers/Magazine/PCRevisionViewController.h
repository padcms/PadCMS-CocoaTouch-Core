//
//  PCMagazineViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCData.h"
#import "PCPageViewController.h"
#import "PCColumnViewController.h"
#import "PCEmailController.h"
#import "PCTwitterNewController.h"
#import "PCTwitterViewController.h"
#import "PCFacebookViewController.h"
#import "PCEmailController.h"
#import "PCMainViewController.h"
#import "PCVideoController.h"
#import "PCGalleryViewController.h"
#import "PCLandscapeViewController.h"
#import "PCHelpViewController.h"
#import "PCSearchViewController.h"

/**
 @class PCMagazineViewController
 @brief Magazine View Controller
 */

@class PCRevision;
@class PCLandscapeViewController;
@class PCPageViewController;
@class PCColumnViewController;
@class PCFacebookViewController;
@class PCMainViewController;
@class PCScrollView;

@interface PCRevisionViewController : UIViewController <UIScrollViewDelegate, PCEmailControllerDelegate, PCTwitterNewControllerDelegate, PCVideoControllerDelegate, PCHelpViewControllerDelegate, UIGestureRecognizerDelegate, PCSearchViewControllerDelegate>

{
    IBOutlet PCScrollView* mainScrollView;
    NSMutableArray* columnsViewControllers;
    PCScrollView* tableOfContentsView;
    UIButton* tableOfContentButton;
    UITapGestureRecognizer* tapGestureRecognizer;
    UITapGestureRecognizer* horizontalTapGestureRecognizer;
    IBOutlet UIView* topMenuView;
    IBOutlet UIView* horizontalTopMenuView;
    IBOutlet UIView* topSummaryView;
    PCScrollView* horizontalSummaryView;
    IBOutlet PCScrollView* topSummaryScrollView;
    PCFacebookViewController* facebookViewController;
    PCTwitterViewController* twitterViewController;
    PCEmailController* emailController;
    PCVideoController* _videoController;
    PCHelpViewController* helpController;
    PCSearchViewController* searchController;
    PCGalleryViewController* galleryViewController;
    UIView* shareMenu;
    
    PCScrollView* horizontalScrollView;
    NSMutableArray* horizontalPagesViewControllers;
    
    PCLandscapeViewController* horizontalPagesViewController;
    UIDeviceOrientation currentMagazineOrientation;
}

@property (nonatomic, retain) PCRevision* revision;///< Mgazine data model
@property (nonatomic, assign) NSInteger initialPageIndex;
@property (nonatomic, assign) PCMainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet PCScrollView* mainScrollView;
@property (nonatomic, retain) IBOutlet PCLandscapeViewController* horizontalPagesViewController;
@property (nonatomic, retain) IBOutlet UIView* topSummaryView;
@property (retain, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet UIButton *horizontalHelpButton;
@property (nonatomic, retain) IBOutlet UIButton *topSummaryButton;
@property (nonatomic, retain) PCScrollView* horizontalSummaryView;

/**
 @brief Show concrete page
 @param page - page data model
 */
-(PCPageViewController*)showPage:(PCPage*)page;

/**
 @brief Show concrete page with index
 @param pageIndex - index of page in magazine pages array
 */
-(void)showPageWithIndex:(NSInteger) pageIndex;

/**
 @brief Show concrete column
 @param column - column data model
 */
-(PCColumnViewController*)showColumn:(PCColumn*)column;

/**
 @brief Show column at index
 @param columnIndex - column index
 */
-(PCColumnViewController*)showColumnAtIndex:(NSInteger)columnIndex;

/**
 @brief Return current column
 */
- (PCColumnViewController*) currentColumnViewController;

/**
 @brief Show next column
 */
-(BOOL)showNextColumn;

/**
 @brief Show prev column
 */
-(BOOL)showPrevColumn;


/**
 @brief Home button Action. Show column with 0 index.
 */
-(IBAction)homeAction:(id)sender;

/**
 @brief Show table of content
 */
-(IBAction)showTOCAction:(id)sender;

/**
 @brief Show help
 */
-(IBAction)helpAction:(id)sender;

/**
 @brief Show share menu 
 */
-(IBAction)shareAction:(id)sender;

/**
 @brief Tap action callback
 */
-(void)tapAction:(UIGestureRecognizer*)sender;

@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
- (IBAction)searchTextDidEndOnExit:(id)sender;
- (void) showGalleryViewController:(PCGalleryViewController*)galleryViewController;
- (void) dismissGalleryViewController;
- (IBAction)showTopSummary:(id)sender;
- (void) updateViewsForCurrentIndex;
- (void)clearMemory;

@end
