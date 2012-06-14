//
//  PCDownloadOperation.m
//  Pad CMS
//
//  Created by Alexey Petrosyan on 5/11/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCDownloadOperation.h"

@implementation PCDownloadOperation
@synthesize page, element, resource, isPrimary, isThumbnail, horizontalPageKey;

-(void)dealloc
{
  page = nil;
  element = nil;
  horizontalPageKey = nil;
  [resource release];
  [super dealloc];
   
  
}

@end
