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
#import "PCPage.h"

@interface ImageCache ()
@property (atomic, retain) NSArray* currentPages;
@property (atomic, retain) PCPage* page;

@end

@implementation ImageCache
@synthesize elementCache=_elementCache;
@synthesize operations=_operations;
@synthesize queue=_queue;
@synthesize callbackQueue = _callbackQueue;
@synthesize currentPages=_currentPages;
@synthesize page=_page;

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
	if (_callbackQueue) { 
        dispatch_release(_callbackQueue);
        _callbackQueue = NULL;
    }

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_queue cancelAllOperations];
	[_elementCache release], _elementCache = nil;
	[_operations release], _operations = nil;
	[_queue release], _queue = nil;
	[_currentPages release], _currentPages = nil;
	[_page release], _page = nil;
	
	[super dealloc];
}

- (void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    if (callbackQueue != _callbackQueue) {
        if (_callbackQueue) {
            dispatch_release(_callbackQueue);
            _callbackQueue = NULL;
        }
		
        if (callbackQueue) {
            dispatch_retain(callbackQueue);
            _callbackQueue = callbackQueue;
        }
    }    
}


- (id)init
{
    if ((self = [super init]))
    {
        // Init the memory cache
        _operations = [[NSMutableDictionary alloc] init];
		_elementCache = [[NSMutableDictionary alloc] init];
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
		
		self.callbackQueue = dispatch_queue_create("com.padcms.image.load", NULL);
        		
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
//	[_operations removeAllObjects];
	[_elementCache removeAllObjects];
}

-(void)storeTileForElement:(PCPageElement *)element withIndex:(NSUInteger)index
{
	if (!element.isComplete) return;
	NSString* path = [element resourcePathForTileIndex:index];
	if (!path) return;
	NSNumber* elementIdentifier = [NSNumber numberWithInt:element.identifier];
	if ([[self.elementCache objectForKey:elementIdentifier] objectForKey:[NSNumber numberWithInteger:index]])
	{
		//NSLog(@"HaHaHa");
		return;
	}
	UIImage* image = [[[UIImage alloc] initImmediateLoadWithContentsOfFile:path] retain];
	//UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
	if (!image)
	{
		NSLog(@"ERRRor!!! - %@, %d", path, index);
		return;
	}
	
	if (![self.elementCache objectForKey:elementIdentifier])
	{
		[self.elementCache setObject:[NSMutableDictionary dictionary] forKey:elementIdentifier];
	}
	
	[[self.elementCache objectForKey:elementIdentifier] setObject:image forKey:[NSNumber numberWithInteger:index]];
	[image release];
	
	
	
	NSLog(@"CACHED");
	
	
	
}

-(void)clearMemoryForElement:(PCPageElement *)element
{
}

-(void)clearMemoryForPage:(PCPage *)page
{
	for (PCPageElement* pageElement in page.primaryElements) {
		[self.elementCache removeObjectForKey:[NSNumber numberWithInt:pageElement.identifier]];
	}
	
	if ([UIScreen mainScreen].scale < 2.0) {
		return;
	}
	for (PCPageElement* pageElement in page.secondaryElements) {
		[self.elementCache removeObjectForKey:[NSNumber numberWithInt:pageElement.identifier]];
	}
}


-(NSArray*)getNeighborsForPage:(PCPage*)page
{
	NSMutableArray* array = [NSMutableArray arrayWithObject:page];
	if (page.leftPage) [array addObject:page.leftPage];
	if (page.rightPage) [array addObject:page.rightPage];
	if (page.topPage) [array addObject:page.topPage];
	if (page.bottomPage) [array addObject:page.bottomPage];
	
	if ([UIScreen mainScreen].scale == 2.0)
	{
		if (page.leftPage.leftPage) [array addObject:page.leftPage.leftPage];
		if (page.leftPage.bottomPage) [array addObject:page.leftPage.bottomPage];
		if (page.leftPage.topPage) [array addObject:page.leftPage.topPage];
		if (page.rightPage.rightPage) [array addObject:page.rightPage.rightPage];
		if (page.rightPage.bottomPage) [array addObject:page.rightPage.bottomPage];
		if (page.rightPage.topPage) [array addObject:page.rightPage.topPage];
		if (page.topPage.topPage) [array addObject:page.topPage.topPage];
		if (page.bottomPage.bottomPage) [array addObject:page.bottomPage.bottomPage];
	}
	return [NSArray arrayWithArray:array];
	
}

-(void)loadPrimaryImagesForPage:(PCPage*)aPage
{
	if (self.page == aPage) return;
	self.page = aPage;
	dispatch_async(self.callbackQueue, ^{
	//	NSInteger maxIndex = ceilf(1024.0f / kDefaultTileSize) * ceilf(768.0f / kDefaultTileSize);
		
		NSArray* oldPages = [_currentPages retain];
		self.currentPages = [self getNeighborsForPage:aPage];
		//BOOL isNewPage = NO;
		for (PCPage* page in oldPages) {
			if (![_currentPages containsObject:page])
			{
				[self clearMemoryForPage:page];
		//		isNewPage = YES;
			}
		}
		
	//	if (!isNewPage) return;
		
		NSLog(@"load");
		[oldPages release], oldPages = nil;
		for (PCPage* page in self.currentPages) {
			
			PCPageElement* backgroundElement = [page firstElementForType:PCPageElementTypeBackground];
			if (![self.elementCache objectForKey:[NSNumber numberWithInt:backgroundElement.identifier]] && backgroundElement && [backgroundElement.resourceExtension isEqualToString:@"png"] )
			{
				NSInteger maxColumn = ceilf(backgroundElement.realImageSize.width / kDefaultTileSize);
				for (int col = 1; col <=2; ++col) {
					for (int row = 1; row <=2; ++row) {
						NSInteger index = (row - 1) * maxColumn + col;
						NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
							[self storeTileForElement:backgroundElement withIndex:index];
						}];
						[self.queue addOperation:operation];
					}
					
				}
			}
			
			
			PCPageElement* bodyElement = [page firstElementForType:PCPageElementTypeBody];
			if (![self.elementCache objectForKey:[NSNumber numberWithInt:bodyElement.identifier]] && bodyElement && [bodyElement.resourceExtension isEqualToString:@"png"])
			{
				NSInteger maxColumn = ceilf(bodyElement.realImageSize.width / kDefaultTileSize);
				for (int col = 1; col <=2; ++col) {
					for (int row = 1; row <=2; ++row) {
						NSInteger index = (row - 1) * maxColumn + col;
						NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
							[self storeTileForElement:bodyElement withIndex:index];
						}];
						[self.queue addOperation:operation];
					}
					
				}
			}
			
			PCPageElement* scrollElement = [page firstElementForType:PCPageElementTypeScrollingPane];
			if (![self.elementCache objectForKey:[NSNumber numberWithInt:scrollElement.identifier]] && scrollElement && [scrollElement.resourceExtension isEqualToString:@"png"])
			{
				
				
				NSInteger maxColumn = ceilf(scrollElement.realImageSize.width / kDefaultTileSize);
				for (int col = 1; col <=2; ++col) {
					for (int row = 1; row <=2; ++row) {
						NSInteger index = (row - 1) * maxColumn + col;
						NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
							[self storeTileForElement:scrollElement withIndex:index];
						}];
						[self.queue addOperation:operation];
					}
					
				}
				
			}
			
			if ([UIScreen mainScreen].scale < 2.0) {
				continue;
			}
			NSArray* slideElements = [page elementsForType:PCPageElementTypeSlide];
			for (PCPageElement* element in slideElements) {
				if (![self.elementCache objectForKey:[NSNumber numberWithInt:element.identifier]] && element  && [element.resourceExtension isEqualToString:@"png"])
				{
					
					
					NSInteger maxColumn = ceilf(element.realImageSize.width / kDefaultTileSize);
					for (int col = 1; col <=2; ++col) {
						for (int row = 1; row <=2; ++row) {
							NSInteger index = (row - 1) * maxColumn + col;
							NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
								[self storeTileForElement:element withIndex:index];
							}];
							[self.queue addOperation:operation];
						}
						
					}
					
				}
			}
			
	/*		NSArray* miniArticlesElements = [page elementsForType:PCPageElementTypeMiniArticle];
			for (PCPageElement* element in miniArticlesElements) {
				if (![self.elementCache objectForKey:[NSNumber numberWithInt:element.identifier]] && element  && [element.resourceExtension isEqualToString:@"png"])
				{
					
					
					NSInteger maxColumn = ceilf(element.realImageSize.width / kDefaultTileSize);
					for (int col = 1; col <=2; ++col) {
						for (int row = 1; row <=2; ++row) {
							NSInteger index = (row - 1) * maxColumn + col;
							NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
								[self storeTileForElement:element withIndex:index];
							}];
							[self.queue addOperation:operation];
						}
						
					}
					
				}
			}
		*/	
			
			
