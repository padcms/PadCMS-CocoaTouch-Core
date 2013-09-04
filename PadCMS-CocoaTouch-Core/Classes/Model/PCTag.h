//
//  PCTag.h
//  PadCMS-CocoaTouch-Core
//
//  Created by tar on 03.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCTag : NSObject

@property (nonatomic, retain) NSString * tagTitle;
@property (nonatomic) NSInteger tagId;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
