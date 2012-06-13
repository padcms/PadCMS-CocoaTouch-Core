//
//  PCKioskSubview.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
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
