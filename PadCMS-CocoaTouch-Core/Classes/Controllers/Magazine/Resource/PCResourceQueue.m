
#import "PCResourceQueue.h"

@implementation PCResourceQueue

//#pragma mark Properties

//@synthesize ;

#pragma mark PCResourceQueue class methods

+ (PCResourceQueue *)sharedInstance
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	static dispatch_once_t predicate = 0;

	static PCResourceQueue *object = nil; // Object

	dispatch_once(&predicate, ^{ object = [[self alloc] init]; });

	return object; // PCResourceQueue singleton
}

#pragma mark PCResourceQueue instance methods

- (id)init
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init])) // Initialize
	{
		loadQueue = [[NSOperationQueue alloc] init];

		[loadQueue setName:@"PCResourceLoadQueue"];

		[loadQueue setMaxConcurrentOperationCount:1];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[loadQueue release], loadQueue = nil;

	[super dealloc];
}

- (void)addLoadOperation:(PCResourceBaseOperation *)operation
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

    [loadQueue addOperation:operation]; // Add to load queue
}

- (void)cancelAllOperations
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[loadQueue cancelAllOperations];
}

- (BOOL)cancelNotStartedOperationWithObject:(id)object
{
    [loadQueue setSuspended:YES];
    
    for(PCResourceBaseOperation *operation in [loadQueue operations])
    {
        if([operation isContainObject:object])
        {
            if(![operation isCancelled] && ![operation isFinished])
            {
                if([operation isExecuting])
                {
                    [loadQueue setSuspended:NO];
                    
                    return NO;
                }
                else
                {
                    [operation cancel];
                }
            }
        }
    }
    
    [loadQueue setSuspended:NO];
    
    return YES;
}

@end

@implementation PCResourceBaseOperation

#pragma mark PCResourceBaseOperation instance methods

- (BOOL)isContainObject:(id)object
{
    return NO;
}

@end
