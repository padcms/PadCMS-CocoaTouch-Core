//
//  PCTemplatesPool.h
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
