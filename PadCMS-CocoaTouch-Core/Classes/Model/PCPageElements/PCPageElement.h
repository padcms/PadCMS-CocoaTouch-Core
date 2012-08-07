//
//  PCPageElement.h
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
	CGSize realSize;
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
@property (nonatomic, assign) CGSize elementContentSize;
@property (nonatomic, assign) BOOL isCropped; 

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

- (NSString *)fullPathToContent;

- (CGSize)realImageSize;

- (NSUInteger)tileIndexForResource:(NSString*)resource;

- (NSString*)resourcePathForTileIndex:(NSUInteger)index;

@end
