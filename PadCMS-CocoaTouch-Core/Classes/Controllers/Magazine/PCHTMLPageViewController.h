//
//  PCHTMLPageViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCPageViewController.h"
#import "PCLandscapeViewController.h"

@interface PCHTMLPageViewController : PCPageViewController <UIWebViewDelegate>
{
    PCLandscapeViewController* webViewController;
    UIDeviceOrientation currentMagazineOrientation;
    BOOL webViewIsShowed;
}

@property (nonatomic,retain) PCLandscapeViewController* webViewController;

@end
