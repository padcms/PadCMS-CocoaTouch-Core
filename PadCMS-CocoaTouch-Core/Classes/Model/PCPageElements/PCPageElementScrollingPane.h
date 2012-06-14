//
//  PCPageElementScrollingPane.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

/**
 @class PCPageElementScrollingPane
 @brief Represents Scrolling Pane element of the page.
 */

@interface PCPageElementScrollingPane : PCPageElement
{
    NSInteger top;
}

@property (nonatomic,assign) NSInteger top; ///< Set in pixels, it defines where this element should be shown at the beginning. It also defines the lowest position of the scrolling pan; to avoid, it disappears from the screen.

@end
