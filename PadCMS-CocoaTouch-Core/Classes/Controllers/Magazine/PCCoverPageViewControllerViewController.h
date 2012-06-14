//
//  PCCoverPageViewControllerViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 27.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageViewController.h"

@interface PCCoverPageViewControllerViewController : PCPageViewController
{
    PCPageElementViewController* advertViewController;
    BOOL showVidioController;
}

@property (nonatomic,retain) PCPageElementViewController* advertViewController;

@end
