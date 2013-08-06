//
//  RssElementFactory.m
//  RssParser
//
//  Created by admin on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RssElementFactory.h"
#import "RssElement.h"
#import "RssChannel.h"
#import "RssItem.h"
#import "RssNumber.h"
#import "RssDate.h"
#import "RssEnclosure.h"
#import "RssImage.h"
#import "RssCloud.h"
#import "RssCategory.h"
#import "RssGuid.h"
#import "RssSource.h"
#import "RssTextInput.h"

@implementation RssElementFactory


+(RssElement*)elementWithName:(NSString*)name atributes:(NSDictionary*)attributes forParent:(RssElement*)parent
{
    name = [name lowercaseString];
    RssElement* element = nil;
    if ([name isEqualToString:RSS_CHANNEL]) {
        element = [[RssChannel alloc] initWithParent:parent name:name];
        
        return [element autorelease];
    }else if ([name isEqualToString:RSS_ITEM]) {
        element = [[RssItem alloc] initWithParent:parent name:name];
        if (parent&&[parent isKindOfClass:[RssChannel class]]) {
            RssChannel* chanel = (RssChannel*)parent;
            [chanel.items addObject:element];
        }
    } else if ([name isEqualToString:RSS_IMAGE]) {
        element = [[RssImage alloc] initWithParent:parent name:name];
    }else if ([name isEqualToString:RSS_PUBDATE]||[name isEqualToString:RSS_LASTBUILDDATE]) {
        element = [[RssDate alloc] initWithParent:parent name:name];
    }else if ([name isEqualToString:RSS_TTL]||[name isEqualToString:RSS_WIDTH]||[name isEqualToString:RSS_HEIGHT]
              ||[name isEqualToString:RSS_SKIP_HOURS]||[name isEqualToString:RSS_SKIP_DAYS]) {
        element = [[RssNumber alloc] initWithParent:parent name:name];
    }else if ([name isEqualToString:RSS_CATHEGORY]) {
        element = [[RssCategory alloc] initWithParent:parent name:name];
    }else if ([name isEqualToString:RSS_CLOUD]) {
        element = [[RssCloud alloc] initWithParent:parent name:name];
    }else if ([name isEqualToString:RSS_TEXTINPUT]) {
        element = [[RssTextInput alloc] initWithParent:parent name:name];
    }else if ([name isEqualToString:RSS_SOURCE]) {
        element = [[RssSource alloc] initWithParent:parent name:name];
    }else if ([name isEqualToString:RSS_ENCLOSURE]) {
        element = [[RssItem alloc] initWithParent:parent name:name];
        if (parent&&[parent isKindOfClass:[RssItem class]]) {
            RssItem* item = (RssItem*)parent;
            [item.enclosures addObject:element];
        }
    } else if ([name isEqualToString:RSS_GUID]) {
        element = [[RssGuid alloc] initWithParent:parent name:name];
    }else {
        element = [[RssElement alloc] initWithParent:parent name:name];        
    }
    if (element&&parent) {
        [parent setChildElement:element];
    }
    if (element) {
        [element setAtributes:attributes];
    }    
    return [element autorelease];
}

@end
