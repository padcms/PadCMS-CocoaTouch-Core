//
//  PCPageElemetBody.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementDragAndDrop.h"

@implementation PCPageElementDragAndDrop

@synthesize video;
@synthesize thumbnail;
@synthesize thumbnailSelected;
@synthesize topArea;

- (void)dealloc
{
    [video release];
    video = nil;
    [thumbnail release];
    thumbnail = nil;
    [thumbnailSelected release];
    thumbnailSelected = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        video = nil;
        thumbnail = nil;
        thumbnailSelected = nil;
        topArea = -1;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    self.video = [data objectForKey:PCSQLiteElementVideoAttributeName];    

    self.thumbnail = [data objectForKey:PCSQLiteElementThumbnailAttributeName];
    self.thumbnailSelected = [data objectForKey:PCSQLiteElementThumbnailSelectedAttributeName];
    self.topArea = [[data objectForKey:PCSQLiteElementTopAreaAttributeName] integerValue];
}

@end
