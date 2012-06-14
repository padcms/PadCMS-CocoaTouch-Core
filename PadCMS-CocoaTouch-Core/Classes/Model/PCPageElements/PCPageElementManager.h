//
//  PCPageElementManager.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 21.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class PCPageElementManager
 @brief Provides an interface for extending page elements types without making changes in core components. Model Builder retrieves class that describes an element of specific type from PCPageElementManager, then created an instance of this class and initialize its data with pushElementData:.
 */

@interface PCPageElementManager : NSObject
{
    NSMutableDictionary* elementClasses;
}

/**
 @brief Returns standart Element Manager 
 */
+ (PCPageElementManager*)sharedManager;

/**
 @brief Return class for specific type. 
 @param aElementType - element type.
 */
- (Class)elementClassForElementType:(NSString*)aElementType;

/**
 @brief Register class for specific type  
 @param aClass - Class
 @param aElementType - element type
 */
- (void)registerPageElementClass:(Class)aClass forElementType:(NSString*)aElementType;

@end
