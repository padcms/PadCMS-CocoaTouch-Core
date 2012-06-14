//
//  PCDataHelper.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class PCDataHelper
 @brief PCSQLLiteModelBuilder class uses PCDataHelper class for convert string data to their values. 
 */

@interface PCDataHelper : NSObject

/**
 @brief Convert NSString data to NSColor value.
 
 @param aString - Hex reprezentation for color 
 */ 
+ (UIColor*)colorFromString:(NSString*)aString;

/**
 @brief Convert NSString data to NSDate value
 
 @param aString - RFC3339 reprezentation of date
 */ 

+ (NSDate*)dateFromString:(NSString*)aString;

@end
