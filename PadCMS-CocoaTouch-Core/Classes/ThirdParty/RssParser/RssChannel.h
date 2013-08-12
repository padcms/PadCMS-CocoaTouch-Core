//
//  RssChannel.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElement.h"

@class RssDate, RssCategory, RssCloud, RssNumber, RssImage, RssTextInput, RssRating;

@interface RssChannel : RssElement

@property(nonatomic, retain) NSMutableArray* items;

@property(nonatomic, retain) RssElement* title;
@property(nonatomic, retain) RssElement* elementDescription;
@property(nonatomic, retain) RssElement* language;
@property(nonatomic, retain) RssElement* copyright;
@property(nonatomic, retain) RssElement* managingEditor;
@property(nonatomic, retain) RssElement* webMaster;


@property(nonatomic, retain) RssDate* pubDate;
@property(nonatomic, retain) RssDate* lastBuildDate;

@property(nonatomic, retain) RssCategory* category;

@property(nonatomic, retain) RssElement* generator;
@property(nonatomic, retain) RssElement* docs;

@property(nonatomic, retain) RssCloud* cloud;

@property(nonatomic, retain) RssNumber* ttl;

@property(nonatomic, retain) RssImage* image;

@property(nonatomic, retain) RssTextInput* textInput;

@property(nonatomic, retain) RssElement* rating;

@property(nonatomic, retain) RssNumber* skipHours;
@property(nonatomic, retain) RssNumber* skipDays;



@end
