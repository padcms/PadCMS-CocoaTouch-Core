//
//  RRItemsViewItem.m
//  ReusingScrollViewDemo
//
//  Created by Maxim Pervushin on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PCGridViewCell.h"

#import "PCGridViewIndex.h"

@implementation PCGridViewCell
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _index = nil;
    }
    return self;
}

- (void)clearContent
{
    // empty
}

@end
