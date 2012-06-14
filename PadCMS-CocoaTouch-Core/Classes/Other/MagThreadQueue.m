//
//  MagThreadQueue.m
//  the_reader
//
//  Created by User on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MagThreadQueue.h"
#import "ImageCache.h"
#import "Helper.h"

@interface MagOperation : NSOperation
{
	int index;
	NSString *path;
	BOOL executing;
	BOOL finished;
}

@property (readonly, getter = getIndex) int index;
@property (retain, readonly) NSString *path;

- (id) initWithPath:(NSString *) path index:(int) index;

- (void)completeOperation;
- (CGRect) rectFromPDFArray: (CGPDFArrayRef) a;

@end

@interface MagOperation(ForwardDeclaration)

- (UIImage *) preloadPage;
- (void) extractLinks:(CGPDFPageRef)pageRef fileName:(NSString*)_fileName;
- (UIImage *) loadGlyph:(CGPDFPageRef)pageRef;


@end

@implementation MagOperation

@synthesize index;
@synthesize path;

- (CGRect) rectFromPDFArray: (CGPDFArrayRef) a
{
    return CGRectZero;
}

- (id) initWithPath:(NSString *) _path index:(int) _index
{
	if((self = [super init]))
	{
		path = [[NSString alloc] initWithString:_path];
		index = _index;
		executing = NO;
		finished = NO;
	}
	
	return self;
}

- (void) main
{
	@try
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		NSLog(@"Thread priority %f", [self threadPriority]);
		
		UIImage *glyph = [self preloadPage];
		
		if(glyph)
		{
			[[ImageCache sharedImageCache] storeImage:glyph withKey:path index:index];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:ImageLoadNotification object:path];
		}
		else
		if(![[ImageCache sharedImageCache] hasImageWithKey:path])
		{
			NSData *imageData = [NSData dataWithContentsOfFile:path];
			if(imageData)
			{
				UIImage* glyph = [UIImage imageWithData:imageData];
				
				CGImageRef cgImage = [glyph CGImage];
					
				int width = CGImageGetWidth(cgImage);
				int height = CGImageGetHeight(cgImage);
					
				CGColorSpaceRef colorspace = CGImageGetColorSpace(cgImage);
				CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorspace, kCGImageAlphaNoneSkipFirst);
				
				if(context)
				{
					CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
					CGContextRelease(context);
					
					[[ImageCache sharedImageCache] storeImage:glyph withKey:path index:index];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:ImageLoadNotification object:path];
				}
			}
		}

		[self completeOperation];
		[pool release];
	}
	@catch(...)
	{
	}
}

- (UIImage *) preloadPage
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
		return nil;
	
	NSString *fileName = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
	NSString *plistFileName = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
	
	NSLog(@"preloading %@", fileName);
	
	CGPDFDocumentRef pdfDocumentRef = [Helper getDocumentRef:[fileName cStringUsingEncoding:NSASCIIStringEncoding]];
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDocumentRef, 1);
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistFileName])
		[self extractLinks:pageRef fileName:plistFileName];
	
	UIImage* glyph = [self loadGlyph:pageRef];	
	
		
	NSData *data = UIImagePNGRepresentation(glyph);
	[data writeToFile:path atomically:YES];
		
	return glyph;
}

