//
//  PCMagazineViewControllersFactory.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMagazineViewControllersFactory.h"
#import "PCSliderBasedMiniArticleViewController.h"
#import "PCSlideshowViewController.h"
#import "PCScrollingPageViewController.h"
#import "PCFixedIllustrationArticleViewController.h"
#import "PCFixedIllustrationArticleTouchablePageViewController.h"
#import "PCLanscapeSladeshowColumnViewController.h"
#import "PCPageControllersManager.h"

@implementation PCMagazineViewControllersFactory

+(PCMagazineViewControllersFactory*)factory
{
    static PCMagazineViewControllersFactory* factory = nil;
    if (factory == nil)
    {
        factory = [[PCMagazineViewControllersFactory alloc] init];
    }
    return factory;
}

-(PCColumnViewController*)viewControllerForColumn:(PCColumn*)column
{
    if ([column.pages count] < 1)
        return nil;
    PCPage* firstPage = [column.pages objectAtIndex:0];
    
    switch (firstPage.pageTemplate.identifier) 
    {
        case PCSlideshowLandscapePageTemplate:
            return [[[PCLanscapeSladeshowColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;    
        default:
            return [[[PCColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;    
    }   
    return nil;
}

-(PCPageViewController*)viewControllerForPage:(PCPage *)page
{
    Class pageControllerClass = [[PCPageControllersManager sharedManager] controllerClassForPageTemplate:page.pageTemplate];
    
    if (pageControllerClass != nil)
    {
        return [[[pageControllerClass alloc] initWithPage:(PCPage *)page] autorelease];
    }
    
    return nil;
}

@end
