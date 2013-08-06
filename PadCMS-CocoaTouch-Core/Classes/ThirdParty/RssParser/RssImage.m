//
//  RssImage.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssImage.h"
#import "RssElementFactory.h"

@implementation RssImage

@synthesize title, link, url, width, height;

- (NSString*)stringBody
{
    NSString* xmlElementString = [super stringBody];
    
    if (title) {
        xmlElementString = [xmlElementString stringByAppendingString:[title stringFromElement]];
    }
    if (link) {
        xmlElementString = [xmlElementString stringByAppendingString:[link stringFromElement]];
    }
    if (url) {
        xmlElementString = [xmlElementString stringByAppendingString:[url stringFromElement]];
    }
    if (width) {
        xmlElementString = [xmlElementString stringByAppendingString:[width stringFromElement]];
    }
    if (height) {
        xmlElementString = [xmlElementString stringByAppendingString:[height stringFromElement]];
    }    
    
    return xmlElementString;    
    
}

- (BOOL)setChildElement:(RssElement*)element
{
    if ([element.elementName isEqualToString:RSS_TITLE]) {
        self.title = element;
    } else if ([element.elementName isEqualToString:RSS_URL]) {
        self.url = element;
    } else if ([element.elementName isEqualToString:RSS_LINK]) {
        self.link = element;
    } else if ([element.elementName isEqualToString:RSS_WIDTH]) {
        self.width = (RssNumber*)element;
    } else if ([element.elementName isEqualToString:RSS_HEIGHT]) {
        self.height = (RssNumber*)element;
    }
    return NO;
}



-(void)dealloc
{
    if (title) {
        [title release];
    }
    if (url) {
        [url release];
    }
    if (link) {
        [link release];
    }
    if (width) {
        [width release];
    }
    if (height) {
        [height release];
    }
    [super dealloc];
}

@end
