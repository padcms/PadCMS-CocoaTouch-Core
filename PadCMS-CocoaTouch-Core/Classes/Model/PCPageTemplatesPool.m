//
//  PCPageTemplatesPool.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
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
    

    [self registerPageTemplate:[PCPageTemplate templateWithIdentifier:PCArticleWithOverlayPageTemplate 
                                                                title:@"Article with overlay" 
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
