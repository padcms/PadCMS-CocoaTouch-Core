//
//  HTMLPageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/24/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "HTMLPageViewController.h"
#import "PCLandscapeViewController.h"
#import "ZipArchive.h"
#import "PCVideoController.h"
@interface HTMLPageViewController ()
{
    BOOL _webViewVisible;
    PCLandscapeViewController* _webViewController;
}

- (void)showBrowser;
- (void)hideBrowser;
@end

@implementation HTMLPageViewController

-(void)dealloc
{
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
    PCPageElementHtml* pageElement = (PCPageElementHtml*)[self.page firstElementForType:PCPageElementTypeHtml];
	
    if (pageElement && (pageElement.templateType==PCPageElementHtmlRotationType || pageElement.templateType==PCPageElementHtmlUnknowType) )
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
	
    _webViewVisible = NO;
}

-(void)loadFullView
{
    [super loadFullView];
	
	PCPageElementHtml* pageElement = (PCPageElementHtml*)[self.page firstElementForType:PCPageElementTypeHtml];
	
    if (pageElement && (pageElement.templateType==PCPageElementHtmlRotationType || pageElement.templateType==PCPageElementHtmlUnknowType) )
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
	
    _webViewVisible = NO;

	
    if (_webViewController == nil) {
       		
        NSURL *url = nil;
        if (pageElement.htmlUrl != nil) {
            url = [NSURL URLWithString:pageElement.htmlUrl];    
        } else {
			
            NSString *archivePath = [[_page.revision contentDirectory] stringByAppendingPathComponent:pageElement.resource];
            
            ZipArchive *zipArchive = [[ZipArchive alloc] init];
            BOOL openFileResult = [zipArchive UnzipOpenFile:archivePath];
            
            if (openFileResult)
            {
                NSString *outputDirectory = [[archivePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"resource"];
				
                [zipArchive UnzipFileTo:outputDirectory overWrite:YES];
                url = [NSURL fileURLWithPath:[outputDirectory stringByAppendingPathComponent:@"index.html"]];
                
                [zipArchive UnzipCloseFile];
            }
            
            [zipArchive release];
        }
        
        _webViewController = [[PCLandscapeViewController alloc] init];
        
        CGRect      webViewRect;
        
     /*   if (self.columnViewController.horizontalOrientation) {
            webViewRect = CGRectMake(0, 0, 768, 1024);
        } else {
            webViewRect = CGRectMake(0, 0, 1024, 786);
        }*/
        
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 786)];
        webView.backgroundColor = [UIColor blackColor];
        [webView setDelegate:self];
        
        [_webViewController.view addSubview:webView];
        
        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView setFrame:CGRectMake((webView.frame.size.width-activityView.frame.size.width)/2, (webView.frame.size.height-activityView.frame.size.height)/2, activityView.frame.size.width, activityView.frame.size.height)];
        [activityView setTag:100];
        [activityView startAnimating];
        [_webViewController.view addSubview:activityView];
        [activityView release];
        
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView release];
    }
}


-(void)showBrowser
{
    if (_webViewVisible) {
        return;
    }
    
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
    PCPageElementHtml* pageElement =(PCPageElementHtml*)[self.page firstElementForType:PCPageElementTypeHtml];
    if (pageElement)
    {
        if (pageElement.templateType==PCPageElementHtmlTouchType)
        {    
            [self showBrowser];
        }
        else 
        {
          //  [super tapAction:gestureRecognizer];
        }
    }
}


-(void)deviceOrientationDidChange
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        [self showBrowser];
    } else {
        [self hideBrowser];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[_webViewController.view viewWithTag:100];
    [activityView stopAnimating];
    activityView.hidden = YES;
}


@end
