//
//  PCPageElementHtml5.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementHtml5.h"

 NSString* PCPageElementHtml5BodyCodeType           = @"code";
 NSString* PCPageElementHtml5BodyGoogleMapsType     = @"google_maps";
 NSString* PCPageElementHtml5BodyRSSFeedType        = @"rss_feed";
 NSString* PCPageElementHtml5BodyFacebookLikeType   = @"facebook_like";
 NSString* PCPageElementHtml5BodyTwitterType        = @"twitter";

@implementation PCPageElementHtml5

@synthesize html5Position;
@synthesize html5Body;
@synthesize postCode;
@synthesize googleLinkToMap;
@synthesize rssLink;
@synthesize rssLinkNumber;
@synthesize facebookNamePage;
@synthesize twitterAccount;
@synthesize twitterTweetNumber;

- (void)dealloc
{
    [html5Body release];
    [postCode release];
    [googleLinkToMap release];
    [rssLink release];
    [facebookNamePage release];
    [twitterAccount release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        html5Position = -1;
        html5Body = nil;
        postCode = nil;
        googleLinkToMap = nil;
        rssLink = nil;
        facebookNamePage = nil;
        twitterAccount = nil;
        twitterTweetNumber = -1;
        rssLinkNumber = -1;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    
    self.html5Position = [[data objectForKey:PCSQLiteElementHtml5PositionAttributeName] integerValue];
    self.html5Body = [data objectForKey:PCSQLiteElementHtml5BodyAttributeName];
    self.postCode = [data objectForKey:PCSQLiteElementPostCodeAttributeName];
    self.googleLinkToMap = [data objectForKey:PCSQLiteElementGoogleLinkToMapAttributeName];
    self.rssLink = [data objectForKey:PCSQLiteElementRSSLinkAttributeName];
    self.rssLinkNumber = [[data objectForKey:PCSQLiteElementRSSLinkNumberAttributeName] integerValue];
    self.facebookNamePage = [data objectForKey:PCSQLiteElementFacebookNameAttributeName];
    self.twitterAccount = [data objectForKey:PCSQLiteElementTwitterAccountAttributeName];
    self.twitterTweetNumber = [[data objectForKey:PCSQLiteElementTwitterTweetNumberAttributeName] integerValue];
}

- (NSString*)rssNewsXmlFilePath
{
    return [NSString stringWithFormat:@"element/RSS/%d/news.xml", self.identifier];
}

- (NSString*)twitterJSONFilePath
{
    return [NSString stringWithFormat:@"element/TwitterLine/%d/twitter.json", self.identifier];
}

@end
