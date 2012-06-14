//
//  PCPageElementBody.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementBody.h"

@implementation PCPageElementBody

@synthesize hasPhotoGalleryLink;
@synthesize showTopLayer;
@synthesize top;

- (id)init
{
    if (self = [super init])
    {
        hasPhotoGalleryLink = NO;
        showTopLayer = NO;
        top = -1;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    
    if ([data objectForKey:PCSQLiteElementShowTopLayerAttributeName])
        self.showTopLayer = [[data objectForKey:PCSQLiteElementShowTopLayerAttributeName] boolValue];
    
    if ([data objectForKey:PCSQLiteElementHasPhotoGalleryLinkAttributeName])
        self.hasPhotoGalleryLink = [[data objectForKey:PCSQLiteElementHasPhotoGalleryLinkAttributeName] boolValue];   
   
    if ([data objectForKey:PCSQLiteElementTopAttributeName])
        self.top = [[data objectForKey:PCSQLiteElementTopAttributeName] integerValue];
}

-(NSString*)description
{
    return [[super description] stringByAppendingFormat:@"\rshowTopLayer=%d\rhasPhotoGalleryLink=%d\rtop=%d\r",self.showTopLayer,self.hasPhotoGalleryLink,self.top];
}

@end
