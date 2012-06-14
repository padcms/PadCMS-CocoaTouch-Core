//
//  RssNumber.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssNumber.h"

@implementation RssNumber

- (NSNumber*)number
{
    if (!self.text) {
        return nil;
    }
  
    return [NSNumber numberWithInt:[self.text intValue]];
}

@end
