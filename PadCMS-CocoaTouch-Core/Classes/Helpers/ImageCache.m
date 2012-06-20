//
//  ImageCache.m
//  the_reader
//
//  Created by User on 03.05.11.
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
