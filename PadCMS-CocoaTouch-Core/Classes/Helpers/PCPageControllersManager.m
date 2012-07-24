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
#import "PCFixedIllustrationArticleTouchablePageViewController.h"
#import "PCFixedIllustrationArticleViewController.h"
#import "PCScrollingPageViewController.h"
#import "PCSlideshowViewController.h"
#import "PCSliderBasedMiniArticleViewController.h"
#import "PCHTMLPageViewController.h"
#import "PCInteractiveBulletWithFlash.h"
#import "PCGallaryWithFlashBulletsViewController.h"
//#import "PCHTML5PageViewController.h"
#import "PCCoverPageViewControllerViewController.h"
#import "PCHorizontalScrollingPageViewController.h"
#import "PC3DViewController.h"
#import "BasicArticleViewController.h"
#import "SimpleAudioEngine.h"
#import "ScrollingPageViewController.h"
#import "TouchableArticleWithFixedIllustrationViewController.h"
#import "SliderBasedMiniArticleViewController.h"
#import "InteractivesBulletsViewController.h"
#import "SlideshowViewController.h"
#import "HTMLPageViewController.h"

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
   // [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate]];
	[self registerPageControllerClass:[BasicArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate]];
   // [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSimplePageTemplate]];
	;
	[self registerPageControllerClass:[SimplePageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSimplePageTemplate]];
	
   // [self registerPageControllerClass:[PCCoverPageViewControllerViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCCoverPageTemplate]];
	[self registerPageControllerClass:[SimplePageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCCoverPageTemplate]];
	
    [self registerPageControllerClass:[HTMLPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHTMLPageTemplate]];
	
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCDragAndDropPageTemplate]];
	
    [self registerPageControllerClass:[PCInteractiveBulletWithFlash class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCFlashBulletInteractivePageTemplate]];
 //   [self registerPageControllerClass:[PCGallaryWithFlashBulletsViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCGalleryFlashBulletInteractivePageTemplate]];
	
	[self registerPageControllerClass:[ScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCGalleryFlashBulletInteractivePageTemplate]];
	
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHtml5PageTemplate]];
    [self registerPageControllerClass:[PCPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlideshowLandscapePageTemplate]];
    
  //  [self registerPageControllerClass:[PCFixedIllustrationArticleTouchablePageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCFixedIllustrationArticleTouchablePageTemplate]];
	[self registerPageControllerClass:[TouchableArticleWithFixedIllustrationViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCFixedIllustrationArticleTouchablePageTemplate]];
	
    
    [self registerPageControllerClass:[PCFixedIllustrationArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCArticleWithFixedIllustrationPageTemplate]];

  //  [self registerPageControllerClass:[PCScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCScrollingPageTemplate]];
	[self registerPageControllerClass:[ScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCScrollingPageTemplate]];

    [self registerPageControllerClass:[SlideshowViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlideshowPageTemplate]];

    //[self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCInteractiveBulletsPageTemplate]];
	
	[self registerPageControllerClass:[InteractivesBulletsViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCInteractiveBulletsPageTemplate]];
    //[self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesHorizontalPageTemplate]];
   // [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesVerticalPageTemplate]];
	
	[self registerPageControllerClass:[SliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesHorizontalPageTemplate]];
	[self registerPageControllerClass:[SliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesVerticalPageTemplate]];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesTopPageTemplate]];
    [self registerPageControllerClass:[PCSliderBasedMiniArticleViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlidersBasedMiniArticlesTopPageTemplate]];

   // [self registerPageControllerClass:[PCHorizontalScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHorizontalScrollingPageTemplate]];
	
	[self registerPageControllerClass:[ScrollingPageViewController class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCHorizontalScrollingPageTemplate]];
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
