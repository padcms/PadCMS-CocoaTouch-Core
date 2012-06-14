
#import <Foundation/Foundation.h>

#import "PCResourceQueue.h"

@class PCResourceLoadRequest;

@interface PCResourceFetch : PCResourceBaseOperation
{
@protected // Instance variables

	PCResourceLoadRequest *request;
    
    BOOL isBadQuality;
}

@property (assign, readwrite) BOOL isBadQuality;

- (id)initWithRequest:(PCResourceLoadRequest *)object;

@end
