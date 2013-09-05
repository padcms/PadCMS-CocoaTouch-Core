//
//  PCMagazineViewController.h
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


#import "PCColumnViewController.h"
#import "PCData.h"
#import "PCEmailController.h"
#import "PCFacebookViewController.h"
#import "PCGalleryViewController.h"
#import "PCHelpViewController.h"
#import "PCLandscapeViewController.h"
#import "PCMainViewController.h"
#import "PCPageViewController.h"
#import "PCSearchViewController.h"
#import "PCTwitterNewController.h"
#import "PCVideoController.h"
#import <UIKit/UIKit.h>
#import "PCHudView.h"
#import "PCTopBarView.h"

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
@class PCSubscriptionsMenuView;
@protocol PCTopBarViewDelegate;

@interface PCRevisionViewController : UIViewController <UIScrollViewDelegate, PCEmailControllerDelegate, PCTwitterNewControllerDelegate, PCVideoControllerDelegate, PCHelpViewControllerDelegate, UIGestureRecognizerDelegate, PCSearchViewControllerDelegate, PCHudViewDataSource, PCHudViewDelegate, PCTopBarViewDelegate>

{
    IBOutlet PCScrollView* mainScrollView;
    NSMutableArray* columnsViewControllers;
    PCScrollView* tableOfContentsView;
    UIButton* tableOfContentButton;
    UITapGestureRecognizer* tapGestureRecognizer;
    UITapGestureRecognizer* horizontalTapGestureRecognizer;
//    IBOutlet UIView* topMenuView;
//    IBOutlet UIView* horizontalTopMenuView;
    IBOutlet UIView* topSummaryView;
    PCScrollView* horizontalSummaryView;
    IBOutlet PCScrollView* topSummaryScrollView;
    PCFacebookViewController* facebookViewController;
    PCEmailController* emailController;
    PCVideoController* _videoController;
    PCHelpViewController* helpController;
    PCSearchViewController* searchController;
    PCGalleryViewController* galleryViewController;
    UIView* shareMenu;
    PCSubscriptionsMenuView *subscriptionsMenu;
    
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
@property (nonatomic, retain) IBOutlet UIButton *subscriptionButton;
@property (assign) BOOL previewMode;

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
- (void)tapGesture:(UIGestureRecognizer *)recognizer;

@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
- (IBAction)searchTextDidEndOnExit:(id)sender;
- (void) showGalleryViewController:(PCGalleryViewController*)galleryViewController;
- (void) dismissGalleryViewController;
- (IBAction)showTopSummary:(id)sender;
- (void) updateViewsForCurrentIndex;
- (void)clearMemory;
- (IBAction)subscriptionsAction:(id)sender;

//for overriding
- (void)createHUDView;
- (void)destroyHUDView;

@end
