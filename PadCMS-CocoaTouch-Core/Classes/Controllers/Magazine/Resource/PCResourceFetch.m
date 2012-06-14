
#import "PCResourceFetch.h"
#import "PCResourceCache.h"
#import "PCResourceView.h"

#import <ImageIO/ImageIO.h>

@implementation PCResourceFetch

#pragma mark Properties

@synthesize isBadQuality;

#pragma mark PCResourceFetch instance methods

- (id)initWithRequest:(PCResourceLoadRequest *)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init]))
	{
		request = [object retain];
        
        isBadQuality = NO;
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (request.resourceView.operation == self)
	{
		request.resourceView.operation = nil; // Done
	}

	[request release], request = nil;

	[super dealloc];
}

- (void)cancel
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[[PCResourceCache sharedInstance] removeNullForKey:request.fileURL];

	[super cancel];
}

- (void)main
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.isCancelled == YES) return;

	[[NSThread currentThread] setName:@"PCResourceFetch"];

    NSString *resourceString = nil;
    CGImageRef imageRef = NULL;
    
    if (isBadQuality)
    {
        resourceString = request.fileBadQualityURL;
    }
    else
    {
        resourceString = request.fileURL;
    }
    
    if (resourceString == nil) return;
    
    NSURL *resourceURL = [NSURL fileURLWithPath:resourceString];

	CGImageSourceRef loadRef = CGImageSourceCreateWithURL((CFURLRef)resourceURL, NULL);

	if (loadRef != NULL) // Load the existing thumb image
	{
		imageRef = CGImageSourceCreateImageAtIndex(loadRef, 0, NULL); // Load it

		CFRelease(loadRef); // Release CGImageSource reference
	}
    
	if (imageRef != NULL) // Create UIImage from CGImage and show it
	{
		UIImage *image = [UIImage imageWithCGImage:imageRef];

		CGImageRelease(imageRef); // Release the CGImage reference from the above thumb load code

		[[PCResourceCache sharedInstance] setObject:image forKey:resourceString]; // Update cache

		if (self.isCancelled == NO) // Show the image in the target resource view on the main thread
		{
			PCResourceView *resourceView = request.resourceView; // Target resource view for image show

			NSUInteger targetTag = request.targetTag; // Target reference tag for image show
            
			dispatch_async(dispatch_get_main_queue(), // Queue image show on main thread
			^{
				if (resourceView.targetTag == targetTag) [resourceView showImage:image];
                
			});
		}
	}
    
    //TODO mb move to dispatch_async block after setting image
    if(isBadQuality)
    {
        [[PCResourceCache sharedInstance] resourceLoadGoodQualityRequest:request];
    }
}

- (BOOL)isContainObject:(id)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    return (request.resourceView == object);
}

@end
