//
//  PCPageElement.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"
/**
 @class PCPageElementAdvert
 @brief Represents Advert element of the page.
 */

@interface PCPageElementAdvert : PCPageElement
{
    NSUInteger advertDuration;
}

@property (nonatomic,assign) NSUInteger advertDuration; ///< Advert duration time in seconds

@end
