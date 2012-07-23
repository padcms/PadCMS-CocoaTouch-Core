//
//  PCConfig.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.02.12.
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

#import "PCConfig.h"

#import "PCMacros.h"

NSString const *PCTableOfContentsKey = @"PCTableOfContents";
NSString const *PCTableOfContentsTopKey = @"PCTableOfContentsTop";
NSString const *PCTableOfContentsBottomKey = @"PCTableOfContentsBottom";
NSString const *PCConfigApplicationIdentifierKey = @"PCConfigApplicationIdentifier";
NSString const *PCConfigClientIdentifierKey = @"PCConfigClientIdentifier";
NSString const *PCConfigDisableSearchingKey = @"PCDisableSearching";
NSString const *PCConfigFacebookId	= @"PCConfigFacebookId";
NSString const *PCConfigSharedSecretKey = @"PCConfigSharedSecretKey";
NSString const *PCConfigGANAccountId = @"PCConfigGANAccountId";
NSString const *PCConfigKiosqueType	= @"PCConfigKiosqueType";
NSString const *PCConfigServerURLKey = @"PCConfigServerURL";
NSString const *PCConfigSubscriptions = @"PCConfigSubscriptions";
NSString const *PCConfigUseNewsstand = @"PCConfigUseNewsstand";
NSString const *PCPADCMSConfigKey = @"PADCMSConfig";
NSString const *PCScrollViewScrollButtonsDisabledKey = @"PCScrollViewScrollButtonsDisabled";
NSString const *PCScrollingPageVerticalScrollButtonsDisabledKey = @"PCScrollingPageVerticalScrollButtonsDisabled";
NSString const *PCScrollingPageHorizontalScrollButtonsDisabledKey = @"PCScrollingPageHorizontalScrollButtonsDisabled";
NSString const *PCStyleSheetKey = @"PCStyleSheet"; 
NSString const *PCConfigApplicationDefaultLanguageKey = @"PCConfigApplicationDefaultLanguage"; 


@interface PCConfig ()

+ (NSDictionary *)padCMSConfig;

@end

@implementation PCConfig

#pragma mark - private class methods

+ (NSDictionary *)padCMSConfig
{
    static NSDictionary *padCMSConfig = nil;
    
    if (padCMSConfig == nil) {
        padCMSConfig = [[[[NSBundle mainBundle] infoDictionary] objectForKey:PCPADCMSConfigKey] retain];
        
        if (padCMSConfig == nil) {
            NSLog(@"WARNING! Please add 'PADCMSConfig' Dictionary to Info.plist file");
        }
    }
    
    return padCMSConfig;
}

#pragma mark - public class methods

+ (NSDictionary *)topTableOfContentsConfig
{
    static NSDictionary *topTableOfContentsConfig = nil;
    
    if (topTableOfContentsConfig == nil) {
        topTableOfContentsConfig = [[[[self padCMSConfig] objectForKey:PCTableOfContentsKey] objectForKey:PCTableOfContentsTopKey] retain];
    }
    
    return topTableOfContentsConfig;
}

+ (NSDictionary *)bottomTableOfContentsConfig
{
    static NSDictionary *bottomTableOfContentsConfig = nil;
    
    if (bottomTableOfContentsConfig == nil) {
        bottomTableOfContentsConfig = [[[[self padCMSConfig] objectForKey:PCTableOfContentsKey] objectForKey:PCTableOfContentsBottomKey] retain];
    }
    
    return bottomTableOfContentsConfig;
}

+ (BOOL)isScrollViewScrollButtonsDisabled
{
    static NSNumber *scrollViewScrollButtonsDisabled = nil;
    
    if (scrollViewScrollButtonsDisabled == nil) {
        scrollViewScrollButtonsDisabled = [[[self padCMSConfig] 
                                            objectForKey:PCScrollViewScrollButtonsDisabledKey] retain]; 
        
        if (scrollViewScrollButtonsDisabled == nil) {
            scrollViewScrollButtonsDisabled = [[NSNumber numberWithBool:NO] retain];
        }
    }
    
    return [scrollViewScrollButtonsDisabled boolValue];
}

+ (BOOL)isScrollingPageVerticalScrollButtonsDisabled
{   
    static NSNumber *scrollingPageVerticalScrollButtonsDisabled = nil;
    
    if (scrollingPageVerticalScrollButtonsDisabled == nil) {
        scrollingPageVerticalScrollButtonsDisabled = [[[self padCMSConfig] 
                                                       objectForKey:PCScrollingPageVerticalScrollButtonsDisabledKey] retain]; 
        
        if (scrollingPageVerticalScrollButtonsDisabled == nil) {
            scrollingPageVerticalScrollButtonsDisabled = [[NSNumber numberWithBool:NO] retain];
        }
    }
    
    return [scrollingPageVerticalScrollButtonsDisabled boolValue];
}

