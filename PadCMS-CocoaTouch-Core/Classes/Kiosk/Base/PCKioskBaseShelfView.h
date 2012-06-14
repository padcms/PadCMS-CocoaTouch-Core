//
//  PCKioskBaseShelfView.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 26.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskSubview.h"
#import "PCKioskAbstractControlElement.h"

/**
 @class PCKioskBaseShelfView
 @brief Base class for kiosk book shelf subview
 */
@interface PCKioskBaseShelfView : PCKioskSubview <PCKioskSubviewDelegateProtocol>
{
    NSMutableArray      *cells; ///< array of control elements
    UIScrollView        *mainScrollView; ///< scroll view for scrolling subview content
}

/**
 @brief Create and return new instance of the control element
 
 @param visible frame for element
 */
- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;

@end
