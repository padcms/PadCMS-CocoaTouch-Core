//
//  PCPageElementHtml5.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
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
