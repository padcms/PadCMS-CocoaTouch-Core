//
//  PCPageElementVidio.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementVideo.h"

@implementation PCPageElementVideo

@synthesize stream;

- (void)dealloc
{
    [stream release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        stream = nil;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    self.stream = [data objectForKey:PCSQLiteElementStreamAttributeName];
}

@end
