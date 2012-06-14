//
//  PCPageElementAdvert.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementAdvert.h"

@implementation PCPageElementAdvert

@synthesize advertDuration;

-(id)init
{
    if (self = [super init])
    {
        advertDuration = 0;
    }
    return self;
}

-(void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    self.advertDuration = [[data objectForKey:PCSQLiteElementAdvertDurationAttributeName] integerValue];
}

@end
