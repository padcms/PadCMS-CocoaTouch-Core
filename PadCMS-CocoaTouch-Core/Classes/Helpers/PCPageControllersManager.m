//
//  PCPageControllersManager.m
//  Pad CMS
//
//  Created by Rustam Mallarcubanov on 21.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageControllersManager.h"
#import "PCPageTemplatesPool.h"
#import "PCPageViewController.h"
#import "PCFixedIllustrationArticleTouchablePageViewController.h"
#import "PCFixedIllustrationArticleViewController.h"
#import "PCScrollingPageViewController.h"
#import "PCSlideshowViewController.h"
#import "PCSliderBasedMiniArticleViewController.h"
#import "PCPageWithOverlayViewController.h"
#import "PCHTMLPageViewController.h"
#import "PCInteractiveBulletWithFlash.h"
#import "PCGallaryWithFlashBulletsViewController.h"
#import "PCHTML5PageViewController.h"
#import "PCCoverPageViewControllerViewController.h"
#import "PCHorizontalScrollingPageViewController.h"
#import "PC3DViewController.h"

@interface  PCPageControllersManager(ForwardDeclarations)
-(void)initializeBaseControllers;
@end

@implementation PCPageControllersManager

+(PCPageControllersManager*)sharedManager
{
    static PCPageControllersManager * sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[PCPageControllersManager alloc] init];
    }
    return sharedManager;
}

-(void)dealloc
{
    [controllers release];
    controllers = nil;
    [super dealloc];
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        controllers = [[NSMutableDictionary alloc] init];
        [self initializeBaseControllers];
    }
    
    return self;  
}

-(void)initializeBaseControllers
{
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate]];
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSimplePageTemplate]];
    [self registerPageControllerClass:[PCCoverPageViewControllerViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCCoverPageTemplate]];
    [self registerPageControllerClass:[PCPageWithOverlayViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCArticleWithOverlayPageTemplate]];
    [self registerPageControllerClass:[PCHTMLPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHTMLPageTemplate]];
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCDragAndDropPageTemplate]];
    [self registerPageControllerClass:[PCInteractiveBulletWithFlash class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCFlashBulletInteractivePageTemplate]];
    [self registerPageControllerClass:[PCGallaryWithFlashBulletsViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCGalleryFlashBulletInteractivePageTemplate]];
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHtml5PageTemplate]];
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlideshowLandscapePageTemplate]];
    
    [self registerPageControllerClass:[PCFixedIllustrationArticleTouchablePageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCFixedIllustrationArticleTouchablePageTemplate]];
    
    [self registerPageControllerClass:[PCFixedIllustrationArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCArticleWithFixedIllustrationPageTemplate]];

    [self registerPageControllerClass:[PCScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCScrollingPageTemplate]];

    [self registerPageControllerClass:[PCSlideshowViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlideshowPageTemplate]];

    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCInteractiveBulletsPageTemplate]];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesHorizontalPageTemplate]];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesVerticalPageTemplate]];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesTopPageTemplate]];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesTopPageTemplate]];

    [self registerPageControllerClass:[PCHorizontalScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHorizontalScrollingPageTemplate]];
    [self registerPageControllerClass:[PC3DViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PC3DPageTemplate]];
}

-(Class)controllerClassForPageTemplate:(PCPageTemplate*)aTemplate
{
    id controllerClass = [controllers objectForKey:[NSNumber numberWithInteger:aTemplate.identifier]];
    return controllerClass;
}

-(void)registerPageControllerClass:(Class)aClass forTemplate:(PCPageTemplate*)aTemplate
{
    [controllers setObject:aClass forKey:[NSNumber numberWithInteger:aTemplate.identifier]];
}

@end
