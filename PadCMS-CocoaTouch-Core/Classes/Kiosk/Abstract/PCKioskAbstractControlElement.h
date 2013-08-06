//
//  PCKioskAbstractControlElement.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
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
