//
//  PCPageElementGallery.m
//  Pad CMS
//
//  Created by admin on 28.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementGallery.h"

@implementation PCPageElementGallery

@synthesize galleryID = _galleryID;

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _galleryID = -1;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    self.galleryID = [[data objectForKey:PCSQLiteElementGalleryIDName] integerValue];    
}

@end
