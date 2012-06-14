//
//  PCColumn.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

/**
 @class PCColumn
 @brief PCColumn is a container class which build pages to columns. After pages initialization Model Builder calls updateColumns method of PCMagazine class that builds columns from pages.
*/

#import <Foundation/Foundation.h>

@interface PCColumn : NSObject
{
    NSMutableArray* pages;
}

/// @brief Pages which belong to specific columns
@property (assign,readonly) NSMutableArray* pages;

/**
 @brief Creating column.
 
 @param aPages - Array with pages 
 */ 
- (id)initWithPages:(NSMutableArray*)aPages;

@end
