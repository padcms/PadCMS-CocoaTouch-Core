//
//  PCBrowserViewController.h
//  Pad CMS
//
//  Created by Igor Getmanenko on 10.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCBrowserViewController : UIViewController
{
    UIWebView *_webView;
}

@property (nonatomic, retain) UIWebView *webView;

- (void) presentURL:(NSString *) url;
- (void) presentFile:(NSString *) file;

@end
