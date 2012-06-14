//
//  PCLanscapeSladeshowColumnViewController.h
//  Pad CMS
//
//  Created by Rustam Mallarkubanov on 12.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCColumnViewController.h"
#import <AVFoundation/AVFoundation.h>

@class PCScrollView;

/**
 @class PCLanscapeSladeshowColumnViewController
 @brief Lanscape Sladeshow Column View Controller 
 */

@interface PCLanscapeSladeshowColumnViewController : PCColumnViewController
{
    NSMutableArray* slideShowPageViewControllers;
    PCScrollView* slideShowPagesScrollView;
    NSString* soundSource;
    AVAudioPlayer* player;
}

@end
