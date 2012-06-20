//
//  PCKioskSubview.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
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

#import <UIKit/UIKit.h>
#import "PCKioskDataSourceProtocol.h"
#import "PCKioskSubviewDelegateProtocol.h"

/**
 @class PCKioskSubview
 @brief This is base class for kiosk subviews. PCKioskViewController switches between them
 */
@interface PCKioskSubview : UIView

/**
 @brief Data source that provide information about revisions
 */ 
@property (retain, nonatomic) id<PCKioskDataSourceProtocol> dataSource;

/**
 @brief Delegate for interacting with PCKioskViewController instance
 */ 
@property (retain, nonatomic) id<PCKioskSubviewDelegateProtocol> delegate;

/**
 @brief Indicate is revision downloaded now
 */ 
@property (assign, nonatomic) BOOL downloadInProgress;

/**
 @brief Index of revision that downloaded
 */ 
@property (assign, nonatomic) NSInteger downloadingRevisionIndex;



/**
 @brief Return unique subview tag, that used for identification subview for switch on it
 */ 
+ (NSInteger) subviewTag;

/**
 @brief Create and init subview elements
 */ 
- (void) createView;

/**
 @brief Visually select subview element that represents appropriate revision
 
 @param revision index
 */ 
- (void) selectRevisionWithIndex:(NSInteger)index;

/**
 @brief Update subview element that represents appropriate revision
 
 @param revision index
 */ 
- (void) updateRevisionWithIndex:(NSInteger)index;

/**
 @brief Delete all subview elements that represents all revisions, and create again. Used in case when number of revisions in dataSource is changed
 */ 
- (void) reloadRevisions;

/**
 @brief Notify subview element that represents appropriate revision about revision download starting
 
 @param  revision index
 */ 
- (void) downloadStartedWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subview element that represents appropriate revision about revision downloading progress update
 
 @param index - revision index
 @param progress - downloading progress in range 0.0-1.0
 @param time - downloading remaining time
 */ 
- (void) downloadProgressUpdatedWithRevisionIndex:(NSInteger)index andProgress:(float)progress andRemainingTime:(NSString *)time;

/**
 @brief Notify subview element that represents appropriate revision about finish of revision downloading
 
 @param revision index
 */ 
- (void) downloadFinishedWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subview element that represents appropriate revision about revision downloading failing
 
 @param  revision index
 */ 
- (void) downloadFailedWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subview element that represents appropriate revision about revision downloading canceled
 
 @param  revision index
 */ 
- (void) downloadCanceledWithRevisionIndex:(NSInteger)index;

/**
 @brief Notify subview that device orientation is changed
 */ 
- (void) deviceOrientationDidChange;

@end
