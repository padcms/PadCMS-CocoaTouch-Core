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
                                                         description:@"" 
                                                          connectors:PCTemplateHorizontalConnectors 
                                                       engineVersion:1
                               ]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCBasicArticlePageTemplate 
                                                                title:@"Basic article" 
                                                          description:@"" 
                                                           connectors:PCTemplateHorizontalConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCArticleWithFixedIllustrationPageTemplate 
                                                                title:@"Article with fixed illustration" 
                                                          description:@"" 
                                                           connectors:PCTemplateHorizontalConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSimplePageTemplate 
                                                                title:@"Simple Page" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCScrollingPageTemplate 
                                                                title:@"Scrolling Page" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlidersBasedMiniArticlesHorizontalPageTemplate 
                                                                title:@"Sliders based mini-articles (horizontal)" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];

    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlideshowPageTemplate 
                                                                title:@"Slideshow" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCCoverPageTemplate 
                                                                title:@"Cover page" 
                                                          description:@"" 
                                                           connectors:PCTemplateRightConnector 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlidersBasedMiniArticlesVerticalPageTemplate 
                                                                title:@"Sliders based mini-articles (vertical)" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    

    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCFixedIllustrationArticleTouchablePageTemplate 
                                                                title:@"Touchable article with fixed illustration" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    

    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCInteractiveBulletsPageTemplate 
                                                                title:@"Interactives bullets" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlideshowLandscapePageTemplate 
                                                                title:@"Slideshow page" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCSlidersBasedMiniArticlesTopPageTemplate 
                                                                title:@"Sliders based mini-articles (top)" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCHTMLPageTemplate 
                                                                title:@"HTML page" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCDragAndDropPageTemplate 
                                                                title:@"Slideshow page" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];

    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCFlashBulletInteractivePageTemplate 
                                                                title:@"Slideshow page" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCFlashBulletInteractivePageTemplate 
                                                                title:@"Interactive bullet with flash" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCGalleryFlashBulletInteractivePageTemplate 
                                                                title:@"Gallery with flash bullet interactive" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCHtml5PageTemplate 
                                                                title:@"Gallery with flash bullet interactive" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];    

    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCHorizontalScrollingPageTemplate 
                                                                title:@"Horizontal scrolling Page" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];
    
    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PC3DPageTemplate 
                                                                title:@"Page with 3D element" 
                                                          description:@"" 
                                                           connectors:PCTemplateAllConnectors 
                                                        engineVersion:1
                                ]];    
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
