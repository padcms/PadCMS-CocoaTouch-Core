//
//  PCKioskBaseControlElement.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCKioskAbstractControlElement.h"
#import "PCKioskDataSourceProtocol.h"
#import "PCKioskSubviewDelegateProtocol.h"
#import "PCKioskCoverImageProcessingProtocol.h"
#import "PDColoredProgressView.h"

/**
 @class PCKioskBaseControlElement
 @brief Base class for kiosk subview's control element
 */
@interface PCKioskBaseControlElement : PCKioskAbstractControlElement <PCKioskCoverImageProcessingProtocol>
{
    UIImageView             *revisionCoverView;

    UILabel                 *issueTitleLabel;
    UILabel                 *revisionTitleLabel;
    UILabel                 *revisionStateLabel; ///< revision state
    
    UIButton                *downloadButton; ///< button for download revision
    UIButton                *cancelButton; ///< button for cancel downloading
    UIButton                *readButton; ///< button for reading revision
    UIButton                *deleteButton; ///< button for deleting revision content
    
    PDColoredProgressView   *downloadingProgressView; ///< show downloading progress
    UILabel                 *downloadingInfoLabel;  ///< show downloading percent and remaining time (optional)
}

/**
 @brief Init revision cover
 */
- (void) initCover;

/**
 @brief Init revision and issue title labels
 */
- (void) initLabels;

/**
 @brief Init buttons
 */
- (void) initButtons;

/**
 @brief Assign tapping handlers fo buttons
 */
- (void) assignButtonsHandlers;

/**
 @brief Change element view according to revision state (downloaded, upon downloading, not downloaded)
 */
- (void) adjustElements;

/**
 @brief Init download progress indicator and label for show percents
 */
- (void) initDownloadingProgressComponents;

@end
