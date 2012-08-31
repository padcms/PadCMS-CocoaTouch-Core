//
//  PCPageTemplatesPool.m
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

#import "PCPageTemplatesPool.h"

@implementation PCPageTemplatesPool

+ (PCPageTemplatesPool*)templatesPool
{
    static PCPageTemplatesPool* templatesPool = nil;
    @synchronized(self)
    {
        if (templatesPool == nil)
        {
            templatesPool = [[PCPageTemplatesPool alloc] init];
        }
    }
    return templatesPool;
}

- (void)registerPageTemplate:(PCPageTemplate*)aPageTemplate
{
    [templates setObject:aPageTemplate forKey:[NSNumber numberWithInteger:aPageTemplate.identifier]];
}

- (void)initializeDefaultTemplates
{
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCBasicArticlePageTemplate 
                                                               title:@"Basic article" 
                                                          connectors:PCTemplateHorizontalConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCBasicArticlePageTemplate 
                                                                title:@"Basic article" 
                                                           connectors:PCTemplateHorizontalConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCArticleWithFixedIllustrationPageTemplate
                                                                title:@"Article with fixed illustration" 
                                                           connectors:PCTemplateHorizontalConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSimplePageTemplate
                                                                title:@"Simple Page" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCScrollingPageTemplate
                                                                title:@"Scrolling Page" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlidersBasedMiniArticlesHorizontalPageTemplate
                                                                title:@"Sliders based mini-articles (horizontal)" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlideshowPageTemplate
                                                                title:@"Slideshow" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCCoverPageTemplate
                                                                title:@"Cover page" 
                                                           connectors:PCTemplateRightConnector]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlidersBasedMiniArticlesVerticalPageTemplate
                                                                title:@"Sliders based mini-articles (vertical)" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCFixedIllustrationArticleTouchablePageTemplate
                                                                title:@"Touchable article with fixed illustration" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCInteractiveBulletsPageTemplate
                                                                title:@"Interactives bullets" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlideshowLandscapePageTemplate
                                                                title:@"Slideshow page" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlidersBasedMiniArticlesTopPageTemplate
                                                                title:@"Sliders based mini-articles (top)" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCHTMLPageTemplate
                                                                title:@"HTML page" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCDragAndDropPageTemplate 
                                                                title:@"Slideshow page" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCFlashBulletInteractivePageTemplate
                                                                title:@"Slideshow page" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCFlashBulletInteractivePageTemplate
                                                                title:@"Interactive bullet with flash" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCGalleryFlashBulletInteractivePageTemplate
                                                                title:@"Gallery with flash bullet interactive" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCHtml5PageTemplate
                                                                title:@"HTML5 page (code, rss, twitter, facebook, google map)" 
                                                           connectors:PCTemplateAllConnectors]];    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCHorizontalScrollingPageTemplate
                                                                title:@"Horizontal scrolling Page" 
                                                           connectors:PCTemplateAllConnectors]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PC3DPageTemplate
                                                                title:@"Page with 3D element" 
                                                           connectors:PCTemplateAllConnectors]];
}

- (id)init
{
    if (self = [super init])
    {
        templates = [[NSMutableDictionary alloc] init];
        [self initializeDefaultTemplates];
    }
    
    return self;
}

- (PCPageTemplate*)templateForId:(NSInteger)identifier
{
    PCPageTemplate* template = [templates objectForKey:[NSNumber numberWithInteger:identifier]];
    
    if (template == nil)
    {
        NSLog(@"WARNING unknow template id (%d)",identifier);
    }
    
    return template;
}

@end
