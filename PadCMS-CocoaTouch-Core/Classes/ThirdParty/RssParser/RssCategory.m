//
//  RssCategory.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssCategory.h"

@implementation RssCategory

@synthesize domain;

- (NSString*)stringFromAttributes
{
    if (!self.domain) {
        return @"";
    }
    return [NSString stringWithFormat:@"domain = \"%@\"", self.domain];
}

- (void)setAtributes:(NSDictionary*)attributes
{
    self.domain = [attributes valueForKey:@"domain"];
}

- (void)dealloc
{
    if (domain) {
        [domain release];
    }
    [super dealloc];
}

@end
