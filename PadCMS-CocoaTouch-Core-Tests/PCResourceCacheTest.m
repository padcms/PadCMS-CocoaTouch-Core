#import <GHUnitIOS/GHUnit.h> 

#import "PCResourceCache.h"

@interface PCResourceCacheTest : GHTestCase
@end

@implementation PCResourceCacheTest

- (void)testObjectCaching
{
    PCResourceCache *defaultCache = [PCResourceCache defaultResourceCache];
    
    NSString *objectToCache = @"String to cache";
    NSString *key = @"key";
    
    [defaultCache setObject:objectToCache forKey:key];
    
    GHAssertEquals(objectToCache, [defaultCache objectForKey:key], nil);
}

- (void)testObjectEvictionOnMemoryWarning
{
    //TODO: PCResourceCache should automatically evict objects when memory warning notification recieved.
    //Simulate memory warning to test case
}

@end