//
//  RssGuid.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssGuid.h"

@implementation RssGuid

@synthesize isPermaLink;

- (id)initWithParent:(RssElement *)_parent name:(NSString *)_name
{
    self = [super initWithParent:_parent name:_name];
    if (self) {
        isPermaLink = YES;
    }
    
    return self;
}

- (NSString*)stringFromAttributes
{
    NSString* attrString = @"";
    if (isPermaLink) {
        attrString = [attrString stringByAppendingString:@" isPermaLink=\"true\""];
    } else {
        attrString = [attrString stringByAppendingString:@" isPermaLink=\"false\""]; 
    }    
    return attrString;
}

- (void)setAtributes:(NSDictionary*)attributes
{
    NSString* attrString = [attributes valueForKey:@"isPermaLink"];
    if (!attrString||[attrString isEqualToString:@"true"]) {
        isPermaLink = YES;
    } else {
        isPermaLink = NO;
    }
}

@end
