//
//  RssParser.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RssParserDelegate.h"

@class RssChannel, RssElement;
@interface RssParser : NSObject <NSXMLParserDelegate>
{
    RssElement* currentElement;
    NSMutableString* foundString;
}

@property(nonatomic, retain) RssChannel* channel;
@property(nonatomic, readonly) id <RssParserDelegate> target;
@property(nonatomic, retain) NSData* data;

+(id)parseRssData:(NSData*)data toTarget:(id<RssParserDelegate>)target;
- (void)parse;

@end


