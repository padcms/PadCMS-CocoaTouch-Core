//
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

#import "PCResourceLoadRequest.h"
#import "PCResourceView.h"

@implementation PCResourceLoadRequest

#pragma mark Properties

@synthesize fileURL             = _fileURL;
@synthesize fileBadQualityURL   = _fileBadQualityURL;
@synthesize resourceView        = _resourceView;
@synthesize targetTag           = _targetTag;
@synthesize scale               = _scale;

#pragma mark PCResourceLoadRequest class methods

+ (id)forView:(PCResourceView *)view fileURL:(NSString *)url fileBadQualityURL:(NSString *)urlbq
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [[[PCResourceLoadRequest alloc] initWithView:view fileURL:url fileBadQualityURL:urlbq] autorelease];
}

#pragma mark PCResourceLoadRequest instance methods

- (id)initWithView:(PCResourceView *)view fileURL:(NSString *)url fileBadQualityURL:(NSString *)urlbq
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

    self = [super init];
    
	if (self) // Initialize object
	{
		_resourceView = [view retain];

		_fileURL = [url copy];
        
        _fileBadQualityURL = [urlbq copy];

        _targetTag = [_fileURL hash]; 
        _resourceView.targetTag = _targetTag;
        
        _scale = 1.0f;
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[_fileURL release], _fileURL = nil;
    
    [_fileBadQualityURL release], _fileBadQualityURL = nil;

	[_resourceView release], _resourceView = nil;

	[super dealloc];
}

@end
