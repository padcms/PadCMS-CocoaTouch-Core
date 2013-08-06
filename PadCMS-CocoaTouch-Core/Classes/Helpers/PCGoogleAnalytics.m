//
//  GoogleAnalyticsTracker.m
//  GoogleAnalyticsResearch
//
//  Created by Maxim Pervushin on 5/8/12.
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
