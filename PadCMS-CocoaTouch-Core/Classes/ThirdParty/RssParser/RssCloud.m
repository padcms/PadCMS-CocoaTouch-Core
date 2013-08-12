//
//  RssCloud.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssCloud.h"

@implementation RssCloud

@synthesize domain, port, path, registerProcedure, protocol;

- (NSString*)stringFromAttributes
{
    NSString* attrString = @"";
    if (domain) {
        attrString = [attrString stringByAppendingFormat:@" domain=\"%@\"", self.domain];
    }
    if (port) {
        attrString = [attrString stringByAppendingFormat:@" port=\"%d\"", self.port];
    }
    if (path) {
        attrString = [attrString stringByAppendingFormat:@" path=\"%@\"", self.path];
    }
    if (registerProcedure) {
        attrString = [attrString stringByAppendingFormat:@" registerProcedure=\"%@\"", self.registerProcedure];
    }
    if (protocol) {
        attrString = [attrString stringByAppendingFormat:@" protocol=\"%@\"", self.protocol];
    }
    return attrString;
}

- (void)setAtributes:(NSDictionary*)attributes
{
    self.domain = [attributes valueForKey:@"domain"];
    if ([attributes valueForKey:@"port"]) {
        self.port = [[attributes valueForKey:@"port"] integerValue];
    } else {
        self.port = 0;
    }    
    self.registerProcedure = [attributes valueForKey:@"registerProcedure"];
    self.protocol = [attributes valueForKey:@"protocol"];
    
}

- (void)dealloc
{
    if (domain) {
        [domain release];
    }
    if (registerProcedure) {
        [registerProcedure release];
    }
    if (protocol) {
        [protocol release];
    }    
    [super dealloc];
}


@end
