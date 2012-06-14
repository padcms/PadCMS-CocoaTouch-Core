
#import <Foundation/Foundation.h>

@interface PCResourceQueue : NSObject
{
@private // Instance variables

	NSOperationQueue *loadQueue;
}

+ (PCResourceQueue *)sharedInstance;

- (void)addLoadOperation:(NSOperation *)operation;

- (void)cancelAllOperations;

- (BOOL)cancelNotStartedOperationWithObject:(id)object;

@end

@interface PCResourceBaseOperation : NSOperation
{
}

- (BOOL)isContainObject:(id)object;

@end