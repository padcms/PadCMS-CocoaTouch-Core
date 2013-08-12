//
//  PCMagazine.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
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
#import "TBXML.h"
#import "PCPage.h"

@class PCApplication;
@class PCRevision;

typedef enum
{
    PCIssueUnknownSubscriptionType = 0, /**< Unknow Subscription Type */
    PCIssueSubscriptionAutoRenewable = 1, /**< Auto-Renewable Subscription Type */  
} PCIssueSubscriptionType; ///< The enumeration of magazine subscription type

/**
 @class PCIssue
 @brief This class represents issue's model. Keeps issue information and revisions list.
 */

@interface PCIssue : NSObject

@property (nonatomic, assign) PCApplication *application;

/**
 @brief Current published revision
 */ 
//@property (readonly) PCRevision *currentRevision;

/**
 @brief back end server URL
 */
@property (retain, nonatomic) NSURL *backEndURL;

/**
 @brief Directory where PCIssue instances stores data
 */ 
@property (readonly) NSString *contentDirectory;

/**
 @brief List of revisions
 */ 
@property (nonatomic, retain) NSMutableArray *revisions;

/**
 @brief Issue subscription type
 */ 
@property (nonatomic, assign) PCIssueSubscriptionType subscriptionType;

/**
 @brief Is issue paid
 */ 
@property (nonatomic, assign, getter = isPaid) BOOL paid;

/**
 @brief Magazine identifier
 */ 
@property (nonatomic, assign) NSInteger identifier;

/**
 @brief Magazine title
 */ 
@property (nonatomic, retain) NSString *title;

/**
 @brief Magazine number
 */ 
@property (nonatomic, retain) NSString *number;

/**
 @brief Product identifier
 */ 
@property (nonatomic, retain) NSString *productIdentifier;

/**
 @brief Basic magazine color
 */ 
//@property (nonatomic, retain) UIColor *color;

/**
 @brief Path to the thumbnail of the magazine cover page
 */ 
@property (nonatomic, retain) NSString *coverImageThumbnailURL;

/**
 @brief Path to the image list of the magazine main page
 */ 
@property (nonatomic, retain) NSString *coverImageListURL;

/**
 @brief Path to the image of the magazine main page
 */ 
@property (nonatomic, retain) NSString *coverImageURL;

/**
 @brief Magazine updated date
 */ 
@property (nonatomic, retain) NSDate *updatedDate;

@property (nonatomic, copy) NSString* price;

/**
 @brief Support for the horizontal mode flag
 */ 
//@property (nonatomic, assign) BOOL horizontalMode;

/**
 @brief Designated initializer.
 @param Dictionary with parameters to initialize instance
 @param Root directory for content
 @param Back end server URL
 */ 
- (id)initWithParameters:(NSDictionary *)parameters 
           rootDirectory:(NSString *)rootDirectory 
              backEndURL:(NSURL *)backEndURL;

/**
 @brief Designated initializer.
 @param Dictionary with parameters to initialize instance
 @param Root directory for content
 */ 
- (id)initWithParameters:(NSDictionary *)parameters 
           rootDirectory:(NSString *)rootDirectory;

@end
