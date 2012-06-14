//
//  PCSlideshowViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageViewController.h"
#import "PCCustomPageControll.h"

/**
 @class PCSlideshowViewController
 @brief Slideshow View Controller
 */
@class MBProgressHUD;
@interface PCSlideshowViewController : PCPageViewController <UIScrollViewDelegate>
{
    PCScrollView* slidersView;
    PCCustomPageControll* pageControll;
    NSMutableArray *slideViewControllers;
    CGRect sliderRect;
	MBProgressHUD* slideHUD;
}

@property (nonatomic,retain) PCScrollView* slidersView; ///< slide view 
@property (nonatomic,retain) PCCustomPageControll* pageControll;///< custom page controll
@property (nonatomic,retain) NSMutableArray* slideViewControllers;

@end
