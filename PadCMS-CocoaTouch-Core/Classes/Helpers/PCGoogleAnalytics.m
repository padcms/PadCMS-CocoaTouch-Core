//
//  GoogleAnalyticsTracker.m
//  GoogleAnalyticsResearch
//
//  Created by Maxim Pervushin on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCGoogleAnalytics.h"
#import "GANTracker.h"
#import "PCApplication.h"
#import "PCIssue.h"
#import "PCRevision.h"
#import "PCPage.h"
#import "PCConfig.h"

static const NSInteger GANDispatchPeriodSec = 10;
static NSString* const DefaultGoogleAnalyticsAccountId = @"UA-1535257-14";
static BOOL GoogleAnalyticsTrackerStarted = NO;


@implementation PCGoogleAnalytics

+ (void)start
{
    if (!GoogleAnalyticsTrackerStarted)
    {
        NSString* accountId = [PCConfig googleAnalyticsAccountId];
        
        if (accountId == nil)
        {
            accountId = DefaultGoogleAnalyticsAccountId;
        }
        
        [[GANTracker sharedTracker] startTrackerWithAccountID:accountId
                                               dispatchPeriod:GANDispatchPeriodSec
                                                     delegate:nil];

        GoogleAnalyticsTrackerStarted = YES;

        NSLog(@"Google Analytics Tracker Started");
    }
}

+ (void)stop
{
    if (GoogleAnalyticsTrackerStarted)
    {
        [[GANTracker sharedTracker] stopTracker];
        GoogleAnalyticsTrackerStarted = NO;

        NSLog(@"Google Analytics Tracker Stopped");
    }
}

+ (void)trackPageView:(PCPage *)page
{
    PCRevision *revision = page.revision;
    PCIssue *issue = revision.issue;
    PCApplication *application = issue.application;
    
    NSString *pageInfo = [NSString stringWithFormat:@"/%@ - %@ - %@",
                          application.title, issue.title, page.machineName];

    
    if ([[GANTracker sharedTracker] trackPageview:pageInfo withError:nil])
    {
        NSLog(@"GA Track Page View: %@", pageInfo);
    }
    else
    {
        NSLog(@"ERROR: [GoogleAnalyticsTracker trackPageView:]");
    }
}

+ (void)trackPageNameView:(NSString *)pageName
{
    if ([[GANTracker sharedTracker] trackPageview:pageName withError:nil])
    {
        NSLog(@"GA Track Page View: %@", pageName);
    }
    else
    {
        NSLog(@"ERROR: [GoogleAnalyticsTracker trackPageView:]");
    }
}

+ (void)trackAction:(NSString *)action category:(NSString *)category
{
    if ([[GANTracker sharedTracker] trackEvent:category action:action
                                          label:nil value:-1 withError:nil])
    {
        NSLog(@"GA Track Action: %@ category: %@", action, category);
    }
    else
    {
        NSLog(@"ERROR: [GoogleAnalyticsTracker trackAction:category:]");
    }
}

@end
