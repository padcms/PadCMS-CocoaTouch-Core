//
//  PCElementHTML5RssNewsDownloadOperation.h
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCElementHTML5DownloadOperation.h"
#import "RssParserDelegate.h"

@class RssChannel, RssParser;

@interface PCElementHTML5RssNewsDownloadOperation : PCElementHTML5DownloadOperation <RssParserDelegate>
{
    BOOL isOldXmlParsing, isNewXmlParsing;
    RssParser *oldRssParser, *newRssParser;
    BOOL isEndParsing;
    
}

@property (nonatomic, readonly) RssChannel* rssChannel;

@end
