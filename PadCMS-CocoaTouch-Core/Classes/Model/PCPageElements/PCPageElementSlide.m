//
//  PCPageElementSlide.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementSlide.h"

@implementation PCPageElementSlide

@synthesize video;

- (void)dealloc
{
    [video release];
    video = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        video = nil;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    self.video = [data objectForKey:PCSQLiteElementVideoAttributeName];
}

@end
