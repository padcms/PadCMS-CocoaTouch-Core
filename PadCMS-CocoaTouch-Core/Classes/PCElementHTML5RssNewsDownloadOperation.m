//
//  PCElementHTML5RssNewsDownloadOperation.m
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCElementHTML5RssNewsDownloadOperation.h"
#import "PCPageElementHtml5.h"
#import "RssParser.h"
#import "RssChannel.h"
#import "RssDate.h"
#import "RssItem.h"


@implementation PCElementHTML5RssNewsDownloadOperation

@synthesize rssChannel;

- (id)initWithElement:(PCPageElement*)_element
{
    PCPageElementHtml5* html5Element = (PCPageElementHtml5*)_element;

    self = [self initWithURL:[NSURL URLWithString:html5Element.rssLink]];
    if (self) {
        self.element = _element;
        isEndParsing = NO;
    }
    
    return self;
}

- (BOOL)processDownloadingContent
{
    if (isEndParsing) {
        return YES;
    }
    isOldXmlParsing = NO;
    isNewXmlParsing = NO;
    
        
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        NSData* oldRssData = [NSData dataWithContentsOfFile:self.filePath];
        isOldXmlParsing = YES;
        oldRssParser = [RssParser parseRssData:oldRssData toTarget:self];
        if (oldRssParser) {
            [oldRssParser parse];
        }
        
    }

    newRssParser = [RssParser parseRssData:self->_dataAccumulator toTarget:self];
    if (newRssParser) {
        [newRssParser parse];
    }
    
    if (newRssParser==nil&&oldRssParser==nil) {
        return YES;
    }    
        
    return NO;
}

- (void)endProcessDownloadContent
{
    if (newRssParser) {
        if (oldRssParser) {
            PCPageElementHtml5* html5Element = (PCPageElementHtml5*)self.element;
            BOOL isSameLines = NO;
            if (oldRssParser.channel&&newRssParser.channel&&[oldRssParser.channel.items count]==[newRssParser.channel.items count]&&[oldRssParser.channel.items count]>0) {   
                NSLog(@"oldRssParser.channel.pubDate = %@", oldRssParser.channel.pubDate);
                NSLog(@"newRssParser.channel.pubDate = %@", newRssParser.channel.pubDate);
                isSameLines = [[oldRssParser.channel.pubDate date] isEqualToDate:[newRssParser.channel.pubDate date]];
            } 
            if (!isSameLines) {
                NSMutableArray* rssItems = [NSMutableArray arrayWithCapacity:html5Element.rssLinkNumber];
                int oldIndex = 0, newIndex = 0; 
                NSArray* oldRssItems = oldRssParser.channel.items;
                NSArray* newRssitems = newRssParser.channel.items;
                for (int i  = 0; i < html5Element.rssLinkNumber; i++) {
                    if (i>=[oldRssItems count]&&i<[newRssitems count]) {
                        RssItem* newItem = [newRssitems objectAtIndex:newIndex];
                        newIndex++;
                        [rssItems addObject:newItem];                    
                    } else if (i<[oldRssItems count]&&i>=[newRssitems count]) {
                        RssItem* oldItem = [oldRssItems objectAtIndex:oldIndex];
                        oldIndex++;
                        [rssItems addObject:oldItem];                  
                    } else if(i>=[oldRssItems count]&&i>=[newRssitems count]){
                        break;
                    }
                    RssItem* oldItem = [oldRssItems objectAtIndex:oldIndex];
                    RssItem* newItem = [newRssitems objectAtIndex:newIndex];
                    if (newItem.pubDate&&oldItem.pubDate) {
                        if ([newItem.pubDate.date timeIntervalSince1970]>[oldItem.pubDate.date timeIntervalSince1970]) {
                            newIndex++;
                            [rssItems addObject:newItem];
                        } else if ([newItem.pubDate.date  timeIntervalSince1970]==[oldItem.pubDate.date  timeIntervalSince1970]) {
                            newIndex++;
                            oldIndex++;
                            [rssItems addObject:newItem];
                        } else {
                            oldIndex++;
                            [rssItems addObject:oldItem];
                        }
                    } else {
                        if ([newItem isEqualRssItem:oldItem]) {
                            newIndex++;
                            oldIndex++;
                            [rssItems addObject:newItem];
                        } else {
                            newIndex++;
                            [rssItems addObject:newItem];
                        }
                    }
                    
                }                
                newRssParser.channel.items = rssItems;
            }

        }
        if (newRssParser.channel) {
            [[newRssParser.channel stringFromElement] writeToFile:self.filePath 
                                                       atomically:NO 
                                                         encoding:NSUTF8StringEncoding 
                                                            error:nil];
        }
        [super connectionDidFinishLoading:self->_connection];
    } else {
        if (self->_dataAccumulator==nil) {
            newRssParser = oldRssParser;
            [super connectionDidFinishLoading:self->_connection];
        }
    }
    
}

- (void)parser:(RssParser*)parser endParseRssChanel:(RssChannel*)channel
{
    if (parser==oldRssParser) {
        isOldXmlParsing = NO;
    }
    if (parser==newRssParser) {
        isNewXmlParsing = NO;
    }
    
    if (!isOldXmlParsing&&!isNewXmlParsing) {
        isEndParsing = YES;
        [self endProcessDownloadContent];
    }
}
- (void)parser:(RssParser *)parser endParseWithError:(NSError*)error
{
    if (parser==oldRssParser) {
        isOldXmlParsing = NO;
    }
    if (parser==newRssParser) {
        isNewXmlParsing = NO;
    }
    
    if (!isOldXmlParsing&&!isNewXmlParsing) {
        [self endProcessDownloadContent];
    }
}

@end
