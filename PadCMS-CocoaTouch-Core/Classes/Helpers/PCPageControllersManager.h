//
//  PCPageControllersManager.h
//  Pad CMS
//
//  Created by Rustam Mallarkubanov on 21.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCData.h"

@interface PCPageControllersManager : NSObject
{
    NSMutableDictionary* controllers;
}

+(PCPageControllersManager*)sharedManager;

-(Class)controllerClassForPageTemplate:(PCPageTemplate*)aTemplate;
-(void)registerPageControllerClass:(Class)aClass forTemplate:(PCPageTemplate*)aTemplate;

@end
