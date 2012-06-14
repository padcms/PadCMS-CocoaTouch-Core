//
//  PCPadCMSAppDelegate.h
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCMainViewController;
@interface PCPadCMSAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    PCMainViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PCMainViewController *viewController;

@end

