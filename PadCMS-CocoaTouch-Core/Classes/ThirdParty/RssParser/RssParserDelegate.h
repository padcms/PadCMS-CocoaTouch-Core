//
//  RssParserDelegate.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RssParser, RssChannel;
@protocol RssParserDelegate <NSObject>

- (void)parser:(RssParser*)parser endParseRssChanel:(RssChannel*)channel;
- (void)parser:(RssParser *)parser endParseWithError:(NSError*)error;

@end
