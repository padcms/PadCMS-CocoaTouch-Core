
#import <UIKit/UIKit.h>

#import "PCResourceLoadRequest.h"

@interface PCResourceCache : NSObject
{
@private // Instance variables

	NSCache *resourceCache;
}

+ (PCResourceCache *)sharedInstance;

- (id)resourceLoadBadQualityRequest:(PCResourceLoadRequest *)request;

- (id)resourceLoadGoodQualityRequest:(PCResourceLoadRequest *)request;

- (id)resourceLoadRequestImmediate:(PCResourceLoadRequest *)request;

- (void)setObject:(UIImage *)image forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeNullForKey:(NSString *)key;

- (void)removeAllObjects;

@end