CGContextRef ThreadCreateBitmapContext (int pixelsWide,
									   int pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
    if (context== NULL)
    {
        free (bitmapData);
        CGColorSpaceRelease(colorSpace);
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease(colorSpace);
	
    return context;
}

- (UIImage *) loadGlyph:(CGPDFPageRef)pageRef
{
	CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(pageRef);
	CGPDFArrayRef cropBox;
	CGPDFDictionaryGetArray(pageDict, "CropBox", &cropBox);
	CGRect clipRect = [self rectFromPDFArray:cropBox];
	
	CGSize displaySize = clipRect.size;
	
	// Create a bitmap context to store the new thumbnail 
    CGContextRef context = ThreadCreateBitmapContext(displaySize.width,	displaySize.height);
	
	CGContextSetRGBFillColor(context, 1, 1, 1, 0);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	CGContextFillRect(context, CGRectMake(0, 0, displaySize.width, displaySize.height));
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	
	CGContextTranslateCTM(context, 0.0, clipRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextConcatCTM(context, CGAffineTransformMake(1,0,0,-1,0,clipRect.size.height));
	
	CGContextDrawPDFPage(context, pageRef);
	
    CGImageRef myRef = CGBitmapContextCreateImage (context);
	
    UIImage *img = [UIImage imageWithCGImage:myRef];
	
    free(CGBitmapContextGetData(context));
    CGContextRelease(context);
    CGImageRelease(myRef);
	
    return img; 
}

- (void) extractLinks:(CGPDFPageRef)pageRef fileName:(NSString*)_fileName
{
	
	NSDictionary* linksDocument = nil;
	
	CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(pageRef);
	
	CGPDFArrayRef cropBox = nil;
	CGPDFDictionaryGetArray(pageDict, "CropBox", &cropBox);
	CGRect clipRect = [self rectFromPDFArray:cropBox];
	
	CGPDFArrayRef annots = nil;
	if (!CGPDFDictionaryGetArray(pageDict, "Annots", &annots))
	{
		return;
	}
    NSArray* linksArray = [[NSMutableArray alloc] init];

	int count = CGPDFArrayGetCount(annots);
	for (int i = 0; i < count; i++)
	{
		
		CGPDFDictionaryRef annotation;
		CGPDFArrayGetDictionary(annots, i, &annotation);
		
		// process "A" entry to get URI
		CGPDFDictionaryRef a;
		CGPDFDictionaryGetDictionary(annotation, "A", &a);
		
		CGPDFStringRef pdfUriRef;
		CGPDFDictionaryGetString(a, "URI", &pdfUriRef);
		
		NSString* uri = [NSString stringWithCString:(char*)CGPDFStringGetBytePtr(pdfUriRef) encoding:NSASCIIStringEncoding];
		
		//process "Rect" entry to get hotspot rectangle
		CGPDFArrayRef rect;
		CGPDFDictionaryGetArray(annotation, "Rect", &rect);
		
		if (CGPDFArrayGetCount(rect) != 4)
		{
			continue;
		}
		
		NSString* rc = NSStringFromCGRect([self rectFromPDFArray: rect]);
		NSNumber* hostScale = [NSNumber numberWithFloat:1.0f];
		NSString* hostClipRect = NSStringFromCGRect(clipRect);
		
		[(NSMutableArray*)linksArray addObject:
		 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:uri,rc,hostScale,hostClipRect,nil]
									 forKeys:[NSArray arrayWithObjects:@"url",@"rect",@"hostScale",@"hostClipRect",nil]]	 ];
		
	}
	
	linksDocument = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:NSStringFromCGRect(clipRect),linksArray,nil]
												forKeys:[NSArray arrayWithObjects:@"clipRect",@"links",nil]];
	
	[linksDocument writeToFile:_fileName atomically:YES];
    [linksArray release];
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
	
    executing = NO;
    finished = YES;
	
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void) start
{
	if ([self isCancelled])
	{
		[self willChangeValueForKey:@"isFinished"];
		finished = YES;
		[self didChangeValueForKey:@"isFinished"];
		return;
	}
	
	[self willChangeValueForKey:@"isExecuting"];
	[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
	executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
}

- (BOOL) isExecuting
{
	return executing;
}

- (BOOL) isFinished
{
	return finished;
}

- (BOOL) isConcurrent
{
	return YES;
}

- (void) dealloc
{
	[path release];
	
	[super dealloc];
}

@end



@implementation MagThreadQueue

//NSOperationQueuePriorityVeryHigh for unload operations
//NSOperationQueuePriorityHigh for load current index templates
//NSOperationQueuePriorityNormal for load not current index templates

static MagThreadQueue *instance;

@synthesize prevIndex;
@synthesize blocked;

+ (MagThreadQueue *) sharedInstance
{
	if(!instance)
	{
		instance = [[MagThreadQueue alloc] init];
	}
	
	return instance;
}

- (id) init
{
	if(self = [super init])
	{
		prevIndex = -1;
		queue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:1];
		
		instance = self;
	}
	
	return self;
}

- (void) removeOperationWithPath:(NSString *) path
{
	NSLog(@"remove operation with path %@", path);
	for(MagOperation *op in [queue operations])
	{
		if(![op isExecuting] && ![op isCancelled] && [[op path] isEqualToString:path])
			[op cancel];
	}
}

- (void) addOperationWithPath:(NSString *) path columnIndex:(int) index
{
	NSLog(@"addOperation index %d path %@", index, path);
	NSOperation *newop = [[MagOperation alloc] initWithPath:path index:index];

	if(index == -1)
		[newop setQueuePriority:NSOperationQueuePriorityVeryHigh];
	else
	if(index == prevIndex)
		[newop setQueuePriority:NSOperationQueuePriorityHigh];
	else
	if(ABS(index - prevIndex) == 1)
		[newop setQueuePriority:NSOperationQueuePriorityNormal];
	else
		[newop setQueuePriority:NSOperationQueuePriorityLow];
	   
	[queue addOperation:newop];
	[newop release];
}

- (void) setCurrentIndex:(int) index
{
	[queue setSuspended:YES];
	
	if(prevIndex != -1)
	{
		for(MagOperation *operation in [queue operations])
		{
			if(![operation isExecuting] && [operation queuePriority] < NSOperationQueuePriorityVeryHigh)
			{
				if(operation.index == index)
					[operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
				else
				if(ABS(operation.index - index) == 1)
					[operation setQueuePriority:NSOperationQueuePriorityNormal];
				else
				if([operation queuePriority] != NSOperationQueuePriorityVeryLow)
					[operation setQueuePriority:[operation queuePriority] - 1];
				else
				{
					[operation cancel];
				}
			}
		}
	}
	
	prevIndex = index;
	
	if(!blocked)
	{
		[queue setSuspended:NO];
	}
}

- (BOOL) isBlocked
{
    return blocked;
}

- (void) setBlocked:(BOOL)_blocked
{
	blocked = _blocked;
	[queue setSuspended:_blocked];
}

- (void) dealloc
{
	[queue cancelAllOperations];
	
	[queue release];
	
	[super dealloc];
}


@end
