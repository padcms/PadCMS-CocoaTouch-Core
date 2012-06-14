//
//  PCHorizontalScrollingPageViewController.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 24.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageViewController.h"
#import "PCHorizontalPageElementViewController.h"

@class PCScrollView;

/**
 @class PCHorizontalScrollingPageViewController
 @brief Horizontal scrolling Page View Controller
 */
@interface PCHorizontalScrollingPageViewController : PCPageViewController <UIScrollViewDelegate>
{
    PCScrollView* scrollingPane;
    PCHorizontalPageElementViewController* scrollingPaneContentView;
    UIButton* scrollRightButton;
    UIButton* scrollLeftButton;
}

@property (nonatomic,retain) PCScrollView* scrollingPane; ///< scrolling pane
@property (nonatomic,retain) PCHorizontalPageElementViewController* scrollingPaneContentView; ///< scrolling pane content 

@end
