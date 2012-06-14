//
//  PCHorizontalPage.m
//  Pad CMS
//
//  Created by Alexey Petrosyan on 5/7/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCHorizontalPage.h"
#import "PCDownloadProgressProtocol.h"

@implementation PCHorizontalPage
@synthesize identifier=_identifier;
@synthesize downloadProgress=_downloadProgress;
@synthesize progressDelegate=_progressDelegate;
@synthesize isComplete=_isComplete;

- (id)init
{
    if (self = [super init])
    {
        
		_progressDelegate = nil;
		_isComplete = YES;
    }
    return self;
}



-(void)dealloc
{
	_progressDelegate = nil;
	[_identifier release], _identifier = nil;
	[super dealloc];
}

-(void)setDownloadProgress:(float)downloadProgress
{
	_downloadProgress = downloadProgress;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.progressDelegate setProgress:downloadProgress];
	});
}

@end
