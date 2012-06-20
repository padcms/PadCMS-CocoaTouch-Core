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
