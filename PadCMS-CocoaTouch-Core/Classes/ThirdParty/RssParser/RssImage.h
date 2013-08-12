//
//  RssImage.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElement.h"

@class RssNumber;

@interface RssImage : RssElement

@property(nonatomic, retain) RssElement* url;
@property(nonatomic, retain) RssElement* title;
@property(nonatomic, retain) RssElement* link;
@property(nonatomic, retain) RssNumber* width;
@property(nonatomic, retain) RssNumber* height;

@end
