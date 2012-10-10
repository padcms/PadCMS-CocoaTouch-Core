//
//  PCPageControllersManager.m
//  Pad CMS
//
//  Created by Rustam Mallarcubanov on 21.02.12.
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

#import "PCPageControllersManager.h"
#import "PCPageTemplatesPool.h"
#import "PCPageViewController.h"
#import "PCFixedIllustrationArticleViewController.h"
#import "PCScrollingPageViewController.h"
#import "PCSlideshowViewController.h"
#import "PCSliderBasedMiniArticleViewController.h"
#import "PCInteractiveBulletWithFlash.h"
#import "PCGallaryWithFlashBulletsViewController.h"
#import "PCHorizontalScrollingPageViewController.h"
#import "SimpleAudioEngine.h"
#import "ScrollingPageViewController.h"
#import "TouchableArticleWithFixedIllustrationViewController.h"
#import "SliderBasedMiniArticleViewController.h"
#import "InteractivesBulletsViewController.h"
#import "SlideshowViewController.h"
#import "HTMLPageViewController.h"
#import "Page3DViewController.h"
#import "HTML5PageViewController.h"

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
	[self registerPageControllerClass:[SimplePageViewController class] forTemplateId:PCBasicArticlePageTemplate];
	[self registerPageControllerClass:[SimplePageViewController class] forTemplateId:PCSimplePageTemplate];
	[self registerPageControllerClass:[SimplePageViewController class] forTemplateId:PCCoverPageTemplate];
    [self registerPageControllerClass:[HTMLPageViewController class] forTemplateId:PCHTMLPageTemplate];
    [self registerPageControllerClass:[PCPageViewController class] forTemplateId:PCDragAndDropPageTemplate];
    [self registerPageControllerClass:[PCInteractiveBulletWithFlash class] forTemplateId:PCFlashBulletInteractivePageTemplate];
	[self registerPageControllerClass:[ScrollingPageViewController class] forTemplateId:PCGalleryFlashBulletInteractivePageTemplate];
    [self registerPageControllerClass:[HTML5PageViewController class] forTemplateId:PCHtml5PageTemplate];
    [self registerPageControllerClass:[PCPageViewController class] forTemplateId:PCSlideshowLandscapePageTemplate];
	[self registerPageControllerClass:[TouchableArticleWithFixedIllustrationViewController class] forTemplateId:PCFixedIllustrationArticleTouchablePageTemplate];
    [self registerPageControllerClass:[PCFixedIllustrationArticleViewController class] forTemplateId:PCArticleWithFixedIllustrationPageTemplate];
	[self registerPageControllerClass:[ScrollingPageViewController class] forTemplateId:PCScrollingPageTemplate];
    [self registerPageControllerClass:[SlideshowViewController class] forTemplateId:PCSlideshowPageTemplate];
	[self registerPageControllerClass:[InteractivesBulletsViewController class] forTemplateId:PCInteractiveBulletsPageTemplate];
	[self registerPageControllerClass:[SliderBasedMiniArticleViewController class] forTemplateId:PCSlidersBasedMiniArticlesHorizontalPageTemplate];
	[self registerPageControllerClass:[SliderBasedMiniArticleViewController class] forTemplateId:PCSlidersBasedMiniArticlesVerticalPageTemplate];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplateId:PCSlidersBasedMiniArticlesTopPageTemplate];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplateId:PCSlidersBasedMiniArticlesTopPageTemplate];
	[self registerPageControllerClass:[ScrollingPageViewController class] forTemplateId:PCHorizontalScrollingPageTemplate];
    [self registerPageControllerClass:[Page3DViewController class] forTemplateId:PC3DPageTemplate];
}

-(Class)controllerClassForPageTemplate:(PCPageTemplate*)aTemplate
{
    id controllerClass = [controllers objectForKey:[NSNumber numberWithInteger:aTemplate.identifier]];
    return controllerClass;
}

-(void)registerPageControllerClass:(Class)aClass forTemplateId:(PCPageTemplateType)aTemplateId
{
    if([[PCPageTemplatesPool templatesPool] templateForId:aTemplateId]) // registering class only if template is put into pool
        [controllers setObject:aClass forKey:[NSNumber numberWithInteger:aTemplateId]];
}

@end
