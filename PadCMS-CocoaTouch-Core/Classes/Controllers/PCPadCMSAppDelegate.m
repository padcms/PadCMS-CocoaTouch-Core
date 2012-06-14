//
//  PCPadCMSAppDelegate.m
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PCPadCMSAppDelegate.h"
#import "PCMainViewController.h"
#import "ImageCache.h"
#import "PCRemouteNotificationCenter.h"
#import "InAppPurchases.h"
#import "PCGoogleAnalytics.h"
#import "PCResourceCache.h"
#import "PCDownloadManager.h"
@implementation PCPadCMSAppDelegate

@synthesize window;
@synthesize viewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    [PCGoogleAnalytics start];
    [PCGoogleAnalytics trackAction:@"Application launch" category:@"General"];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];
    [InAppPurchases sharedInstance];
	[PCDownloadManager sharedManager];
    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];	
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{

}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [PCGoogleAnalytics trackAction:@"Application terminate" category:@"General"];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	NSLog(@"From applicationDidReceiveMemoryWarning");
	
	if ([viewController modalViewController]) {
		return;
    }
    [[PCResourceCache sharedInstance] removeAllObjects];
	[[ImageCache sharedImageCache] removeAllImages];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

	[self.viewController.revisionViewController clearMemory];
}

- (void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[PCRemouteNotificationCenter defaultRemouteNotificationCenter] registerDeviceWithToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[PCRemouteNotificationCenter defaultRemouteNotificationCenter] registrationDidFailWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[PCRemouteNotificationCenter defaultRemouteNotificationCenter] didReceiveRemoteNotification:userInfo];
}

@end
