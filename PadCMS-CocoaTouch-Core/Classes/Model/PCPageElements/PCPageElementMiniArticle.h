//
//  PCPageElementMiniArticle.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

/**
 @class PCPageElementMiniArticle
 @brief Represents Mini Article element of the page.
 */

PADCMS_EXTERN NSString * const PCMiniArticleElementDidDownloadNotification;

@interface PCPageElementMiniArticle : PCPageElement
{
    NSString* video;
    NSString* thumbnail;
    NSString* thumbnailSelected;
}

@property (nonatomic,retain) NSString* video; ///< Relative path to the video
@property (nonatomic,retain) NSString* thumbnail; ///< Relative path to the thumbnail
@property (nonatomic,retain) NSString* thumbnailSelected; ///< Relative path to the thumbnail selected
@property (nonatomic,assign) float thumbnailProgress;
@property (nonatomic,assign) float thumbnailSelectedProgress;

@end
