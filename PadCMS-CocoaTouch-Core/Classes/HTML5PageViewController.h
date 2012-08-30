//
//  HTML5PageViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Mikhail Kotov on 8/21/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimplePageViewController.h"
#import "RssParser.h"
#import "RssChannel.h"
#import "RssDate.h"
#import "RssItem.h"

@interface HTML5PageViewController : SimplePageViewController <UIWebViewDelegate, RssParserDelegate>{
    //UIWebView* _webView;
    NSArray* _twitter;
}

@property(nonatomic, retain) NSString* homeDirectory;
@end
