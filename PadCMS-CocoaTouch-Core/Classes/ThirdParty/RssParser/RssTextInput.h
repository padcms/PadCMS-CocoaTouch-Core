//
//  RssTextInput.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElement.h"

@interface RssTextInput : RssElement

@property(nonatomic, retain) RssElement* title;
@property(nonatomic, retain) RssElement* elementDescription;
@property(nonatomic, retain) RssElement* name;
@property(nonatomic, retain) RssElement* link;

@end
