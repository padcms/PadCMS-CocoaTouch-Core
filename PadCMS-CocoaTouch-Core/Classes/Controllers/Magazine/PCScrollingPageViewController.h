//
//  PCScrollingPageViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 09.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageViewController.h"

/**
 @class PCScrollingPageViewController
 @brief Scrolling Page View Controller
 */

@interface PCScrollingPageViewController : PCPageViewController <UIScrollViewDelegate>
{
    PCScrollView* scrollingPane;
    PCPageElementViewController* scrollingPaneContentView;
    UIButton* scrollDownButton;
    UIButton* scrollUpButton;
}

@property (nonatomic,retain) PCScrollView* scrollingPane; ///< scrolling pane
@property (nonatomic,retain) PCPageElementViewController* scrollingPaneContentView; ///< scrolling pane content 
@end
