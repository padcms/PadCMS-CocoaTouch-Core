//
//  PCBrowserViewController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 10.02.12.
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

#import "PCBrowserViewController.h"
#import "PCVideoController.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"
#import "MBProgressHUD.h"
#import "PCLocalizationManager.h"

@interface PCBrowserViewController()

- (void) createWebView;
- (void) createReturnButton;
- (void) showHUD;
- (void) hideHUD;

@end

@implementation PCBrowserViewController

@synthesize webView = _webView;
@synthesize HUD = _HUD;
@synthesize videoRect = _videoRect;
@synthesize videoURL = _videoURL;

- (id) init
{
    self = [super init];
    if (self)
    {
        _webView = nil;
        _HUD = nil;
        _videoURL = nil;
        _videoRect = CGRectZero;
    }
    return self;
}

- (void) dealloc
{
    [_webView release], _webView = nil;
    [_HUD release], _HUD = nil;
    [_videoURL release], _videoURL = nil;
    _videoRect = CGRectZero;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self createWebView];
    [self createReturnButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self hideHUD];
    [self backButtonTap];
    
    [super viewDidDisappear:animated];
}

- (void) createWebView
{
    UIWebView *tempWebView = [[UIWebView alloc] initWithFrame:self.videoRect];
    self.webView = tempWebView;
    [tempWebView release];
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO; 
    self.webView.scrollView.bounces = NO;
    [self.view addSubview:self.webView];
}

- (void) createReturnButton
{
    if (CGSizeEqualToSize(self.videoRect.size, [[UIScreen mainScreen] bounds].size))
    {
        UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton addTarget:self action:@selector(backButtonTap) forControlEvents:UIControlEventTouchUpInside];
        NSDictionary *buttonOption = [NSDictionary dictionaryWithObject:[NSValue valueWithCGRect:self.view.frame] forKey:PCButtonParentViewFrameKey];
        [[PCStyler defaultStyler] stylizeElement:backButton withStyleName:PCGallaryReturnButtonKey withOptions:buttonOption];
        [backButton setFrame:CGRectMake(self.view.frame.size.width - backButton.frame.size.width, 0, backButton.frame.size.width, backButton.frame.size.height)];
        [[PCStyler defaultStyler] stylizeElement:backButton withStyleName:PCGallaryReturnButtonKey withOptions:buttonOption];
        [self.view addSubview:backButton];
    }
}

- (void) backButtonTap
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	//[self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView removeFromSuperview];
    [self.webView release], self.webView = nil;
    for (UIView *subview in self.view.subviews)
    {
        [subview removeFromSuperview];
    }
    [self.view removeFromSuperview];
}

- (void) presentURL:(NSString*) url
{
    self.videoURL = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.videoURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240.0]];
    [self showHUD];
}

-(void)showHUD
{
    if (!self.HUD)
    {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.webView];
        self.HUD.labelText = [PCLocalizationManager localizedStringForKey:@"LABEL_LOADING"
                                                                    value:@"Loading"];
    }
    
    [self.webView addSubview:self.HUD];
    [self.HUD show:YES];
}

-(void)hideHUD
{
	if (self.HUD)
	{
        [self.HUD hide:YES];
		[self.HUD removeFromSuperview];
		[self.HUD release];
		self.HUD = nil;
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL absoluteURL] isEqual:[self.videoURL absoluteURL]])
        return YES;
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [self hideHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideHUD];
}

@end
