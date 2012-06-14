//
//  PCPageElementBody.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

/**
 @class PCPageElementBody
 @brief Represents Body element of the page.
 */

@interface PCPageElementBody : PCPageElement
{
    BOOL hasPhotoGalleryLink;
    BOOL showTopLayer;
    NSInteger top;
}

@property (nonatomic,assign) BOOL hasPhotoGalleryLink; ///< If YES means that body template have a link to launch photo gallery, and there is no need to show the default one. If NO, the default one will be shown.
@property (nonatomic,assign) BOOL showTopLayer; ///< Do we have to show scroller
@property (nonatomic,assign) NSInteger top; ///< Says where the body content should be positioned from the top of the screen

@end
