//
//  PCTemplatesPool.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCPageTemplate.h"

typedef enum _PCPageTemplateType 
{
    PCBasicArticlePageTemplate                          = 1,  ///< Basic Article Page Template
    PCArticleWithFixedIllustrationPageTemplate          = 2,  ///< Article With Fixed Illustration Page Template
    PCSimplePageTemplate                                = 3,  ///< Simple Page Template
    PCScrollingPageTemplate                             = 4,  ///< Scrolling Page Template
    PCSlidersBasedMiniArticlesHorizontalPageTemplate    = 5,  ///< Sliders Based Mini Articles Horizontal Page Template
    PCSlideshowPageTemplate                             = 6,  ///< Slideshow Page Template
    PCCoverPageTemplate                                 = 7,  ///< Cover Page Template
    PCSlidersBasedMiniArticlesVerticalPageTemplate      = 8,  ///< Sliders Based Mini Articles Vertical Page Template
    PCArticleWithOverlayPageTemplate                    = 9,  ///< Article With Overlay Page Template
    PCFixedIllustrationArticleTouchablePageTemplate     = 10, ///< Fixed Illustration Article Touchable Page Template
    PCInteractiveBulletsPageTemplate                    = 11, ///< Interactive Bullets Page Template
    PCSlideshowLandscapePageTemplate                    = 12, ///< Slideshow Landscape Page Template
    PCSlidersBasedMiniArticlesTopPageTemplate           = 13, ///< Sliders Based Mini Articles Top Page Template
    PCHTMLPageTemplate                                  = 14, ///< HTML Page Template
    PCDragAndDropPageTemplate                           = 15, ///< Drag And Drop Page Template
    PCFlashBulletInteractivePageTemplate                = 16, ///< Flash Bullet Interactive Page Template
    PCGalleryFlashBulletInteractivePageTemplate         = 17, ///< Gallery Flash Bullet Interactive Page Template
    PCHtml5PageTemplate                                 = 18, ///< Html5 Page Template  
    PCHorizontalScrollingPageTemplate                   = 20,  ///< Horizontal scrolling Page Template
    PC3DPageTemplate                                    = 21  ///< 3D Page Template  
} PCPageTemplateType; ///< The enumeration of page template types

/**
 @class PCPageTemplatesPool
 @brief Represents a pool of PCPageTemplate objects.
 */

@interface PCPageTemplatesPool : NSObject
{
    NSMutableDictionary* templates;
}

/**
 @brief The magezine this page belongs to
 */ 
+ (PCPageTemplatesPool*)templatesPool;

/**
 @brief The magezine this page belongs to
 */ 
- (void)registerPageTemplate:(PCPageTemplate*)aPageTemplate;

/**
 @brief The magezine this page belongs to
 */ 
- (PCPageTemplate*)templateForId:(NSInteger)identifier;

@end
