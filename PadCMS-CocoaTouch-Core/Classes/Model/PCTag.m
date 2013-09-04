//
//  PCTag.m
//  PadCMS-CocoaTouch-Core
//
//  Created by tar on 03.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCTag.h"
#import "PCJSONKeys.h"

@implementation PCTag

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.tagId = [[dictionary objectForKey:PCJSONIssueTagIdKey] integerValue];
        self.tagTitle = [[dictionary objectForKey:PCJSONIssueTagTitleKey] uppercaseString];
    }
    
    return self;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@, title: %@, id: %d", [super description], self.tagTitle, self.tagId];
}

@end
