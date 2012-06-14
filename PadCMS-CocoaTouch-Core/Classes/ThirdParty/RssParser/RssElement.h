//
//  RssElement.h
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OPENTAG_TEMPLATE_WITH_ATTRIBUTES @"<%@ %@>"
#define CLOSEDTAG_TEMPLATE @"<!%@>"
#define CDATA_TEMPLATE @"<![CDATA[\n%@\n]]>"

@interface RssElement : NSObject

@property(nonatomic, retain) NSString* text;
@property(nonatomic, readonly) NSString* elementName;
@property(nonatomic, retain) NSString* CDATA;
@property(nonatomic, readonly) RssElement* parent;

- (id)initWithParent:(RssElement*)_parent name:(NSString*)_name;

- (NSString*)stringFromElement;
- (NSString*)stringBody;
- (NSString*)stringFromAttributes;


- (BOOL)setChildElement:(RssElement*)element;

- (void)setAtributes:(NSDictionary*)attributes;

@end
