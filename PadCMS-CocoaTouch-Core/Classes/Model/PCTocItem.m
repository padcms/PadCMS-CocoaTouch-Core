//
//  PCTocItem.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCTocItem.h"
#import "PCDataHelper.h"

NSString* endOfDownloadingTocNotification = @"endOfDownloadingTocNotification";

@implementation PCTocItem

@synthesize title; 
@synthesize tocItemDescription; 
@synthesize color; 
@synthesize thumbStripe; 
@synthesize thumbSummary; 
@synthesize firstPageIdentifier;

- (void)dealloc
{
    [title release];
    title = nil;
    [tocItemDescription release];
    tocItemDescription = nil;
    [color release];
    color = nil;
    [thumbStripe release];
    thumbStripe = nil;
    [thumbSummary release];
    thumbSummary = nil;
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        firstPageIdentifier = -1;
        title = nil; 
        tocItemDescription = nil; 
        color = nil; 
        thumbStripe = nil; 
        thumbSummary = nil; 
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"PCTocItem\r title=%@\r description=%@\r color=%@\r thumbStripe=%@\r thumbSummary=%@\r firstPageIdentifier=%d\r",self.title,self.tocItemDescription,self.color,self.thumbStripe,self.thumbSummary,self.firstPageIdentifier];
}

@end
