//
//  PCMagazineViewControllersFactory.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCData.h"
#import "PCColumnViewController.h"
#import "PCPageViewController.h"

/**
 @class PCMagazineViewControllersFactory
 @brief Magazine View Controllers Factory
 */

@interface PCMagazineViewControllersFactory : NSObject

/**
 @brief default factory
 */

+(PCMagazineViewControllersFactory*)factory;

/**
 @brief Return column view controller for column data model
 @param column - column data model
 */

-(PCColumnViewController*)viewControllerForColumn:(PCColumn*)column;

/**
 @brief Return page view controller for page data model 
 @brief default factory
 */

-(PCPageViewController*)viewControllerForPage:(PCPage *)page;

@end
