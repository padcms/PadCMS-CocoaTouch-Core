//
//  PCPageElementScrollingPane.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementScrollingPane.h"

@implementation PCPageElementScrollingPane

@synthesize top;

- (id)init
{
    if (self = [super init])
    {
        top = -1;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    self.top = [[data objectForKey:PCSQLiteElementTopAttributeName] intValue];
}

@end
