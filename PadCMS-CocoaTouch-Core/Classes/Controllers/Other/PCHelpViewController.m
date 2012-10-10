//
//  PCHelpViewController.h
//  Pad CMS
//
//  Edit by Igor Getmanenko on 29.03.12.
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

#import "PCHelpViewController.h"
//#import "PCMainViewController.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"
#import "PCIssue.h"
#import "PCRevision.h"
#import "MBProgressHUD.h"
#import "Helper.h"
#import "PCScrollView.h"

@interface PCHelpViewController()

- (void) rotateViewControllerToOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void) deviceOrientationDidChange;
- (void) removeHelpView;
- (void) showHUD;
- (void) hideHUD;

@end

@implementation PCHelpViewController

@synthesize contentScroll = _contentScroll;
@synthesize tintColor = _tintColor;
@synthesize revision = _revision;
@synthesize delegate = _delegate;

- (id)initWithRevision:(PCRevision *)revision;
{
    self = [super init];
    
    if (self)
    {
        _tintColor = nil;
        _contentScroll = nil;
        _revision = [revision retain];
    }
    
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCHelpItemDidDownloadNotification object:nil];
    [_tintColor release], _tintColor = nil;
    [_contentScroll release], _contentScroll = nil;
    [_revision release], _revision = nil;
    [super dealloc];
}


- (void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
//	[self showHUD];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endDownloadingPCHelpPageDownloadOperationOperation:) name:PCHelpItemDidDownloadNotification object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(BOOL)shouldAutorotate{
    return YES;
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self rotateViewControllerToOrientation:interfaceOrientation];
    return YES;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (void) removeHelpView
{
    [self.delegate dismissPCHelpViewController:self];
}

- (void) deviceOrientationDidChange
{
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        [self rotateViewControllerToOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    else if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
    {
        [self rotateViewControllerToOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void) rotateViewControllerToOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.contentScroll == nil)
    {
        _contentScroll = [[PCScrollView alloc] initWithFrame:self.view.frame];
    }
    
    for (UIView *subview in [self.contentScroll subviews])
    {
		[subview removeFromSuperview];
    }
    
    UIImage *contentImage = nil; 
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        self.view.frame = CGRectMake(0, 0, 768, 1024);
        NSString *fullResourcePath = [self.revision.contentDirectory stringByAppendingPathComponent:[self.revision.helpPages objectForKey:@"vertical"]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath];
        if (!fileExists)
        {
			[self showHUD];
      [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:@"vertical" userInfo:nil];
        }
		else {
			[self hideHUD];
		}
        contentImage = [UIImage imageWithContentsOfFile:fullResourcePath];
    }
    else
    {
        self.view.frame = CGRectMake(0, 0, 1024, 768);
        NSString *fullResourcePath = [self.revision.contentDirectory stringByAppendingPathComponent:[self.revision.helpPages objectForKey:@"horizontal"]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath];
        if (!fileExists)
        {
			[self showHUD];
     	[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:@"horizontal" userInfo:nil];
        }
		else {
			[self hideHUD];
		}
        contentImage = [UIImage imageWithContentsOfFile:fullResourcePath];
    }
    
    self.contentScroll.frame = self.view.frame;
    
    UIImageView *contentImageView = [[UIImageView alloc] initWithImage:contentImage];
    if ([Helper currentDeviceResolution] == RETINA)
    {
      contentImageView.frame = CGRectMake(0, 0, contentImage.size.width/2.0, contentImage.size.height/2.0);
       self.contentScroll.contentSize = CGSizeMake(contentImage.size.width/2.0, contentImage.size.height/2.0);
    }
    else {
      contentImageView.frame = CGRectMake(0, 0, contentImage.size.width, contentImage.size.height);
       self.contentScroll.contentSize = CGSizeMake(contentImage.size.width, contentImage.size.height);
    }
    
   
    
    [self.contentScroll addSubview:contentImageView];
    
    [contentImageView release];
    
	[self.view addSubview:self.contentScroll];
    
    UIButton* btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary* buttonOption = nil;
    if (self.tintColor)
    {
        buttonOption = [NSDictionary dictionaryWithObject:self.tintColor forKey:PCButtonTintColorOptionKey];
    }
	[[PCStyler defaultStyler] stylizeElement:btnReturn withStyleName:PCGallaryReturnButtonKey withOptions:buttonOption];
	[btnReturn addTarget:self action:@selector(removeHelpView) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnReturn];
}


#pragma mark PCHelpPageDownloadOperationDelegate method

- (void) endDownloadingPCHelpPageDownloadOperationOperation:(NSNotification *)notif
{
    if ([[[notif userInfo]objectForKey:@"orientation"]isEqualToString:@"horizontal"])
    {
        [self rotateViewControllerToOrientation:UIInterfaceOrientationLandscapeRight];
    }
    else
    {
        [self rotateViewControllerToOrientation:UIInterfaceOrientationPortrait];
    }
}

-(void)showHUD
{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (UIInterfaceOrientationIsPortrait(orientation))
	{
		if (self.revision.isVerticalHelpComplete) return;
	}
	else {
		if (self.revision.isHorizontalHelpComplete) return;
	}
	
	if (HUD)
	{
		self.revision.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	self.revision.progressDelegate = HUD;
	[HUD show:YES];
}



-(void)hideHUD
{
	if (HUD)
	{
		[HUD hide:YES];
		self.revision.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
}



@end
