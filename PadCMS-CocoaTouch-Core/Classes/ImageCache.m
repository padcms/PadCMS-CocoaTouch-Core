//
//  ImageCache.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 8/6/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "ImageCache.h"
#import "PCPageElement.h"
#import "UIImage+ImmediateLoading.h"

@implementation ImageCache
@synthesize elementCache=_elementCache;
@synthesize operations=_operations;
@synthesize queue=_queue;

+ (ImageCache *)sharedImageCache
{
   	static ImageCache *instance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_queue cancelAllOperations];
	[_elementCache release], _elementCache = nil;
	[_operations release], _operations = nil;
	[_queue release], _queue = nil;
	
	[super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Init the memory cache
        _operations = [[NSMutableDictionary alloc] init];
		_elementCache = [[NSMutableDictionary alloc] init];
		_queue = [[NSOperationQueue alloc] init];
        		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
	}
	
    return self;
}

-(void)clearMemory
{
	//[_queue cancelAllOperations];
	[_operations removeAllObjects];
	[_elementCache removeAllObjects];
}

-(void)storeTileForElement:(PCPageElement *)element withIndex:(NSUInteger)index
{
	NSString* path = [element resourcePathForTileIndex:index];
	UIImage* image = [[[UIImage alloc] initImmediateLoadWithContentsOfFile:path] retain];
	//UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
	if (!image)
	{
		NSLog(@"ERRRor!!! - %@, %d", path, index);
		return;
	}
	NSNumber* elementIdentifier = [NSNumber numberWithInt:element.identifier];
	if (![self.elementCache objectForKey:elementIdentifier])
	{
		[self.elementCache setObject:[NSMutableDictionary dictionary] forKey:elementIdentifier];
	}
	
	[[self.elementCache objectForKey:elementIdentifier] setObject:image forKey:[NSNumber numberWithInteger:index]];
	[image release];
	
	
	
}

-(void)clearMemoryForElement:(PCPageElement *)element
{
	
}

-(void)clearMemoryForElement:(PCPageElement *)element withIndex:(NSUInteger)index
{
	
}

@end
