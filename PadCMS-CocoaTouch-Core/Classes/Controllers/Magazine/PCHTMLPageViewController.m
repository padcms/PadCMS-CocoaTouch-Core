//
//  PCHTMLPageViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCHTMLPageViewController.h"
#import "PCVideoController.h"
#import "PCLandscapeViewController.h"

@interface PCHTMLPageViewController ()
- (BOOL)isOrientationChanged:(UIDeviceOrientation)orientation;
- (void)showBrowser;
- (void)hideBrowser;
@end

@implementation PCHTMLPageViewController

@synthesize webViewController;

-(void)dealloc
{
    self.webViewController = nil;
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
    currentMagazineOrientation = [[UIDevice currentDevice] orientation];
    webViewIsShowed = NO;
}

-(void)loadFullView
{
    [super loadFullView];

    if (self.webViewController==nil)
    {
        PCPageElementHtml* pageElement =(PCPageElementHtml*)[self.page firstElementForType:PCPageElementTypeHtml];
        NSURL* url = [NSURL URLWithString:pageElement.htmlUrl];
        self.webViewController = [[[PCLandscapeViewController alloc] init] autorelease];
        
        CGRect      webViewRect;
        
        if(self.columnViewController.horizontalOrientation)
        {
            webViewRect = CGRectMake(0, 0, 768, 1024);
        } else {
            webViewRect = CGRectMake(0, 0, 1024, 786);
        }
        
        UIWebView* webView = [[UIWebView alloc] initWithFrame:webViewRect];
        webView.backgroundColor = [UIColor blackColor];
        [webView setDelegate:self];
        [self.webViewController.view addSubview:webView];
        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView setFrame:CGRectMake((webView.frame.size.width-activityView.frame.size.width)/2, (webView.frame.size.height-activityView.frame.size.height)/2, activityView.frame.size.width, activityView.frame.size.height)];
        [activityView setTag:100];
        [activityView startAnimating];
        [self.webViewController.view addSubview:activityView];
        [activityView release];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView release];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[self.webViewController.view viewWithTag:100];
    [activityView stopAnimating];
    activityView.hidden = YES;
}

-(void)unloadFullView
{
    [super unloadFullView];
    self.webViewController = nil;
}

-(void)showBrowser
{

    if(!webViewIsShowed)
    {
        if ([self.magazineViewController.mainViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) 
        {
            [self.magazineViewController.mainViewController presentViewController:self.webViewController animated:YES completion:nil];
        } 
        else 
        {
            [self.magazineViewController.mainViewController presentModalViewController:self.webViewController animated:YES];   
        }
        webViewIsShowed = YES;
    }
    
    /*if (self.magazineViewController.mainViewController.modalViewController == nil)
    {
        if ([self.magazineViewController.mainViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) 
        {
            [self.magazineViewController.mainViewController presentViewController:self.webViewController animated:YES completion:nil];
        } 
        else 
        {
            [self.magazineViewController.mainViewController presentModalViewController:self.webViewController animated:YES];   
        }
    }
    else 
    {
        if ([self.magazineViewController.mainViewController.modalViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
        {
            [self.magazineViewController.mainViewController.modalViewController dismissViewControllerAnimated:YES completion:nil];
        } 
        else
        {
            [self.magazineViewController.mainViewController.modalViewController dismissModalViewControllerAnimated:YES];
        }
    }
    */
}

- (void)hideBrowser
{
    if (webViewIsShowed)
    {
        if ([self.magazineViewController.mainViewController.modalViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
        {
            [self.magazineViewController.mainViewController.modalViewController dismissViewControllerAnimated:YES completion:nil];
        } 
        else
        {
            [self.magazineViewController.mainViewController.modalViewController dismissModalViewControllerAnimated:YES];
        }
        webViewIsShowed = NO;
    }
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
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
        {
            if (self.columnViewController.currentPageViewController == self && self.columnViewController.magazineViewController.currentColumnViewController == self.columnViewController)
                [self hideBrowser];
        }
    }
    else if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
    {
        if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
        {
            if (self.columnViewController.currentPageViewController == self && self.columnViewController.magazineViewController.currentColumnViewController == self.columnViewController)
                 [self showBrowser];
        }
    }
}

#pragma mark - private

- (BOOL)isOrientationChanged:(UIDeviceOrientation)orientation
{
    UIDeviceOrientation tempOrientation;
    tempOrientation = currentMagazineOrientation;
    
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsPortrait(tempOrientation));
    }
    else if (UIDeviceOrientationIsPortrait(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsLandscape(tempOrientation));
    }
    return NO;
}

@end
