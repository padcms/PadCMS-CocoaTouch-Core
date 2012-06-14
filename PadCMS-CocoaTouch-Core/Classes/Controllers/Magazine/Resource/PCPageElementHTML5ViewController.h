//
//  PCPageElementHTML5ViewController.h
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementViewController.h"
#import "PCTwitterImageDownloadOperationDelegate.h"
#import "RssParserDelegate.h"
@class PCPageElementHtml5, RssChannel;

@interface PCPageElementHTML5ViewController : PCPageElementViewController <PCTwitterImageDownloadOperationDelegate, UITableViewDataSource, UITableViewDelegate, RssParserDelegate> 
{
    UIWebView* _webView;
    
    NSArray* _twitterJsonArray;
    RssChannel* _rssChannel;    
    UITableView* _tableView;
    UIImageView* _backgroundImageView;
    
}

@property(nonatomic, retain) PCPageElementHtml5* html5Element;
@property(nonatomic ,retain) NSString* homeDirectory;

- (id)initWithElement:(PCPageElementHtml5*)element withHomeDirectory:(NSString*)directory;
- (void) loadFullView;
- (void) unloadView;

@end
