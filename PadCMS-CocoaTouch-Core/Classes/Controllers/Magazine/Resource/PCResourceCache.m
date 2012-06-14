
#import "PCResourceCache.h"
#import "PCResourceQueue.h"
#import "PCResourceFetch.h"
#import "PCResourceView.h"

@implementation PCResourceCache

#pragma mark Constants

#define CACHE_SIZE (30 * 1024 * 1024)

//#pragma mark Properties

//@synthesize ;

#pragma mark PCResourceCache class methods

+ (PCResourceCache *)sharedInstance
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	static dispatch_once_t predicate = 0;

	static PCResourceCache *object = nil; // Object

	dispatch_once(&predicate, ^{ object = [[self alloc] init]; });

	return object; // PCResourceCache singleton
}

#pragma mark PCResourceCache instance methods

- (id)init
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init])) // Initialize
	{
		resourceCache = [[NSCache alloc] init]; // Cache

		[resourceCache setName:@"PCResourceCache"];

		[resourceCache setTotalCostLimit:CACHE_SIZE];
        
        //[resourceCache setEvictsObjectsWithDiscardedContent:YES];
        
        //[resourceCache setDelegate:self];
	}

	return self;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"object = %@", obj);
#endif
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[resourceCache release], resourceCache = nil;

	[super dealloc];
}

- (id)resourceLoadBadQualityRequest:(PCResourceLoadRequest *)request
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    if(request.fileBadQualityURL == nil)
    {
        return [self resourceLoadGoodQualityRequest:request];
    }
    else
    {
        @synchronized(resourceCache) // Mutex lock
        {
            id object = [resourceCache objectForKey:request.fileURL];
            
            if (object == nil) // Resource object does not yet exist in the cache
            {
                object = [resourceCache objectForKey:request.fileBadQualityURL];
                
                if (object == nil)
                {
                    object = [NSNull null]; // Return an NSNull placeholder object
                    
                    [resourceCache setObject:object forKey:request.fileBadQualityURL cost:2]; // Cache the placeholder object
                    
                    // Create a resource fetch operation
                    PCResourceFetch *resourceFetch = [[PCResourceFetch alloc] initWithRequest:request];
                    
                    resourceFetch.isBadQuality = YES;
                    
                    [resourceFetch setQueuePriority:NSOperationQueuePriorityNormal]; // Queue priority
                    
                    request.resourceView.operation = resourceFetch; [resourceFetch setThreadPriority:0.55]; // Thread priority
                    
                    [[PCResourceQueue sharedInstance] addLoadOperation:resourceFetch]; [resourceFetch release]; // Queue the operation
                }
                else
                {
                    [self resourceLoadGoodQualityRequest:request];
                }
            }
            
            return object; // NSNull or UIImage
        }
    }
}

- (id)resourceLoadGoodQualityRequest:(PCResourceLoadRequest *)request
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    @synchronized(resourceCache) // Mutex lock
    {
        id object = [resourceCache objectForKey:request.fileURL];
        
        if (object == nil) // Resource object does not yet exist in the cache
        {
            object = [NSNull null]; // Return an NSNull placeholder object
            
            [resourceCache setObject:object forKey:request.fileURL cost:2]; // Cache the placeholder object
            
            // Create a resource fetch operation
            PCResourceFetch *resourceFetch = [[PCResourceFetch alloc] initWithRequest:request];
            
            [resourceFetch setQueuePriority:NSOperationQueuePriorityLow]; // Queue priority
            
            request.resourceView.operation = resourceFetch; [resourceFetch setThreadPriority:0.35]; // Thread priority
            
            [[PCResourceQueue sharedInstance] addLoadOperation:resourceFetch]; [resourceFetch release]; // Queue the operation
        }
        
        return object; // NSNull or UIImage
    }
}

- (id)resourceLoadRequestImmediate:(PCResourceLoadRequest *)request
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	@synchronized(resourceCache) // Mutex lock
	{
        [self removeNullForKey:request.fileURL];
        
		id object = [resourceCache objectForKey:request.fileURL];
        
		if (object == nil) // Resource object does not yet exist in the cache
		{
            if(![[PCResourceQueue sharedInstance] cancelNotStartedOperationWithObject:request.resourceView])
            {
                return object;
            }
            
            // Create a resource fetch operation
            PCResourceFetch *resourceFetch = [[PCResourceFetch alloc] initWithRequest:request];
            
            [resourceFetch main];
            
            [resourceFetch release];
		}
        
		return object; // NSNull or UIImage
	}
}

- (void)setObject:(UIImage *)image forKey:(NSString *)key
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	@synchronized(resourceCache) // Mutex lock
	{
		NSUInteger bytes = (image.size.width * image.size.height * 4.0f);

		[resourceCache setObject:image forKey:key cost:bytes]; // Cache image
	}
}

- (void)removeObjectForKey:(NSString *)key
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	@synchronized(resourceCache) // Mutex lock
	{
		[resourceCache removeObjectForKey:key];
	}
}

- (void)removeNullForKey:(NSString *)key
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	@synchronized(resourceCache) // Mutex lock
	{
		id object = [resourceCache objectForKey:key];

		if ([object isMemberOfClass:[NSNull class]])
		{
			[resourceCache removeObjectForKey:key];
		}
	}
}

- (void)removeAllObjects
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	@synchronized(resourceCache) // Mutex lock
	{
		[resourceCache removeAllObjects];
	}
}

@end
