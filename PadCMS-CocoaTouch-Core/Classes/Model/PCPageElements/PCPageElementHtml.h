//
//  PCPageElementHtml.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

typedef enum _PCPageElementHtmlType
{
    PCPageElementHtmlUnknowType     = 0, ///< Unknow Type 
    PCPageElementHtmlTouchType      = 1, ///< Displays HTML page when user touches the display
    PCPageElementHtmlRotationType   = 2 ///< Displays HTML page when user rotate device
} PCPageElementHtmlType; ///< Displays HTML Type

/**
 @class PCPageElementHtml
 @brief Represents Html element of the page.
 */

@interface PCPageElementHtml : PCPageElement
{
    NSString* htmlUrl;
    PCPageElementHtmlType templateType;
}

@property (nonatomic,retain) NSString* htmlUrl; ///< page's URL
@property (nonatomic,assign) PCPageElementHtmlType templateType; ///< Displays HTML page when user rotate device (if templateType = PCPageElementHtmlRotationType) or user touches the display (if templateType = PCPageElementHtmlTouchType )

@end
