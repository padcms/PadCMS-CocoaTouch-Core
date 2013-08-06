//
//  RssEnclosure.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElement.h"

@interface RssEnclosure : RssElement

@property(nonatomic, retain) NSString* url;
@property(atomic) NSInteger length;
@property(nonatomic, retain) NSString* MIMEType;

@end
