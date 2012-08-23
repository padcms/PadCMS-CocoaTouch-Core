//
//  PCHudController.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 8/21/12.
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

#import "PCHudView.h"
#import "PCTopBarView.h"

@class PCRevision;
@class PCTocItem;
@class PCTopBarView;
@class PCHudController;

/**
 @protocol RRHudControllerDelegate.
 @brief Methods of the RRHudControllerDelegate protocol allow the delegate to perform actions related to HUD UI.
 */
@protocol RRHudControllerDelegate <NSObject>

@optional
/**
 @brief Tells the delegate to dismiss all popups windows that are currently presented.
 @param The PCHudController object informing the delegate of this event.
 */
- (void)hudControllerDismissAllPopups:(PCHudController *)hudController;

@optional
/**
 @brief Tells the delegate that the user selected toc item in the toc or summary.
 @param The PCHudController object informing the delegate of this event.
 @param The PCTocItem object that the user selected.
 */
- (void)hudController:(PCHudController *)hudController selectedTocItem:(PCTocItem *)tocItem;

@optional
/**
 @brief Tells the controller that the user tapped the button in the top bar view.
 @param The PCHudController object informing the delegate of this event.
 @param The PCTopBarView object that contains button that was tapped.
 @param The button that was tapped.
 */
- (void)hudController:(PCHudController *)hudController
           topBarView:(PCTopBarView *)topBarView
         buttonTapped:(UIButton *)button;

@optional
/**
 @brief Tells the delegate that the user begins search with corresponding search text pattern.
 @param The PCHudController object informing the delegate of this event.
 @param The PCTopBarView object that contains button that was tapped.
 @param The search text patter to be used for search.
 */
- (void)hudController:(PCHudController *)hudController
           topBarView:(PCTopBarView *)topBarView
           searchText:(NSString *)searchText;

@end


/**
 @class PCHudController.
 @brief The PCHudController object manages HUD UI elements: top bar, table of contens, summary.
 */
@interface PCHudController : NSObject <PCHudViewDataSource, PCHudViewDelegate, PCTopBarViewDelegate>

/**
 @brief The object that acts as the delegate of the receiving HUD controller.
 */
@property (assign) id<RRHudControllerDelegate> delegate;

/**
 @brief PCRevision object that will be used as the data model.
 */
@property (retain, nonatomic) PCRevision *revision;

/**
 @brief Flag indicating that the UI should be presented in special preview mode.
 */
@property (assign) BOOL previewMode;

/**
 @brief PCHudView object that represents HUD UI.
 */
@property (readonly, nonatomic) PCHudView *hudView;


/**
 @brief Updates the receiver state.
 */
- (void)update;

/**
 @brief Handles tap action in the background view.
 */
- (void)tap;

@end
