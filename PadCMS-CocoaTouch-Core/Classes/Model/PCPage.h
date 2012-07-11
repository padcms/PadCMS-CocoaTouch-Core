//
//  PCPage.h
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
	BOOL _isSecondaryElementComplete;
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

@property (assign) BOOL isHorizontal;

@property (nonatomic, readonly) PCPage* rightPage;

@property (nonatomic, readonly) PCPage* leftPage;

@property (nonatomic, readonly) PCPage* bottomPage;

@property (nonatomic, readonly) PCPage* topPage;

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

-(BOOL)isSecondaryElementsComplete;

@end
