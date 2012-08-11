//
//  ImageCache.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 8/6/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCPageElement;
@class PCPage;
@interface ImageCache : NSObject
@property (atomic, retain) NSMutableDictionary* elementCache;
@property (atomic, retain) NSMutableDictionary* operations;
@property (atomic, retain) NSOperationQueue* queue;
@property (nonatomic) dispatch_queue_t callbackQueue;


+ (ImageCache *)sharedImageCache;
- (void)clearMemory;
- (void)storeTileForElement:(PCPageElement*)element withIndex:(NSUInteger)index;
- (void)clearMemoryForElement:(PCPageElement*)element;
- (void)clearMemoryForElement:(PCPageElement *)element withIndex:(NSUInteger)index;
- (void)loadPrimaryImagesForPage:(PCPage*)aPage;
@end
