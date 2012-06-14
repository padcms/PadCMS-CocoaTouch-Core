//
//  PCPageElementSlide.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

/**
 @class PCPageElementSlide
 @brief Represents Slide element of the page.
 */

@interface PCPageElementSlide : PCPageElement
{
    NSString* video;
}

@property (nonatomic,retain) NSString* video; ///< Relative path to the video

@end
