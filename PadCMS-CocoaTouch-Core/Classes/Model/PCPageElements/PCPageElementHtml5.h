//
//  PCPageElementHtml5.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElement.h"

PADCMS_EXTERN NSString* PCPageElementHtml5BodyCodeType; ///< Code Type
PADCMS_EXTERN NSString* PCPageElementHtml5BodyGoogleMapsType; ///< Google Maps Type
PADCMS_EXTERN NSString* PCPageElementHtml5BodyRSSFeedType; ///< RSS Feed Type
PADCMS_EXTERN NSString* PCPageElementHtml5BodyFacebookLikeType; ///< Facebook Like Type
PADCMS_EXTERN NSString* PCPageElementHtml5BodyTwitterType; ///< Twitter Type

/**
 @class PCPageElementHtml5
 @brief Represents Html5 element of the page.
 */

@interface PCPageElementHtml5 : PCPageElement
{
    NSInteger html5Position;
    NSString* html5Body;
    NSString* postCode;
    NSString* googleLinkToMap;
    NSString* rssLink;
    NSInteger rssLinkNumber;
    NSString* facebookNamePage;
    NSString* twitterAccount;
    NSInteger twitterTweetNumber;
}

@property (nonatomic,assign) NSInteger html5Position;///< html5 Position
@property (nonatomic,retain) NSString* html5Body;///< The type of html data
@property (nonatomic,retain) NSString* postCode;///< HTML5 code
@property (nonatomic,retain) NSString* googleLinkToMap;///< Link to google map
@property (nonatomic,retain) NSString* rssLink;///< Link to the rss
@property (nonatomic,assign) NSInteger rssLinkNumber;///< Amount of rss links
@property (nonatomic,retain) NSString* facebookNamePage;///< Facebook page name
@property (nonatomic,retain) NSString* twitterAccount;///< Twitter account name
@property (nonatomic,assign) NSInteger twitterTweetNumber;///< Amount of displayed twites

- (NSString*)rssNewsXmlFilePath;
- (NSString*)twitterJSONFilePath;

@end