/*			
			
			for (PCPageElement* element in page.primaryElements) {
				if ([self.elementCache objectForKey:[NSNumber numberWithInt:element.identifier]]) continue;
				if (![element.fieldTypeName isEqualToString:PCPageElementTypeBody] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeBackground] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeVideo] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeSound] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeHtml] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeHtml5] &&
					![element.fieldTypeName isEqualToString:PCPageElementType3D])
				{
					for (int i = 1; i <=maxIndex; ++i) {
						NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
							[self storeTileForElement:element withIndex:i];
						}];
						[self.queue addOperation:operation];
					}
				}
				
				
			}
			
			for (PCPageElement* element in page.secondaryElements) {
				if ([self.elementCache objectForKey:[NSNumber numberWithInt:element.identifier]]) continue;
				if (![element.fieldTypeName isEqualToString:PCPageElementTypeBody] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeBackground] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeVideo] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeSound] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeHtml] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeHtml5] &&
					![element.fieldTypeName isEqualToString:PCPageElementType3D])
				{
					for (int i = 1; i <=maxIndex; ++i) {
						NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
							[self storeTileForElement:element withIndex:i];
						}];
						[self.queue addOperation:operation];
					}
				}
				
				
			}
 */
		}
		
		
		
	});

}

-(void)clearMemoryForElement:(PCPageElement *)element withIndex:(NSUInteger)index
{
	NSNumber* elementIdentifier = [NSNumber numberWithInt:element.identifier];
	[[self.elementCache objectForKey:elementIdentifier] removeObjectForKey:[NSNumber numberWithInteger:index]];
}

@end
