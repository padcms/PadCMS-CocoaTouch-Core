//
//  RssChannel.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssChannel.h"
#import "RssItem.h"
#import "RssElementFactory.h"

@implementation RssChannel

@synthesize items, title, elementDescription, language, copyright, managingEditor, webMaster, pubDate, lastBuildDate, category, generator, docs, cloud, ttl, image, textInput, rating, skipHours, skipDays;

-(id)initWithParent:(RssElement*)_parent name:(NSString*)_name
{
    self = [super initWithParent:_parent name:_name];
    if (self) {
        items = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}


- (NSString*)stringBody
{
    NSString* xmlElementString = [super stringBody];
 
    if (title) {
        xmlElementString = [xmlElementString stringByAppendingString:[title stringFromElement]];
    }
    if (elementDescription) {
        xmlElementString = [xmlElementString stringByAppendingString:[elementDescription stringFromElement]];
    }
    if (language) {
        xmlElementString = [xmlElementString stringByAppendingString:[language stringFromElement]];
    }
    if (copyright) {
        xmlElementString = [xmlElementString stringByAppendingString:[copyright stringFromElement]];
    }
    if (managingEditor) {
        xmlElementString = [xmlElementString stringByAppendingString:[managingEditor stringFromElement]];
    }
    if (webMaster) {
        xmlElementString = [xmlElementString stringByAppendingString:[webMaster stringFromElement]];
    }
    if (pubDate) {
        xmlElementString = [xmlElementString stringByAppendingString:[pubDate stringFromElement]];
    }
    if (lastBuildDate) {
        xmlElementString = [xmlElementString stringByAppendingString:[lastBuildDate stringFromElement]];
    }
    if (category) {
        xmlElementString = [xmlElementString stringByAppendingString:[category stringFromElement]];
    }
    if (generator) {
        xmlElementString = [xmlElementString stringByAppendingString:[generator stringFromElement]];
    }
    if (docs) {
        xmlElementString = [xmlElementString stringByAppendingString:[generator stringFromElement]];
    }
    if (cloud) {
        xmlElementString = [xmlElementString stringByAppendingString:[cloud stringFromElement]];
    }
    if (ttl) {
        xmlElementString = [xmlElementString stringByAppendingString:[ttl stringFromElement]];
    }
    if (image) {
        xmlElementString = [xmlElementString stringByAppendingString:[image stringFromElement]];
    }
    if (textInput) {
        xmlElementString = [xmlElementString stringByAppendingString:[textInput stringFromElement]];
    }
    if (rating) {
        xmlElementString = [xmlElementString stringByAppendingString:[rating stringFromElement]];
    }
    if (skipHours) {
       xmlElementString = [xmlElementString stringByAppendingString:[skipHours stringFromElement]];
    }
    if (skipDays) {
        xmlElementString = [xmlElementString stringByAppendingString:[skipDays stringFromElement]];
    }
    
    for (RssItem* item in self.items) {
        xmlElementString = [xmlElementString stringByAppendingString:[item stringFromElement]];
    }
   
    return xmlElementString;    
    
}

- (BOOL)setChildElement:(RssElement*)element
{
    if ([element.elementName isEqualToString:RSS_TITLE]) {
        self.title = element;
    } else if ([element.elementName isEqualToString:RSS_DESCRIPTION]) {
        self.elementDescription = element;
    } else if ([element.elementName isEqualToString:RSS_LANGUAGE]) {
        self.language = element;
    } else if ([element.elementName isEqualToString:RSS_COPYRIGHT]) {
        self.copyright = element;
    } else if ([element.elementName isEqualToString:RSS_MANAGING_EDITOR]) {
        self.managingEditor = element;
    } else if ([element.elementName isEqualToString:RSS_WEB_MASTER]) {
        self.webMaster = element;
    } else if ([element.elementName isEqualToString:RSS_PUBDATE]) {
        self.pubDate = (RssDate*)element;
    } else if ([element.elementName isEqualToString:RSS_LASTBUILDDATE]) {
        self.lastBuildDate = (RssDate*)element;
    } else if ([element.elementName isEqualToString:RSS_CATHEGORY]) {
        self.category = (RssCategory*)element;
    } else if ([element.elementName isEqualToString:RSS_GENERATOR]) {
        self.generator = element;
    } else if ([element.elementName isEqualToString:RSS_DOCS]) {
        self.docs = element;
    } else if ([element.elementName isEqualToString:RSS_CLOUD]) {
        self.cloud = (RssCloud*)element;
    } else if ([element.elementName isEqualToString:RSS_TTL]) {
        self.ttl = (RssNumber*)element;
    } else if ([element.elementName isEqualToString:RSS_IMAGE]) {
        self.image = (RssImage*)element;
    } else if ([element.elementName isEqualToString:RSS_TEXTINPUT]) {
        self.textInput = (RssTextInput*)element;
    } else if ([element.elementName isEqualToString:RSS_RATING]) {
        self.rating = element;
    } else if ([element.elementName isEqualToString:RSS_SKIP_HOURS]) {
        self.skipHours = (RssNumber*)element;
    } else if ([element.elementName isEqualToString:RSS_SKIP_DAYS]) {
        self.skipDays = (RssNumber*)element;
    }
    return NO;
}



-(void)dealloc
{
    [items release]; 
    if (title) {
        [title release];
    }
    if (elementDescription) {
        [elementDescription release];
    }
    if (language) {
        [language release];
    }
    if (copyright) {
        [copyright release];
    }
    if (managingEditor) {
        [managingEditor release];
    }
    if (webMaster) {
        [webMaster release];
    }
    if (pubDate) {
        [pubDate release];
    }
    if (lastBuildDate) {
        [lastBuildDate release];
    }
    if (category) {
        [category release];
    }
    if (generator) {
        [generator release];
    }
    if (docs) {
        [docs release];
    }
    if (cloud) {
        [cloud release];
    }
    if (ttl) {
        [ttl release];
    }
    if (image) {
        [image release];
    }
    if (textInput) {
        [textInput release];
    }
    if (rating) {
        [rating release];
    }
    if (skipHours) {
        [skipHours release];
    }
    if (skipDays) {
        [skipDays release];
    }
    [super dealloc];
}

@end
