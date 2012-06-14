//
//  RssElementFactory.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RSS_CHANNEL @"channel"
#define RSS_TITLE @"title"
#define RSS_LINK @"link"
#define RSS_DESCRIPTION @"description"
#define RSS_LANGUAGE @"language"
#define RSS_COPYRIGHT @"copyright"
#define RSS_MANAGING_EDITOR @"managingEditor"
#define RSS_WEB_MASTER @"webMaster"
#define RSS_PUBDATE @"pubDate"
#define RSS_LASTBUILDDATE @"lastBuildDate"
#define RSS_CATHEGORY @"category"
#define RSS_GENERATOR @"generator"
#define RSS_DOCS @"docs"
#define RSS_CLOUD @"cloud"
#define RSS_TTL @"ttl"
#define RSS_IMAGE @"image"
#define RSS_RATING @"rating"
#define RSS_TEXTINPUT @"textInput"
#define RSS_SKIP_HOURS @"skipHours"
#define RSS_SKIP_DAYS @"skipDays"
#define RSS_URL @"url"
#define RSS_WIDTH @"width"
#define RSS_HEIGHT @"height"
#define RSS_NAME @"name"
#define RSS_ITEM @"item"
#define RSS_AUTHOR @"author"
#define RSS_COMMENTS @"comments"
#define RSS_ENCLOSURE @"enclosure"
#define RSS_GUID @"guid"
#define RSS_SOURCE @"source"
#define RSS_DC_CREATOR @"dc:creator"

@class RssElement;

@interface RssElementFactory : NSObject

+(RssElement*)elementWithName:(NSString*)name atributes:(NSDictionary*)attributes forParent:(RssElement*)parent;

@end
