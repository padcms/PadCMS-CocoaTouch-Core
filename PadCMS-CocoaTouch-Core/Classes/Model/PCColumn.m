//
//  PCColumn.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCColumn.h"
#import "PCPage.h"

@implementation PCColumn

@synthesize pages;

- (void)dealloc
{
    [pages release];
    [super dealloc];
}

- (id)initWithPages:(NSMutableArray*)aPages
{
    if (self = [super init])
    {
        pages = [aPages retain];
    }
    return self;
}


- (NSString*)description
{
    NSString* discription = NSStringFromClass(self.class);
    discription = [discription stringByAppendingString:@"\r"];

    discription = [discription stringByAppendingFormat:@" pages number in column = %d\r",[self.pages count]];
   
    if (self.pages && [self.pages count] > 0)
    {
        discription = [discription stringByAppendingString:@"pages={"];
        for (PCPage * page in self.pages)
        {
            discription = [discription stringByAppendingString:self.pages.description];
            discription = [discription stringByAppendingString:@",\r"];
        }
        discription = [discription stringByAppendingString:@"}\r"];
    }


    return discription; 
}


@end
