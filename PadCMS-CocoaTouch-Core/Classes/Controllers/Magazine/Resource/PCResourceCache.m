//
//  PCResourceCache.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 7/11/12.
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

#import "PCResourceCache.h"

static PCResourceCache *defaultResourceCache = nil;

@interface PCResourceCache ()

@property (retain, nonatomic) NSCache *cache;

@end

@implementation PCResourceCache
@synthesize cache = _cache;

+ (PCResourceCache *)defaultResourceCache
{
    if (defaultResourceCache == nil) {
        defaultResourceCache = [[super allocWithZone:NULL] init];
        defaultResourceCache.cache = [[[NSCache alloc] init] autorelease];
        defaultResourceCache.cache.delegate = defaultResourceCache;
    }
    
    return defaultResourceCache;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self defaultResourceCache] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id)objectForKey:(id)key
{
    return [_cache objectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key
{
    if (object == nil || key == nil) {
        return;
    }
    
    [_cache setObject:object forKey:key];
}

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
}

@end
