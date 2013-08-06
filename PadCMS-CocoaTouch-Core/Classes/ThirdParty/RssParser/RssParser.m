//
//  RssParser.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssParser.h"
#import "RssElementFactory.h"
#import "RssElement.h"
#import "RssChannel.h"

@implementation RssParser

@synthesize target, channel, data;

-(id)initWithTarget:(id<RssParserDelegate>)_target
{
    self = [super init];
    if(self){
        target = _target;
    }
    return self;
}

+(id)parseRssData:(NSData*)data toTarget:(id<RssParserDelegate>)target
{
    RssParser* rssParser = [[RssParser alloc] initWithTarget:target];
    rssParser.data = data;    
    return [rssParser autorelease];
}

- (void)parse
{
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    if (![parser parse]) {
        [target parser:self endParseWithError:[parser parserError]];
    }
}

// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    channel = nil;
    currentElement = nil;
}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [target parser:self endParseRssChanel:channel];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    RssElement* newElement = [RssElementFactory elementWithName:[[elementName copy] autorelease] 
                                                      atributes:attributeDict forParent:currentElement];
    currentElement = newElement;
    foundString = [NSMutableString string];
    currentElement.text = foundString;
    if (!channel) {
        if ([currentElement isKindOfClass:[RssChannel class]]) {
            channel = (RssChannel*)currentElement;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    currentElement.text = foundString;
    currentElement = currentElement.parent;
    if (currentElement) {
        foundString = [NSMutableString stringWithString:currentElement.text];
    } else {
        foundString = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (foundString) {
        [foundString appendString:string];
    }
}

@end
