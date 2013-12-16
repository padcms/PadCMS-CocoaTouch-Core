//
//  PCPadCMSAppDelegate.m
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

#import "PCPadCMSAppDelegate.h"
#import "PCMainViewController.h"
#import "PCRemouteNotificationCenter.h"
#import "InAppPurchases.h"
#import "PCGoogleAnalytics.h"
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
  NSLog(@"token - %@", deviceToken);
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
