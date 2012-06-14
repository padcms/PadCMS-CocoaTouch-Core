//
//  PCConfig.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCMacros.h"

PADCMS_EXTERN NSString *PCPADCMSConfigKey;
PADCMS_EXTERN NSString *PCConfigServerURLKey;
PADCMS_EXTERN NSString *PCConfigClientIdentifierKey;
PADCMS_EXTERN NSString *PCConfigApplicationIdentifierKey;
PADCMS_EXTERN NSString *PCConfigGANAccountId;
PADCMS_EXTERN NSString *PCConfigUseSandBoxKey;
PADCMS_EXTERN NSString *PCConfigDisableSearchingKey;
PADCMS_EXTERN NSString *PCConfigKiosqueType;
PADCMS_EXTERN NSString *PCConfigFacebookId;
PADCMS_EXTERN NSString *PCScrollViewScrollButtonsDisabled;

typedef enum _KiosqueType {
	PC_KIOSQUE_DEFAULT_TYPE = 0,
	PC_KIOSQUE_AIR_DCCV_TYPE  = 1,
	
} KiosqueType;



@interface PCConfig : NSObject

+ (NSInteger)clientIdentifier;
+ (NSInteger)applicationIdentifier;
+ (NSString *)googleAnalyticsAccountId;
+ (NSURL *)serverURL;
+ (NSString*)serverURLString;
+ (BOOL)useSandBox;
+ (NSDictionary*)defaultStyleSheet;
+ (NSArray*)subscriptions;
+ (BOOL)useNewsstand;
+ (BOOL)IsDisableSearching;
+ (KiosqueType)getKiosqueType;
+ (BOOL)isScrollViewScrollButtonsDisabled;
+ (NSString *)facebookApplicationId;

@end
