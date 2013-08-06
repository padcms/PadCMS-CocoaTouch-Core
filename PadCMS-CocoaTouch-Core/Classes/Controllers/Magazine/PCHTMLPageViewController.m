//
//  PCHTMLPageViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.03.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

#import "PCHTMLPageViewController.h"
#import "PCVideoController.h"
#import "PCLandscapeViewController.h"
#import "ZipArchive.h"

@interface PCHTMLPageViewController ()
{
    BOOL _webViewVisible;
    PCLandscapeViewController* _webViewController;
}

- (void)showBrowser;
- (void)hideBrowser;

@end

@implementation PCHTMLPageViewController

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

    if (_webViewController == nil) {
        PCPageElementHtml *pageElement =(PCPageElementHtml *)[self.page firstElementForType:PCPageElementTypeHtml];

        NSURL *url = nil;
        if (pageElement.htmlUrl != nil) {
            url = [NSURL URLWithString:pageElement.htmlUrl];    
        } else {

            NSString *archivePath = [[page.revision contentDirectory] stringByAppendingPathComponent:pageElement.resource];
            
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
        
        if (self.columnViewController.horizontalOrientation) {
            webViewRect = CGRectMake(0, 0, 768, 1024);
        } else {
            webViewRect = CGRectMake(0, 0, 1024, 786);
        }
        
        UIWebView* webView = [[UIWebView alloc] initWithFrame:webViewRect];
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

-(void)unloadFullView
{
    [super unloadFullView];
    _webViewController = nil;
}

-(void)showBrowser
{
    if (_webViewVisible) {
        return;
    }
    
    if (_webViewController && !_webViewController.presentingViewController)
    {
        [self.magazineViewController.mainViewController presentViewController:_webViewController animated:YES completion:nil];
    }
    
    _webViewVisible = YES;
}

- (void)hideBrowser
{
    if (!_webViewVisible) {
        return;
    }
    
    [self.magazineViewController.mainViewController.modalViewController dismissViewControllerAnimated:YES completion:nil];

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
            [super tapAction:gestureRecognizer];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)deviceOrientationDidChange
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) 
    {
        [self showBrowser];
    } 
    else if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
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
