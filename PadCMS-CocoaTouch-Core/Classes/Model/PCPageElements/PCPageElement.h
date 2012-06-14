//
//  PCPageElement.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCSQLiteKeys.h"

PADCMS_EXTERN NSString * const PCGalleryElementDidDownloadNotification;

/**
 @class PCPageElement
 @brief Represents basic model of page elements, all custom models are inherited from it. Each page can have several elements.
 */
@protocol PCDownloadProgressProtocol;
@class PCPage;
@interface PCPageElement : NSObject
{
    NSInteger identifier;		
    NSString* fieldTypeName;
    NSInteger weight;
    NSString* resource;
    NSString* contentText;
    NSDictionary* dataRects;
    CGSize size;
    NSMutableArray* activeZones;
}

@property (nonatomic,assign) NSInteger identifier; ///< Element identifier
@property (nonatomic,retain) NSString* fieldTypeName; ///< Element type
@property (nonatomic,retain) NSString* resource; ///< Relative path to the resource
@property (nonatomic,assign) NSInteger weight; ///< Order(priority) on the page
@property (nonatomic,retain) NSString* contentText; ///< Page content text
@property (nonatomic,retain) NSDictionary* dataRects; ///< Dictionary where key is a string defining area type, and value has a string built from CGRect with using NSStringFromCGRect function. For reverse conversion string to CGRect you should use CGRectFromString.
@property (nonatomic,assign) CGSize size; ///< Element size
@property (nonatomic,retain) NSMutableArray* activeZones; ///< Element Active Zones
@property (nonatomic,assign) BOOL isComplete;
@property (nonatomic,assign) float downloadProgress;
@property (nonatomic, assign) id<PCDownloadProgressProtocol> progressDelegate;
@property (nonatomic, assign) PCPage* page;

- (id)init;
/**
@brief Used to assign element properties. Can be overloaded with child of PCPageElement class that have additional property. With magazine initialization Model Builder receives PCPageElementManager class of the required elements by its type, then he creates its instance and passes attributes to pushElementData: method. 
@param data - NSDictionary with custom element attributes 
*/
- (void)pushElementData:(NSDictionary*)data;

/**
 @brief Returns CGRect for specific type of elements 
 @param elementType - specific type of element
 */
- (CGRect)rectForElementType:(NSString*)elementType;

@end
