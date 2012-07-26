//
//  PCKioskBaseControlElement.h
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
    UIButton                *previewButton; ///< button for previewing revision
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
