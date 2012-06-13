//
//  PCKioskAbstractControlElement.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCKioskDataSourceProtocol.h"
#import "PCKioskSubviewDelegateProtocol.h"

/**
 @class PCKioskAbstractControlElement
 @brief Abstract class for representing kiosk subview element for appropriate revision, and controlling revision life cycle
 */
@interface PCKioskAbstractControlElement : UIView

/**
 @brief Revision index
 */
@property (assign, nonatomic) NSInteger revisionIndex;

/**
 @brief Data source that provide information about revisions
 */
@property (retain, nonatomic) id<PCKioskDataSourceProtocol> dataSource;

/**
 @brief Delegate for interacting with kiosk subview that owned this element
 */
@property (retain, nonatomic) id<PCKioskSubviewDelegateProtocol> delegate;

/**
 @brief Indicate is appropriate revision downloaded now
 */
@property (assign, nonatomic) BOOL downloadInProgress;



/**
 @brief Create and init element (subviews, buttons, etc.)
 */ 
- (void) load;

/**
 @brief Notify that revision download started
 */
- (void) downloadStarted;

/**
 @brief Notify that revision download progress changed
 
 @param progress - downloading progress in range 0.0-1.0
 @param time - downloading remaining time
 */
- (void) downloadProgressUpdatedWithProgress:(float)progress andRemainingTime:(NSString *)time;

/**
 @brief Notify that revision download finished
 */
- (void) downloadFinished;

/**
 @brief Notify that revision download failed
 */
- (void) downloadFailed;

/**
 @brief Notify that revision download canceled
 */
- (void) downloadCanceled;

/**
 @brief Update revision info from dataSource
 */
- (void) update;

@end
