//
//  RssItem.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElement.h"

@class RssCategory, RssDate, RssSource, RssGuid;

@interface RssItem : RssElement

@property(nonatomic, retain) RssElement* title;
@property(nonatomic, retain) RssElement* elementDescription;
@property(nonatomic, retain) RssElement* link;
@property(nonatomic, retain) RssElement* author;
@property(nonatomic, retain) RssCategory* category;
@property(nonatomic, retain) NSMutableArray* enclosures;
@property(nonatomic, retain) RssGuid* guid;
@property(nonatomic, retain) RssDate* pubDate;
@property(nonatomic, retain) RssSource* source;

- (BOOL)isEqualRssItem:(RssItem*)item;

@end
