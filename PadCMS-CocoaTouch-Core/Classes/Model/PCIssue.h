//
//  PCMagazine.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
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
 */ 
- (id)initWithParameters:(NSDictionary *)parameters rootDirectory:(NSString *)rootDirectory;

@end
