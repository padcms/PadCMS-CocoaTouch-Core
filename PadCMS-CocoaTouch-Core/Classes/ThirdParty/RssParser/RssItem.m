//
//  RssItem.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssItem.h"
#import "RssElementFactory.h"
#import "RssEnclosure.h"
#import "RssDate.h"

@implementation RssItem

@synthesize  title, elementDescription, link, author, category, enclosures, guid, pubDate, source;

-(id)initWithParent:(RssElement*)_parent name:(NSString*)_name
{
    self = [super initWithParent:_parent name:_name];
    if (self) {
        self.enclosures = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
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
    if (link) {
        xmlElementString = [xmlElementString stringByAppendingString:[link stringFromElement]];
    }
    if (author) {
        xmlElementString = [xmlElementString stringByAppendingString:[author stringFromElement]];
    }
    if (pubDate) {
        xmlElementString = [xmlElementString stringByAppendingString:[pubDate stringFromElement]];
    }
    if (category) {
        xmlElementString = [xmlElementString stringByAppendingString:[category stringFromElement]];
    }
    if (guid) {
        xmlElementString = [xmlElementString stringByAppendingString:[guid stringFromElement]];
    }
    if (source) {
        xmlElementString = [xmlElementString stringByAppendingString:[source stringFromElement]];
    }    
    
    for (RssEnclosure* enclosure in self.enclosures) {
        xmlElementString = [xmlElementString stringByAppendingString:[enclosure stringFromElement]];
    }
    
    return xmlElementString;    
    
}

- (BOOL)setChildElement:(RssElement*)element
{
    if ([element.elementName isEqualToString:RSS_TITLE]) {
        self.title = element;
    } else if ([element.elementName isEqualToString:RSS_DESCRIPTION]) {
        self.elementDescription = element;
    } else if ([element.elementName isEqualToString:RSS_PUBDATE]) {
        self.pubDate = (RssDate*)element;
    } else if ([element.elementName isEqualToString:RSS_LINK]) {
        self.link = element;
    } else if ([element.elementName isEqualToString:RSS_CATHEGORY]) {
        self.category = (RssCategory*)element;
    } else if ([element.elementName isEqualToString:RSS_AUTHOR]||[element.elementName isEqualToString:RSS_DC_CREATOR]) {
        self.author = element;
    } else if ([element.elementName isEqualToString:RSS_GUID]) {
        self.guid = (RssGuid*)element;
    } else if ([element.elementName isEqualToString:RSS_SOURCE]) {
        self.source = (RssSource*)element;
    }
    return NO;
}



-(void)dealloc
{
    [enclosures release]; 
    if (title) {
        [title release];
    }
    if (elementDescription) {
        [elementDescription release];
    }
    if (link) {
        [link release];
    }
    if (author) {
        [author release];
    }
    if (pubDate) {
        [pubDate release];
    }
    if (category) {
        [category release];
    }
    if (guid) {
        [guid release];
    }
    if (source) {
        [source release];
    }
    [super dealloc];
}

- (BOOL)isEqualRssItem:(RssItem*)item
{
    BOOL isEqual = YES;
    if (item.title&&self.title) {
        isEqual = isEqual && [item.title.text isEqualToString:self.title.text]; 
    }
    if (item.elementDescription&&self.elementDescription) {
        isEqual = isEqual && [item.elementDescription.text isEqualToString:self.elementDescription.text]; 
    }
    if (item.link&&self.link) {
        isEqual = isEqual && [item.link.text isEqualToString:self.link.text]; 
    }
    if (item.pubDate&&self.pubDate) {
        isEqual = isEqual && [item.pubDate.date isEqualToDate:self.pubDate.date]; 
    }
    return isEqual;
}

@end
