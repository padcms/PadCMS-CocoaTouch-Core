//
//  NSDictionary+Additions.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/1/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class NSDictionary (Additions)
 @brief Additions for NSDictionary container class
 */
@interface NSDictionary (Additions)

/**
 @brief Replace all [NSNull null] values in current dictionary and all subdictionaries recursively
 */
- (NSDictionary *)dictionaryWithNullsReplaced;

@end
