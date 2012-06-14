//
//  PCPDFActiveZone.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageActiveZone.h"

@implementation PCPageActiveZone

@synthesize rect;
@synthesize URL;

- (void)dealloc
{
    [URL release], URL = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        URL = nil;
        rect = CGRectZero;
    }
    return self;
}

- (id)initWithRect:(CGRect)aRect URL:(NSString*)aURL
{
    self = [self init];
    if (self)
    {
        rect = aRect;
        self.URL = aURL;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ {%@ ,%@}", [super description], NSStringFromCGRect(rect), self.URL];
}

@end