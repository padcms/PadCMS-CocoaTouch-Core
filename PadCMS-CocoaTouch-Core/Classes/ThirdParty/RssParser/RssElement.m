//
//  RssElement.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElement.h"
#import "NSString+XMLEntities.h"


@implementation RssElement

@synthesize parent;
@synthesize elementName;
@synthesize text;
@synthesize CDATA;

-(id)initWithParent:(RssElement*)_parent name:(NSString*)_name
{
    self = [super init];
    if (self) {
        parent = [_parent retain];
        elementName = [_name retain];
    }
    return self;
}

- (NSString*)stringFromAttributes
{
    return @"";
}

- (NSString*)stringOpenTag
{
    //NSLog(@"elementName = %@", elementName);
    return [NSString stringWithFormat:OPENTAG_TEMPLATE_WITH_ATTRIBUTES, elementName, [self stringFromAttributes]];
}

- (NSString*)stringBody
{
    NSString* bodyString = [self.text stringByEncodingXMLEntities];
    
    if (CDATA) {
        bodyString = [bodyString stringByAppendingFormat:CDATA_TEMPLATE, CDATA];
    }   
    
    return bodyString;
}

- (NSString*)stringFromElement
{
    NSString* xmlElementString = [self stringOpenTag];
    
    xmlElementString = [xmlElementString stringByAppendingString:[self stringBody]];
    
    xmlElementString = [xmlElementString stringByAppendingFormat:CLOSEDTAG_TEMPLATE, elementName];
    
    return xmlElementString;    
    
}

- (BOOL)setChildElement:(RssElement*)element
{
    return NO;
}

- (void)setAtributes:(NSDictionary*)attributes
{
    
}

-(void)dealloc
{
    if (parent) {
        [parent release];
    }
    if (text) {
        [text release];
    }
    if (elementName) {
        [elementName release];
    }
    if (CDATA) {
        [CDATA release];
    }
    [super dealloc];
}

@end
