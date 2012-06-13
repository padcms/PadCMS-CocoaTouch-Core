//
//  PCKioskViewController.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCKioskAbstractSubviewsFactory.h"
#import "PCKioskDataSourceProtocol.h"
#import "PCKioskSubviewDelegateProtocol.h"
#import "PCKioskViewControllerDelegateProtocol.h"

/**
 @class PCKioskViewController
 @brief This class show and manage multiple kiosk subviews by switching from one to another
 */
@interface PCKioskViewController : UIViewController <PCKioskSubviewDelegateProtocol>
{
    NSInteger       _currentSubviewIndex; ///< index of currently shown subview in kioskSubviews array
    CGRect          _initialFrame; ///< frame for show subviews
}

/**
 @brief Aray of subview
 */
@property (retain, nonatomic) NSArray *kioskSubviews;

/**
 @brief Factory that provide list of subviews
 */
@property (retain, nonatomic) PCKioskAbstractSubviewsFactory *subviewsFactory;

/**
 @brief Data source that provide information about revisions
 */
@property (assign) id<PCKioskDataSourceProtocol> dataSource;

/**
 @brief Delegate that implement revision downloading, deleting, reading, etc.
 */
@property (assign) id<PCKioskViewControllerDelegateProtocol> delegate;

/**
 @brief Indicate is revision downloaded now
 */
@property (assign, nonatomic) BOOL downloadInProgress;

/**
 @brief Index of revision that downloaded
 */
@property (assign, nonatomic) NSInteger downloadingRevisionIndex;



/**
 @brief Init view controller
 
 @param factory - Factory that provide list of subviews
 @param frame - visible frame for subviews
 @param dsource - Data source that provide information about revisions
 */
- (id) initWithKioskSubviewsFactory:(PCKioskAbstractSubviewsFactory*)factory
                           andFrame:(CGRect) frame
                      andDataSource:(id<PCKioskDataSourceProtocol>) dsource;

/**
 @brief Retrurns tag of the current subview
 */
- (NSInteger) currentSubviewTag;

/**
 @brief Switch to next subview in list
 */
- (void) switchToNextSubview;

/**
 @brief Switch to previous subview in list
 */
- (void) switchToPreviousSubview;

/**
 @brief Switch to specified subview
 
 @param subview tag
 */
- (BOOL) switchToSubviewWithTag:(NSInteger) tag;

/**
 @brief Reload all subviews, for reloading its content. Used in case when number of revisions in dataSource is changed
 */
- (void) reloadSubviews;

/**
 @brief Notify all subviews that device orientation changed
 */
-(void)deviceOrientationDidChange;

/**
 @brief Update subviews control elements that represents appropriate revision
 
 @param Revision index
 */
- (void) updateRevisionWithIndex:(NSInteger)index;

/**
 @brief Notify subviews that revision downloading starting
 
 @param Revision index
 */
- (void) downloadStartedWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subviews that downloading of revision is finished
 
 @param Revision index
 */
- (void) downloadFinishedWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subviews that downloading of revision is failed
 
 @param Revision index
 */
- (void) downloadFailedWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subviews that downloading of revision is canceled
 
 @param Revision index
 */
- (void) downloadCanceledWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subviews that progress of downloading revision is changed
 
 @param index -  Revision index
 @param progress - downloading progress in range 0.0-1.0
 */
- (void) downloadingProgressChangedWithRevisionIndex:(NSInteger)index andProgess:(float) progress;

@end
