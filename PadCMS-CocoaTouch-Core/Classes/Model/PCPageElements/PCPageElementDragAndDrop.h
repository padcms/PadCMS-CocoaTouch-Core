//
//  PCPageElementDragAndDrop.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

/**
 @class PCPageElementDragAndDrop
 @brief Represents drag and drop element of the page.
 */

@interface PCPageElementDragAndDrop : PCPageElement
{
    NSString* video;
    NSString* thumbnail;
    NSString* thumbnailSelected;
    NSInteger topArea;
}

@property (nonatomic,retain) NSString* video; ///< Relative path to the video
@property (nonatomic,retain) NSString* thumbnail; ///< Relative path to the thumbnail
@property (nonatomic,retain) NSString* thumbnailSelected; ///< Relative path to the thumbnail selected
@property (nonatomic,assign) NSInteger topArea; ///< A top area (in pixel) where there is no mini-articles

@end
