//
//  HTML5PageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Mikhail Kotov on 8/21/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "HTML5PageViewController.h"
#import "PCLandscapeViewController.h"
#import "ZipArchive.h"
//#import "PCVideoController.h"

#import "PCPageElementHtml5.h"

#import "JSON.h"

@interface HTML5PageViewController ()
{
    BOOL _webViewVisible;
    PCPageElementHtml5* pageElement;
    PCLandscapeViewController* _webViewController;
}

- (void)showBrowser;
- (void)hideBrowser;
@end

@implementation HTML5PageViewController

@synthesize homeDirectory;

- (void)dealloc{
    [_webViewController release];
    [super dealloc];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];

    [self loadFullView];
}

-(void)createViewWithResource:(id) resource{
    UIWebView* _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        _webView.frame = CGRectMake(0, 0, 1024, 768);
    }

    _webView.backgroundColor = [UIColor blackColor];
    //_webView.userInteractionEnabled = false;
    [_webView setDelegate:self];
    _webViewController = [[PCLandscapeViewController alloc] init];
    
    [_webViewController.view addSubview:_webView];
    
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityView setFrame:CGRectMake((_webView.frame.size.width-activityView.frame.size.width)/2, (_webView.frame.size.height-activityView.frame.size.height)/2, activityView.frame.size.width, activityView.frame.size.height)];
    [activityView setTag:100];
    [activityView startAnimating];
    [_webViewController.view addSubview:activityView];
    [activityView release];
    if ([resource isKindOfClass:[NSURL class]]) {
        [_webView loadRequest:[NSURLRequest requestWithURL:resource]];
    }
    else if ([resource isKindOfClass:[NSString class]]) {
        [_webView loadHTMLString: resource baseURL:nil];
    }
    [_webView release];
}

-(void)loadFullView
{
    [super loadFullView];
	
	pageElement = (PCPageElementHtml5*)[self.page firstElementForType:PCPageElementTypeHtml5];
    if ([pageElement.html5Body isEqualToString:PCPageElementHtml5BodyCodeType]) {
        //[self loadFullViewForHtml5Code];
    } else if ([pageElement.html5Body isEqualToString:PCPageElementHtml5BodyFacebookLikeType]) {
        //[self loadFullViewForFaceBookLike];
    } else if ([pageElement.html5Body isEqualToString:PCPageElementHtml5BodyGoogleMapsType]) {
        //[self loadFullViewForGoogleMaps];
    } else if ([pageElement.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]) {
        [self loadFullViewForRssNewsline];
    } else if ([pageElement.html5Body isEqualToString:PCPageElementHtml5BodyTwitterType]) {
        //[self loadFullViewForTwitterLine];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Check if this was a click event and then some other criteria for determining if you want to launch Safari.
    if (navigationType == UIWebViewNavigationTypeLinkClicked && [pageElement.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    return true;
}

#pragma mark HTML5
- (void)loadFullViewForHtml5Code {
    NSLog(@"html5Element = %@", [pageElement description]);
    NSURL *url = nil;
    NSString *archivePath = [[_page.revision contentDirectory] stringByAppendingPathComponent:pageElement.resource];
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL openFileResult = [zipArchive UnzipOpenFile:archivePath];
    NSLog(@"%@ for '%@'",openFileResult?@"yes openFileResult":@"no openFileResult", archivePath);
    if (openFileResult)
    {
        NSString *outputDirectory = [[archivePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"resource"];
        
        [zipArchive UnzipFileTo:outputDirectory overWrite:YES];
        url = [NSURL fileURLWithPath:[outputDirectory stringByAppendingPathComponent:@"index.html"]];
        NSLog(@"file URL: '%@'",url);
        [zipArchive UnzipCloseFile];
    }
    
    [zipArchive release];

    [self createViewWithResource:url];
}

#pragma mark RSS


- (void)loadFullViewForRssNewsline {
    
    NSString* rssXmlFile = [[_page.revision contentDirectory] stringByAppendingPathComponent:[pageElement rssNewsXmlFilePath]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:rssXmlFile]) {
        RssParser* parser = [RssParser parseRssData:[NSData dataWithContentsOfFile:rssXmlFile]
                                           toTarget:self];
        [parser parse];
    }
}

- (void)parser:(RssParser*)parser endParseRssChanel:(RssChannel*)channel
{
    NSMutableString* htmlRSS = [NSMutableString stringWithString:@"<html><body>" ];
    NSLog(@"END PARSE SUCCESSFUL %@",parser.channel);
    //title
    [htmlRSS appendFormat:@"<h2>%@</h2><br>",parser.channel.title.text];
    //news
    for (RssItem* curObj in parser.channel.items) {
        [htmlRSS appendFormat:@"<h4><a href=%@><b>%@</b></a></br>%@</h4><hr>", curObj.link.text, curObj.title.text, curObj.elementDescription.text];
    }
    [htmlRSS appendFormat:@"<h2>%@</h2><br>",parser.channel.title.text];
    [htmlRSS appendString:@"</body></html>"];
    [self createViewWithResource:htmlRSS];
}

- (void)parser:(RssParser *)parser endParseWithError:(NSError*)error
{
    NSLog(@"END PARSE WITH ERROR");
}

/////////////////////////


-(void)showBrowser
{
    if (_webViewVisible) {
        return;
    }
    
    if (!_webViewController.presentingViewController)
        [self.delegate presentViewController:_webViewController animated:YES completion:nil];
	
    _webViewVisible = YES;
}

- (void)hideBrowser
{
	if (!_webViewVisible) {
        return;
		
    }
	
	
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
	
    _webViewVisible = NO;
}



-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    if (pageElement)
    {
        if (_webViewVisible) {
            [self hideBrowser];
        } else {
            [self showBrowser];
        }
    }
}


-(void)deviceOrientationDidChange
{
    NSLog(@"deviceOrientationDidChange");
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        //[self showBrowser];
        _webViewController.view.frame = CGRectMake(0, 0, 1024, 768);
    }
    else if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        //[self hideBrowser];
        _webViewController.view.frame = CGRectMake(0, 0, 768, 1024);
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showBrowser];
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[_webViewController.view viewWithTag:100];
    [activityView stopAnimating];
    activityView.hidden = YES;
}

@end
