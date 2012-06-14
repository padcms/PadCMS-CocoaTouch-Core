//
//  GoogleAnalyticsTracker.h
//  GoogleAnalyticsResearch
//
//  Created by Maxim Pervushin on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPage;

@interface PCGoogleAnalytics : NSObject

+ (void)start;
+ (void)stop;
+ (void)trackPageView:(PCPage *)page;
+ (void)trackPageNameView:(NSString *)pageName;
+ (void)trackAction:(NSString *)action category:(NSString *)category;

@end
