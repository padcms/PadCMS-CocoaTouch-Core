//
//  RssSource.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssSource.h"

@implementation RssSource

@synthesize url;

- (NSString*)stringFromAttributes
{
    if (!self.url) {
        return @"";
    }
    return [NSString stringWithFormat:@"url = \"%@\"", self.url];
}

- (void)setAtributes:(NSDictionary*)attributes
{
    self.url = [attributes valueForKey:@"url"];
}

- (void)dealloc
{
    if (url) {
        [url release];
    }
    [super dealloc];
}

@end
