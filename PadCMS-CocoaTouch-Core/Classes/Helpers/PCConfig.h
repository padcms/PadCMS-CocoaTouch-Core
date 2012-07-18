//
//  PCConfig.h
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

#import <Foundation/Foundation.h>


typedef enum _KiosqueType {
	KiosqueTypeDefault = 0,
	KiosqueTypeAirDccv = 1
} KiosqueType;

/**
 @class PCConfig
 @brief Per app configuration management class
 */
@interface PCConfig : NSObject

/**
 @brief returns YES if the app should hide scroll buttons in all PCScrollView instances  
 */
+ (BOOL)isScrollViewScrollButtonsDisabled;

/**
 @brief returns YES if PCHorizontalScrollingPageViewController instances should disable scroll buttons
 */
+ (BOOL)isScrollingPageHorizontalScrollButtonsDisabled;

/**
 @brief returns YES if PCScrollingPageViewController instances should disable scroll buttons
 */
+ (BOOL)isScrollingPageVerticalScrollButtonsDisabled;

/**
 @brief returns YES if search ability should be disabled 
 */
+ (BOOL)isSearchDisabled;

/**
 @brief returns YES if the app should use Nesstand feature
 */
+ (BOOL)useNewsstand;

/**
 @brief returns kiosque type for current app
 */
+ (KiosqueType)kiosqueType;

/**
 @brief subscriptions list
 */
+ (NSArray *)subscriptions;

/**
 @brief default style sheet for styling current app
 */
+ (NSDictionary *)defaultStyleSheet;

/**
 @brief application identifier number
 */
+ (NSInteger)applicationIdentifier;

/**
 @brief client identifier number
 */
+ (NSInteger)clientIdentifier;

/**
 @brief application id to be used for sharing in Facebook API 
 */
+ (NSString *)facebookApplicationId;

/**
 @brief account id to be used for page views tracking in Google Analytics API
 */
+ (NSString *)googleAnalyticsAccountId;

/**
 @brief PadCMS backend server url string
 */
+ (NSString *)serverURLString;

/**
 @brief PadCMS backend server url string 
 */
+ (NSURL *)serverURL;

/**
 @brief InAppPurchases shared secret key
 */
+ (NSString *)sharedSecretKey;

@end
