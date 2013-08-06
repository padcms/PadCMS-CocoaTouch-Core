//
//  RssEnclosure.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssEnclosure.h"

@implementation RssEnclosure

@synthesize url, length, MIMEType;

- (NSString*)stringFromAttributes
{
    NSString* attrString = @"";
    if (url) {
        attrString = [NSString stringWithFormat:@" url=\"%@\"", self.url];
    }
    if (length) {
        attrString = [attrString stringByAppendingFormat:@" length=\"%d\"", self.length];
    }
    if (MIMEType) {
        attrString = [attrString stringByAppendingFormat:@" type=\"%@\"", self.MIMEType];
    }    
    return attrString;
}

- (void)setAtributes:(NSDictionary*)attributes
{
    self.url = [attributes valueForKey:@"url"];
    if ([attributes valueForKey:@"length"]) {
        self.length = [[attributes valueForKey:@"length"] integerValue];
    } else {
        self.length = 0;
    }    
    self.MIMEType = [attributes valueForKey:@"type"];
    
}

- (void)dealloc
{
    if (url) {
        [url release];
    }
    if (MIMEType) {
        [MIMEType release];
    }    
    [super dealloc];
}

@end
