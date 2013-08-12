//
//  RssCloud.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElement.h"

@interface RssCloud : RssElement

@property(nonatomic, retain) NSString* domain;
@property(atomic) NSInteger port;
@property(nonatomic, retain) NSString* path;
@property(nonatomic, retain) NSString* registerProcedure;
@property(nonatomic, retain) NSString* protocol;

@end