+ (BOOL)isScrollingPageHorizontalScrollButtonsDisabled
{
    static NSNumber *scrollingPageHorizontalScrollButtonsDisabled = nil;
    
    if (scrollingPageHorizontalScrollButtonsDisabled == nil) {
        scrollingPageHorizontalScrollButtonsDisabled = [[[self padCMSConfig] 
                                            objectForKey:PCScrollingPageHorizontalScrollButtonsDisabledKey] retain]; 
        
        if (scrollingPageHorizontalScrollButtonsDisabled == nil) {
            scrollingPageHorizontalScrollButtonsDisabled = [[NSNumber numberWithBool:NO] retain];
        }
    }
    
    return [scrollingPageHorizontalScrollButtonsDisabled boolValue];
}

+ (BOOL)isSearchDisabled
{
    static NSNumber *searchDisabled = 0;
    
    if (searchDisabled == nil) {
        searchDisabled = [[[self padCMSConfig] objectForKey:PCConfigDisableSearchingKey] retain]; 
        
        if (searchDisabled == nil) {
            searchDisabled = [[NSNumber numberWithBool:NO] retain];
        }
    }
    
    return [searchDisabled boolValue];
}

+ (BOOL)useNewsstand
{
    static NSNumber *useNewsstand = nil;
    
    if (useNewsstand == nil) {
        useNewsstand = [[[self padCMSConfig] objectForKey:PCConfigUseNewsstand] retain]; 
        
        if (useNewsstand == nil) {
            useNewsstand = [[NSNumber numberWithBool:NO] retain];
        }
    }
    
    return [useNewsstand boolValue];
}

+ (KiosqueType)kiosqueType
{
	static NSNumber *kiosqueType = 0;
    
    if (kiosqueType == nil) {
        kiosqueType = [[[self padCMSConfig] objectForKey:PCConfigKiosqueType] retain]; 
    }
    
    return [kiosqueType intValue];
}

+ (NSArray *)subscriptions
{
    static NSArray *subscriptions = nil;
    
    if (subscriptions == nil) {
        subscriptions = [[self padCMSConfig] objectForKey:PCConfigSubscriptions];
        
        if (subscriptions == nil) {
            NSLog(@"WARNING! Please add 'PCConfigSubscriptions' dictionary to 'PADCMSConfig' in Info.plist file");
        }
    }
    
    return subscriptions;
}

+ (NSDictionary *)defaultStyleSheet
{
    static NSDictionary *defaultStyleSheet = nil;
    
    if (defaultStyleSheet == nil) {
        defaultStyleSheet = [[self padCMSConfig] objectForKey:PCStyleSheetKey];
        
        if (defaultStyleSheet == nil) {
            NSLog(@"WARNING! Please add 'PCStyleSheet' dictionary to 'PADCMSConfig' in Info.plist file");
        }
    }
    
    return defaultStyleSheet;
}

+ (NSInteger)applicationIdentifier
{
    static NSNumber *applicationIdentifier = 0;
    
    if (applicationIdentifier == nil) {
        applicationIdentifier = [[[self padCMSConfig] objectForKey:PCConfigApplicationIdentifierKey] retain]; 
    }
    
    return [applicationIdentifier integerValue];
}

+ (NSInteger)clientIdentifier
{
    static NSNumber *clientIdentifier = nil;
    
    if (clientIdentifier == nil) {
        clientIdentifier = [[[self padCMSConfig] objectForKey:PCConfigClientIdentifierKey] retain];
    }
    
    return [clientIdentifier integerValue];
}

+ (NSString *)facebookApplicationId
{
    static NSString *facebookApplicationId = nil;
    
    if (facebookApplicationId == nil) {
        facebookApplicationId = [[[PCConfig padCMSConfig] 
                                  objectForKey:PCConfigFacebookId] retain]; 
    }
    
    return facebookApplicationId;
}

+ (NSString *)sharedSecretKey
{
    static NSString *sharedSecretKey = nil;
    
    if (sharedSecretKey == nil) {
        sharedSecretKey = [[[PCConfig padCMSConfig] 
                                  objectForKey:PCConfigSharedSecretKey] retain]; 
    }
    
    return sharedSecretKey;
}

+ (NSString *)googleAnalyticsAccountId
{
    static NSString *googleAnalyticsAccountId = nil;
    
    if (googleAnalyticsAccountId == nil) {
        googleAnalyticsAccountId = [[[PCConfig padCMSConfig] 
                                     objectForKey:PCConfigGANAccountId] retain]; 
    }
    
    return googleAnalyticsAccountId;
}

+ (NSString *)serverURLString
{
    static NSString *serverURLString = nil;
    
    if (serverURLString == nil) {
        serverURLString = [[[self padCMSConfig] objectForKey:PCConfigServerURLKey] copy];
    }
    
    return serverURLString;
}

+ (NSURL *)serverURL
{
    static NSURL *serverURL = nil;
    
    if (serverURL == nil) {
        NSString *serverURLString = [self serverURLString];
        serverURL = [[NSURL URLWithString:serverURLString] retain]; 
    }
    
    return serverURL;
}

+ (NSString *)ApplicationDefaultLanguage
{
    static NSString *applicationDefaultLanguage = nil;
    
    if (applicationDefaultLanguage == nil)
    {
        applicationDefaultLanguage = [[[PCConfig padCMSConfig] 
                                  objectForKey:PCConfigApplicationDefaultLanguageKey] retain]; 
    }
    
    return applicationDefaultLanguage;
}


@end
