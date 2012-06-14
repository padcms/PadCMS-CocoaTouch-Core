//
//  NSDictionary+Additions.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/1/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

- (NSDictionary *)dictionaryWithNullsReplaced
{
    NSMutableSet *keysToProcess = [[NSMutableSet alloc] init];
    
    for (NSString *key in self)
    {
        id currentObject = [self objectForKey:key];
        
        if ([currentObject isKindOfClass:NSNull.class] ||
            [currentObject isKindOfClass:NSDictionary.class]) {
            [keysToProcess addObject:key];
        }
    }
    
    NSMutableDictionary *mutableSelf = [self mutableCopy];

    for (NSString *keyToProcess in keysToProcess)
    {
        id currentObject = [self objectForKey:keyToProcess];

        if ([currentObject isKindOfClass:NSNull.class]) {
            [mutableSelf setObject:@"" forKey:keyToProcess];
        } else {
            NSDictionary *subdictionary = (NSDictionary *)currentObject;
            [mutableSelf setObject:[subdictionary dictionaryWithNullsReplaced] 
                                forKey:keyToProcess];
        }
    }
    
    [keysToProcess release];
    
    return [mutableSelf autorelease];
}

@end
