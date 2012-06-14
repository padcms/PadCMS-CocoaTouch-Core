//
//  PCBrowserViewController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 10.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import "PCBrowserViewController.h"
#import "PCVideoController.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"

@implementation PCBrowserViewController

@synthesize webView = _webView;

- (id) init
{
    self = [super init];
    if (self)
    {
        _webView = nil;
    }
    return self;
}

- (void) dealloc
{
    [_webView release], _webView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWebView *tempWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,768,1024)];
    self.webView = tempWebView;
    [tempWebView release];
    [self.view addSubview:self.webView];
    
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(backButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [[PCStyler defaultStyler] stylizeElement:backButton withStyleName:PCGallaryReturnButtonKey withOptions:nil];
    backButton.frame = CGRectMake(710, 945, backButton.frame.size.width, backButton.frame.size.height);
    [self.view addSubview:backButton];
}

- (void) backButtonTap
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	[self.webView loadHTMLString:@"" baseURL:nil];
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } 
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void) presentURL:(NSString*) url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240.0]];
}

- (void) presentFile:(NSString*) file
{
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:file] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240.0]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
	return YES;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
