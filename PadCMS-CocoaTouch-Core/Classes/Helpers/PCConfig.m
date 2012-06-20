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

NSString const *PCPADCMSConfigKey = @"PADCMSConfig";
NSString const *PCConfigServerURLKey = @"PCConfigServerURL";
NSString const *PCConfigClientIdentifierKey = @"PCConfigClientIdentifier";
NSString const *PCConfigApplicationIdentifierKey = @"PCConfigApplicationIdentifier";
NSString const *PCConfigGANAccountId = @"PCConfigGANAccountId";
NSString const *PCConfigUseSandBoxKey = @"PCConfigUseSandBoxKey";
NSString const *PCConfigSubscriptions = @"PCConfigSubscriptions";
NSString const *PCConfigUseNewsstand = @"PCConfigUseNewsstand";
NSString const *PCStyleSheetKey = @"PCStyleSheet"; 
NSString const *PCConfigDisableSearchingKey = @"PCDisableSearching";
NSString const *PCConfigKiosqueType	= @"PCConfigKiosqueType";
NSString const *PCConfigFacebookId	= @"PCConfigFacebookId";
NSString const *PCScrollViewScrollButtonsDisabled = @"PCScrollViewScrollButtonsDisabled";

@implementation PCConfig

+(NSDictionary*)padCMSConfig
{
    static NSDictionary* padCMSConfig = nil;
    if (padCMSConfig == nil)
    {
        padCMSConfig = [[[[NSBundle mainBundle] infoDictionary] objectForKey:PCPADCMSConfigKey] retain];
        if (padCMSConfig == nil)
            NSLog(@"WARNING! Please add 'PADCMSConfig' Dictionary to Info.plist file");
    }
    
    return padCMSConfig;
}

+(NSInteger)clientIdentifier
{
    static NSNumber* clientIdentifierNumber = nil;
    if (clientIdentifierNumber == nil)
    {
        clientIdentifierNumber = [[[self padCMSConfig] objectForKey:PCConfigClientIdentifierKey] retain];
    }
    return [clientIdentifierNumber integerValue];
}

+(NSInteger)applicationIdentifier
{
    static NSNumber* applicationIdentifierNumber = 0;
    if (applicationIdentifierNumber == nil)
    {
        applicationIdentifierNumber = [[[self padCMSConfig] objectForKey:PCConfigApplicationIdentifierKey] retain]; 
    }
    return [applicationIdentifierNumber integerValue];
}

+ (NSString *)googleAnalyticsAccountId
{
    static NSString *googleAnalyticsAccountId = nil;
    
    if (googleAnalyticsAccountId == nil)
    {
        googleAnalyticsAccountId = [[[PCConfig padCMSConfig] 
                                     objectForKey:PCConfigGANAccountId] retain]; 
    }
    
    return googleAnalyticsAccountId;
}

+ (NSString *)facebookApplicationId
{
    static NSString *facebookApplicationId = nil;
    
    if (facebookApplicationId == nil)
    {
        facebookApplicationId = [[[PCConfig padCMSConfig] 
                                     objectForKey:PCConfigFacebookId] retain]; 
    }
    
    return facebookApplicationId;
}

+(NSURL*)serverURL
{
    static NSURL* serverURL = nil;
    if (serverURL == nil)
    {
        NSString* serverURLString = [[self padCMSConfig] objectForKey:PCConfigServerURLKey] ;
        serverURL = [[NSURL URLWithString:serverURLString] retain]; 
    }
    return serverURL;
}

+(NSString*)serverURLString
{
    return [[self padCMSConfig] objectForKey:PCConfigServerURLKey];
}

+(BOOL)useSandBox
{
    static NSNumber* useSandBoxNumber = 0;
    if (useSandBoxNumber == nil)
    {
        useSandBoxNumber = [[[self padCMSConfig] objectForKey:PCConfigUseSandBoxKey] retain]; 
        if (useSandBoxNumber == nil)
        {
            useSandBoxNumber = [[NSNumber numberWithBool:NO] retain];
        }
    }
    return [useSandBoxNumber boolValue];
}

+(NSArray*)subscriptions
{
  static NSArray* subscriptionsArray = nil;
  if (subscriptionsArray == nil)
  {
    subscriptionsArray = [[self padCMSConfig] objectForKey:PCConfigSubscriptions] ;
    if (subscriptionsArray == nil)
      NSLog(@"WARNING! Please add 'PCConfigSubscriptions' dictionary to 'PADCMSConfig' in Info.plist file");
  }
  return subscriptionsArray;
}

+(BOOL)useNewsstand
{
  static NSNumber* useNewsstandNumber = 0;
  if (useNewsstandNumber == nil)
  {
    useNewsstandNumber = [[[self padCMSConfig] objectForKey:PCConfigUseNewsstand] retain]; 
    if (useNewsstandNumber == nil)
    {
      useNewsstandNumber = [[NSNumber numberWithBool:NO] retain];
    }
  }
  return [useNewsstandNumber boolValue];
}

+(NSDictionary*)defaultStyleSheet
{
    static NSDictionary* defaultStyleSheet = nil;
    if (defaultStyleSheet == nil)
    {
        defaultStyleSheet = [[self padCMSConfig] objectForKey:PCStyleSheetKey] ;
        if (defaultStyleSheet == nil)
            NSLog(@"WARNING! Please add 'PCStyleSheet' dictionary to 'PADCMSConfig' in Info.plist file");
    }
    return defaultStyleSheet;
}

+ (BOOL)IsDisableSearching
{
    static NSNumber* disableSearchingNumber = 0;
    if (disableSearchingNumber == nil)
    {
        disableSearchingNumber = [[[self padCMSConfig] objectForKey:PCConfigDisableSearchingKey] retain]; 
        if (disableSearchingNumber == nil)
        {
            disableSearchingNumber = [[NSNumber numberWithBool:NO] retain];
        }
    }
    return [disableSearchingNumber boolValue];
}

+(KiosqueType)getKiosqueType
{
	static NSNumber* type = 0;
    if (type == nil)
    {
        type = [[[self padCMSConfig] objectForKey:PCConfigKiosqueType] retain]; 
    }
    return [type intValue];
	
}

+ (BOOL)isScrollViewScrollButtonsDisabled
{
    static NSNumber *isScrollViewScrollButtonsDisabled = nil;
    if (isScrollViewScrollButtonsDisabled == nil) {
        isScrollViewScrollButtonsDisabled = [[[self padCMSConfig] 
                                              objectForKey:PCScrollViewScrollButtonsDisabled] retain]; 
        if (isScrollViewScrollButtonsDisabled == nil) {
            isScrollViewScrollButtonsDisabled = [[NSNumber numberWithBool:NO] retain];
        }
    }
    
    return [isScrollViewScrollButtonsDisabled boolValue];
}

@end
