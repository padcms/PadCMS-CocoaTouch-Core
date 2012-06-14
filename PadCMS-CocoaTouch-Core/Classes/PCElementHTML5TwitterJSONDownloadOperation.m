//
//  PCElementHTML5TwitterJSONDownloadOperation.m
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCElementHTML5TwitterJSONDownloadOperation.h"
#import "PCPageElementHtml5.h"
#import "JSON.h"

#define TWITTER_GET_STATUSES @"https://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=%@&count=%d"

@implementation PCElementHTML5TwitterJSONDownloadOperation

@synthesize twitterJsonArray;

- (id)initWithElement:(PCPageElement*)_element
{
 
    PCPageElementHtml5* html5Element = (PCPageElementHtml5*)_element;

    NSString* twitterUrl = html5Element.twitterAccount;
    twitterUrl = [twitterUrl stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    twitterUrl = [twitterUrl stringByReplacingOccurrencesOfString:@"www.twitter.com/" withString:@""];
    twitterUrl = [twitterUrl stringByReplacingOccurrencesOfString:@"twitter.com/" withString:@""];
    twitterUrl = [twitterUrl stringByReplacingOccurrencesOfString:@"#/" withString:@""];
    twitterUrl = [twitterUrl stringByReplacingOccurrencesOfString:@"#!/" withString:@""];
    
    twitterUrl = [NSString stringWithFormat:TWITTER_GET_STATUSES, twitterUrl, html5Element.twitterTweetNumber];
    
    self = [self initWithURL:[NSURL URLWithString:twitterUrl]];
    if (self) {
        self.element = _element;
    }
    
    return self;
}

- (NSDateFormatter *)_HTTPDateFormatter
{
    // Returns a formatter for dates in HTTP format (i.e. RFC 822, updated by RFC 1123).
    // e.g. "Sun, 06 Nov 1994 08:49:37 GMT"
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	//[dateFormatter setDateFormat:@"%a, %d %b %Y %H:%M:%S GMT"]; // won't work with -init, which uses new (unicode) format behaviour.
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss GMT"];
	return dateFormatter;
}

- (BOOL)processDownloadingContent
{
    
    PCPageElementHtml5* html5Element = (PCPageElementHtml5*)self.element;
    NSArray* oldJsonArray = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        NSString* jsonString = [NSString stringWithContentsOfFile:self.filePath 
                                                         encoding:NSUTF8StringEncoding 
                                                            error:nil];
        if (jsonString) {
            oldJsonArray = [jsonString JSONValue];
        }
    }
    
    [self saveData:self->_dataAccumulator toPath:self.filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        NSString* jsonString = [NSString stringWithContentsOfFile:self.filePath 
                                                         encoding:NSUTF8StringEncoding 
                                                            error:nil];
        if (jsonString) {
            twitterJsonArray = [[NSArray alloc] initWithArray:[jsonString JSONValue]];
        }
    }
    
    if (oldJsonArray&&twitterJsonArray) {
        if (html5Element.twitterTweetNumber<0) {
            html5Element.twitterTweetNumber = 20;
        }
        BOOL isSameLines = NO;
        if ([oldJsonArray count]==[twitterJsonArray count]&&[oldJsonArray count]>0) {
            NSDictionary* oldTweet = [oldJsonArray objectAtIndex:0];
            NSDictionary* newTweet = [twitterJsonArray objectAtIndex:0];
            isSameLines = [oldTweet isEqualToDictionary:newTweet];
        } 
        
        if (!isSameLines) {
            NSMutableArray* newTwitterJsonArray = [NSMutableArray arrayWithCapacity:html5Element.twitterTweetNumber];
            int oldIndex = 0, newIndex = 0; 
            
            for (int i  = 0; i < html5Element.twitterTweetNumber; i++) {
                if (i>=[oldJsonArray count]&&i<[newTwitterJsonArray count]) {
                    NSDictionary* newTweet = [twitterJsonArray objectAtIndex:newIndex];
                    newIndex++;
                    [newTwitterJsonArray addObject:newTweet]; 
                    continue;
                } else if (i<[oldJsonArray count]&&i>=[newTwitterJsonArray count]) {
                    NSDictionary* oldTweet = [oldJsonArray objectAtIndex:oldIndex];
                    oldIndex++;
                    [newTwitterJsonArray addObject:oldTweet]; 
                    continue;
                } else if(i>=[oldJsonArray count]&&i>=[newTwitterJsonArray count]){
                    break;
                }
                NSDictionary* oldTweet = [oldJsonArray objectAtIndex:oldIndex];
                NSDictionary* newTweet = [twitterJsonArray objectAtIndex:newIndex];
                NSString* oldDateString = [oldTweet objectForKey:@"created_at"];
                NSString* newDateString = [oldTweet objectForKey:@"created_at"];
                NSDateFormatter* dateFormatter = [self _HTTPDateFormatter];
                NSDate* oldTweetDate = [dateFormatter dateFromString:oldDateString];
                NSDate* newTweetDate = [dateFormatter dateFromString:newDateString];
                if ([newTweetDate timeIntervalSince1970]>[oldTweetDate timeIntervalSince1970]) {
                    newIndex++;
                    [newTwitterJsonArray addObject:newTweet];
                } else if ([newTweetDate timeIntervalSince1970]==[oldTweetDate timeIntervalSince1970]) {
                    newIndex++;
                    oldIndex++;
                    [newTwitterJsonArray addObject:newTweet];
                } else {
                    oldIndex++;
                    [newTwitterJsonArray addObject:oldTweet];
                }
            }
            [twitterJsonArray release];
            twitterJsonArray = [[NSArray alloc] initWithArray:newTwitterJsonArray];
            [[twitterJsonArray JSONRepresentation] writeToFile:self.filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        
    }
    
    return YES;
}

@end
