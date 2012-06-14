//
//  ImageCache.h
//  the_reader
//
//  Created by User on 03.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ImageLoadNotification @"ImageLoadNotification"

@interface ImageCache : NSObject
{
@private
    NSMutableArray *keyArray;
    NSMutableDictionary *memoryCache;
}

+ (ImageCache *)sharedImageCache;

- (UIImage *)imageForKey:(NSString *)key;
- (BOOL)hasImageWithKey:(NSString *)key;
- (void)storeImage:(UIImage *)image withKey:(NSString *)key index:(int)index;
- (void)removeImageWithKey:(NSString *)key;
- (void)removeAllImages;
- (void)removeOldImages;
- (NSArray *) indexesForCurrentCache;

@end
