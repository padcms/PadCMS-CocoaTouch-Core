//
//  PCSearchResultItem.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 01.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSearchResultItem.h"

@implementation PCSearchResultItem
@synthesize issueTitle, pageTitle;
@synthesize revisionIdentifier;
@synthesize pageIndex;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.issueTitle = nil;
        self.pageTitle = nil;
        self.revisionIdentifier = -1;
        self.pageIndex = -1;
    }
    
    return self;
}

-(id) initWithIssueTitle:(NSString*) _issueTitle
            andPageTitle:(NSString*) _pageTitle
   andRevisionIdentifier:(NSInteger) _revisionIdentifier
            andPageIndex:(NSInteger) _pageIndex;
{
    self = [super init];
    if (self)
    {
        self.issueTitle = _issueTitle;
        self.pageTitle = _pageTitle;
        self.revisionIdentifier = _revisionIdentifier;
        self.pageIndex = _pageIndex;
    }
    return self;
}

- (void)dealloc
{
    self.issueTitle = nil;
    self.pageTitle = nil;
    [super dealloc];
}

@end
