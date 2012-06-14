//
//  PCPageWithOverlayViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 15.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFixedIllustrationArticleTouchablePageViewController.h"

@interface PCPageWithOverlayViewController : PCFixedIllustrationArticleTouchablePageViewController
{
    PCPageElementViewController* overlayViewController;
}

@property (nonatomic,retain) PCPageElementViewController* overlayViewController;

@end
