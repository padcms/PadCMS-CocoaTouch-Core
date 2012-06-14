//
//  PCSearchResult.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 01.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSearchResult.h"

@implementation PCSearchResult
@synthesize items;

- (id)init
{
    self = [super init];
    if (self)
    {
        items = nil;
    }
    
    return self;
}

- (void)dealloc
{
    @synchronized (self)
    {
        if(self.items)
        {
            [self.items removeAllObjects];
            self.items = nil;
        }
    }
    [super dealloc];
}

-(void) addResultItem:(PCSearchResultItem*) item
{
    @synchronized (self)
    {
        if(self.items==nil)
        {
            self.items = [[[NSMutableArray alloc] init] autorelease];
        }
        [self.items addObject:item];
    }
}

@end
