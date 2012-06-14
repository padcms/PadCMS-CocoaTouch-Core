//
//  PCSliderBasedMiniArticleViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageViewController.h"

@class PCScrollView;

/**
 @class PCSliderBasedMiniArticleViewController
 @brief Slider Based Mini Article View Controller
 */

@interface PCSliderBasedMiniArticleViewController : PCPageViewController
{
    NSMutableArray* miniArticleViews;
    PCScrollView* thumbsView;
    int currentMiniArticleIndex;
}

@property (nonatomic,retain) NSMutableArray* miniArticleViews; ///< mini articales view
@property (nonatomic,retain) PCScrollView* thumbsView; ///< thumbs scroll view

/**
 @brief Show article at index 
 @param index - article index
 */
-(void)showArticleAtIndex:(NSUInteger)index;

/**
 @brief Change article action
 */
-(void)changeArticle:(id)sender;

@end
