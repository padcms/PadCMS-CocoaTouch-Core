
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
