//
//  PCPage.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

#import "PCPageTemplate.h"
#import "PCPageElement.h"
#import "PCRevision.h"

@class PCIssue,PCColumn,PCPageElement;

PADCMS_EXTERN NSString* endOfDownloadingPageNotification;

PADCMS_EXTERN NSString* const PCBoostPageNotification;

@class PCMagazine,PCColumn,PCPageElement;
@protocol PCDownloadProgressProtocol;
/**
 @class PCPage
 @brief Represents page model. PCPageViewController and its children use it to build page view. 
 */

@interface PCPage : NSObject
{
    PCColumn* column;
    NSInteger identifier;
    NSString* title;
    PCPageTemplate* pageTemplate;
    NSString* machineName;
    NSInteger horisontalPageIdentifier;
    NSMutableArray* elements;
    NSMutableDictionary* links;
    UIColor* color;
}

/**
 @brief The magezine this page belongs to
 */ 
@property (nonatomic,assign) PCRevision* revision; 

/**
 @brief The column this page belongs to
 */ 
@property (nonatomic,assign) PCColumn* column; 

/**
 @brief Page identifier
 */ 
@property (nonatomic,assign) NSInteger identifier; 

/**
 @brief Title
 */ 
@property (nonatomic,retain) NSString* title;

/**
 @brief Template
 */ 
@property (nonatomic,retain) PCPageTemplate* pageTemplate;

/**
 @brief Machine Name
 */ 
@property (nonatomic,retain) NSString* machineName;

/**
 @brief An identifier of horizontal page that linked with current
 */ 
@property (nonatomic,assign) NSInteger horisontalPageIdentifier;

/**
 @brief Elements
 */ 
@property (nonatomic,retain) NSMutableArray* elements;

/**
 @brief Dictionary where key is NSNumber with PCPageTemplateConnectorOptions, and value is NSNumber with page identifier.
 */ 

@property (nonatomic,retain) NSMutableDictionary* links;

@property (nonatomic, assign) id<PCDownloadProgressProtocol> progressDelegate;

/**
 @brief Page basic color.
 */ 
@property (nonatomic,retain) UIColor* color;

@property (nonatomic,assign) BOOL isComplete;

@property (nonatomic,assign) float primaryProgress;

@property (nonatomic, readonly) NSArray* primaryElements;

@property (nonatomic, readonly) NSArray* secondaryElements;

@property (assign) NSTimer *repeatingTimer;

@property (assign) BOOL isUpdateProgress;

- (id)init;

/**
 @brief Returns link to the page. 
 
 @param aConnector defines the type of the link
 */ 
- (id)linkForConnector:(PCPageTemplateConnectorOptions)aConnector;

/**
 @brief Returns array of specified type elements.
 
 @param elementType - element Type. Standart element types declared in PCPageElemetTypes.h;
 */ 
- (NSArray*)elementsForType:(NSString*)elementType;

/**
 @brief Returns first found element with specific type, if not found returns nil
 
 @param elementType - element Type. Standart element types declared in PCPageElemetTypes.h;
 */
- (PCPageElement*)firstElementForType:(NSString*)elementType;

- (void)startRepeatingTimer;

- (void)stopRepeatingTimer;

- (BOOL)hasPageActiveZonesOfType: (NSString*)zoneType;


@end
