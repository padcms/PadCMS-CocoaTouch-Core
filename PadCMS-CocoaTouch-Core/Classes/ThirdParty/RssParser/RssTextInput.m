//
//  RssTextInput.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssTextInput.h"
#import "RssElementFactory.h"

@implementation RssTextInput

@synthesize title, elementDescription, name, link;

- (NSString*)stringBody
{
    NSString* xmlElementString = [super stringBody];
    
    if (title) {
        xmlElementString = [xmlElementString stringByAppendingString:[title stringFromElement]];
    }
    if (elementDescription) {
        xmlElementString = [xmlElementString stringByAppendingString:[elementDescription stringFromElement]];
    }
    if (name) {
        xmlElementString = [xmlElementString stringByAppendingString:[name stringFromElement]];
    }
    if (link) {
        xmlElementString = [xmlElementString stringByAppendingString:[link stringFromElement]];
    }    
    
    return xmlElementString;    
    
}

- (BOOL)setChildElement:(RssElement*)element
{
    if ([element.elementName isEqualToString:RSS_TITLE]) {
        self.title = element;
    } else if ([element.elementName isEqualToString:RSS_DESCRIPTION]) {
        self.elementDescription = element;
    } else if ([element.elementName isEqualToString:RSS_NAME]) {
        self.name = element;
    } else if ([element.elementName isEqualToString:RSS_LINK]) {
        self.link = element;
    }
    return NO;
}



-(void)dealloc
{
    if (title) {
        [title release];
    }
    if (elementDescription) {
        [elementDescription release];
    }
    if (name) {
        [name release];
    }
    if (link) {
        [link release];
    }    
    [super dealloc];
}

@end
