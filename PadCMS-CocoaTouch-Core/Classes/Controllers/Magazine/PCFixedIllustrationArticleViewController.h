//
//  PCFixedIllustrationArticleViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 10.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageViewController.h"

@class PCScrollView;

/**
 @class PCFixedIllustrationArticleViewController
 @brief Fixed Illustration Article Page View Controller 
 */

@interface PCFixedIllustrationArticleViewController : PCPageViewController
{
    PCScrollView* articleView;
}

@property (nonatomic,retain) PCScrollView* articleView;///< Article View

@end
