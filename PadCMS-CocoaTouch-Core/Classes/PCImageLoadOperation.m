//
//  PCImageLoadOperation.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 8/10/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCImageLoadOperation.h"
#import "PCPageElement.h"

@implementation PCImageLoadOperation
@synthesize operationElement=_operationElement;
@synthesize tileIndex=_tileIndex;

-(void)dealloc
{
	[_operationElement release], _operationElement = nil;
	[_tileIndex release], _tileIndex = nil;
	[super dealloc];
}

@end
