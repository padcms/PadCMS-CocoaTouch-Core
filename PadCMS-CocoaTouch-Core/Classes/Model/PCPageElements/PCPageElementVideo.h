//
//  PCPageElementVidio.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

/**
 @class PCPageElementVideo
 @brief Represents Video element of the page.
 */

@interface PCPageElementVideo : PCPageElement
{
    NSString* stream;
}

@property (nonatomic,retain) NSString* stream; ///< String with URL to the video stream

@end
