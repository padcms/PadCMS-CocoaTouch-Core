//
//  ImageCache.m
//  the_reader
//
//  Created by User on 03.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"
#import "MagThreadQueue.h"

@implementation ImageCache

static ImageCache *sharedInstance;

+ (ImageCache *)sharedImageCache
{
	if(!sharedInstance)
	{
		sharedInstance = [[ImageCache alloc] init];
	}
	
	return sharedInstance;
}

- (id) init
{
	if(self = [super init])
	{
		keyArray = [[NSMutableArray alloc] init];
		memoryCache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[keyArray release];
	[memoryCache release];
	
	[super dealloc];
}

- (UIImage *)imageForKey:(NSString *)key
{
	if(key)
    {
		if ([[memoryCache objectForKey:key] count] > 0)
        {
            return [[memoryCache objectForKey:key] objectAtIndex:0];
        }
	}
	return nil;
}

- (BOOL)hasImageWithKey:(NSString *)key
{
	return [keyArray containsObject:key];
}

- (void)storeImage:(UIImage *)image withKey:(NSString *)key index:(int)_index
{
	if([self hasImageWithKey:key])
	{
		[memoryCache removeObjectForKey:key];
	}
	else
	{
		[keyArray addObject:key];
	}
	
	NSNumber *index;
	if(_index == -1)
		index = [NSNumber numberWithInt:[MagThreadQueue sharedInstance].prevIndex];
	else
		index = [NSNumber numberWithInt:_index];

	[memoryCache setObject:[NSArray arrayWithObjects: image, index, nil] forKey:key];
}

- (void)removeImageWithKey:(NSString *)key
{
	if([self hasImageWithKey:key])
	{
		[memoryCache removeObjectForKey:key];
		[keyArray removeObject:key];
	}
}

- (void)removeAllImages
{
    [memoryCache removeAllObjects];
    [keyArray removeAllObjects];
}

- (void)removeOldImages
{
	for(int i = 0; i < [keyArray count]; ++i)
	{
		NSString *key = [keyArray objectAtIndex:i];
        if ([[memoryCache objectForKey:key] count] > 0)
        {
            if([[[memoryCache objectForKey:key] objectAtIndex:0] retainCount] == 1)
            {
                NSLog(@"Remove %@ from cache", key);
                [self removeImageWithKey:key];
                i--;
            }
        }
		//else
		//{
		//	NSLog(@"%@ has %d ref count", key, [[[memoryCache objectForKey:key] objectAtIndex:0] retainCount]);
		//}

	}
}

- (NSArray *) indexesForCurrentCache
{
	NSMutableArray *result = [NSMutableArray array];
	@synchronized(keyArray)
	{
		for(NSString *key in keyArray)
		{
			NSNumber *index = [[memoryCache objectForKey:key] objectAtIndex:1];
			if(![result containsObject:index])
				[result addObject:index];
		}
	}
	return result;
}

@end
