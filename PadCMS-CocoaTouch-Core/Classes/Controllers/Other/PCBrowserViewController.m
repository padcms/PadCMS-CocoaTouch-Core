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
