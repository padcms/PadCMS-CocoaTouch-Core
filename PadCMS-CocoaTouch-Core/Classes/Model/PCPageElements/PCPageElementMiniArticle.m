//
//  PCPageElementMiniArticle.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementMiniArticle.h"

NSString * const PCMiniArticleElementDidDownloadNotification = @"PCMiniArticleElementDidDownloadNotification";

@implementation PCPageElementMiniArticle

@synthesize video;
@synthesize thumbnail;
@synthesize thumbnailSelected;
@synthesize thumbnailProgress;
@synthesize thumbnailSelectedProgress;

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
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    
    self.video = [data objectForKey:PCSQLiteElementVideoAttributeName];
    self.thumbnail = [data objectForKey:PCSQLiteElementThumbnailAttributeName];
    self.thumbnailSelected = [data objectForKey:PCSQLiteElementThumbnailSelectedAttributeName];
}

@end
