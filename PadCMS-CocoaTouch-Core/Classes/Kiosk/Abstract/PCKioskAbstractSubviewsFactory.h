//
//  PCKioskAbstractSubviewsFactory.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class PCKioskAbstractSubviewsFactory
 @brief Abstract class for providing list of subviews to PCKioskViewController
 */
@interface PCKioskAbstractSubviewsFactory : NSObject

/**
 @brief Returns array of PCKioskSubview subclassed instances
 
 @param Frame for subviews initialization
 */
- (NSArray*)subviewsListWithFrame:(CGRect) frame;

@end
