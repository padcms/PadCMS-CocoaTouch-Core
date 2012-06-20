//
//  PCHorizontalPageController.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 27.03.12.
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

#import "PCHorizontalPageController.h"
#import "PCResourceView.h"
#import "PCResourceCache.h"
#import "PCConfig.h"
#import "PCRevisionViewController.h"
#import "MBProgressHUD.h"

@interface PCHorizontalPageController (private)
-(void) loadImage;
-(void) LoadImageThread:(id)someObject;
-(NSString*) ResourceUrl:(NSString*) resourceStr;
-(void) ProcessDownloadedImageData:(NSData*) imageData;
-(void) AssignImage:(UIImage*) image;
-(void) StopProgressIndicator;
-(void) PerformCacheResource:(NSData*)imageData;
-(BOOL) saveData:(NSData*)data toPath:(NSString*)path;
-(BOOL) LoadFromCache;
-(BOOL) ImageInCacheExists;
@end

@implementation PCHorizontalPageController
@synthesize revision;
@synthesize pageIdentifier;
@synthesize resource;
@synthesize revisionViewController;
@synthesize selected;
@synthesize identifier;
@synthesize horizontalPage;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.selected = NO;
        innerScroll = nil;
        imageView = nil;
    }
    return self;
}

- (void)dealloc
{
    self.revision = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCHorizontalPageDidDownloadNotification object:self.identifier];
	[self.horizontalPage removeObserver:self forKeyPath:@"isComplete"];
	self.horizontalPage = nil;
    self.resource = nil;
	self.identifier = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.bounds = CGRectMake(0, 0, 1024, 768);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endDownloadingPCHorizontalPageOperation:) name:PCHorizontalPageDidDownloadNotification object:self.identifier];
	[self.horizontalPage addObserver:self forKeyPath:@"isComplete" options:NSKeyValueObservingOptionNew context:NULL];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return innerView;
}

#pragma mark ------- Private --------

-(void)showHUD
{	
	if (!isLoaded) return;
//  if (!selected) return;
	if (self.horizontalPage.isComplete) return;
	if (HUD)
	{
		return;
		horizontalPage.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	horizontalPage.progressDelegate = HUD;
	[HUD show:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//[self showHUD];
}

-(void)hideHUD
{
	if (HUD)
	{
		[HUD hide:YES];
		horizontalPage.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
}


-(void) AssignImage:(UIImage*) image
{
    
    if(innerScroll==nil)
    {
        innerScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [innerScroll setBouncesZoom:NO];
        [innerScroll setDelegate:self];
        innerScroll.maximumZoomScale = 2.0f;
        
        innerView = [[UIView alloc] initWithFrame:self.view.bounds];
        [innerScroll addSubview:innerView];
        [innerView release];

        imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [innerView addSubview:imageView];
        [imageView release];
        
        [self.view addSubview:innerScroll];
        [innerScroll release];
    } else {
        innerScroll.zoomScale = 1;
    }
    
    [imageView setImage:image];
    [imageView sizeToFit];
    
    BOOL        adjustScroll = NO;
    CGRect      rect = imageView.bounds;
    CGSize      contentSize = self.view.bounds.size;
    CGFloat     zoom = 1.0;
    
    if(image.size.width <= self.view.bounds.size.width && image.size.height <= self.view.bounds.size.height) // image is smaller or equal
    {
        adjustScroll = YES;
    } else {
        CGFloat     viewAspect = self.view.bounds.size.width / self.view.bounds.size.height;  // 1.3(3)
        CGFloat     imageAspect = image.size.width / image.size.height;
        
        if(ABS(viewAspect-imageAspect)<0.00001)     // aspect is near equal
        {
            zoom = self.view.bounds.size.width / image.size.width;
            contentSize = image.size;
            adjustScroll = YES;
        } else {
            if(imageAspect > viewAspect)            // image is wider
            {
                zoom = self.view.bounds.size.width / image.size.width;
                contentSize = CGSizeMake(image.size.width, image.size.width/viewAspect);
            } else {                                // image is higher
                zoom = self.view.bounds.size.height / image.size.height;
                contentSize = CGSizeMake(image.size.height/viewAspect, image.size.height);
            }
            adjustScroll = YES;
        }
    }

    if(adjustScroll)
    {
        imageView.frame = rect;
        innerView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
        innerScroll.contentSize = contentSize;
        imageView.center = CGPointMake(contentSize.width/2, contentSize.height/2);
        innerScroll.minimumZoomScale = zoom;
        innerScroll.zoomScale = zoom;
    }
}

-(void) StopProgressIndicator
{
   // [progressView stopAnimating];
}

-(BOOL) LoadFromCache
{
    NSString        *filePath = [self.revision.contentDirectory stringByAppendingPathComponent:self.resource];
    NSData          *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if(imageData)
    {
        UIImage    *image = [UIImage imageWithData:imageData];
        
        if(image)
        {
            [self performSelectorOnMainThread:@selector(AssignImage:)
                                   withObject:image
                                waitUntilDone:NO];
            return YES;
        }
    }
    return NO;
}

-(BOOL) ImageInCacheExists
{
    NSString        *filePath = [self.revision.contentDirectory stringByAppendingPathComponent:self.resource];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return YES;
    }
    return NO;
}

- (void)endDownloadingPCHorizontalPageOperation:(NSNotification*)notif
{
    NSDictionary        *dict = notif.userInfo;
    NSNumber            *pageId = nil;
    
    if(dict)
    {
        id          pageIdentifierObj = [dict objectForKey:@"id"];
        
        if([pageIdentifierObj isKindOfClass:[NSNumber class]])
        {
            pageId = pageIdentifierObj;
        }
    }
	//[self hideHUD];
    if(selected)
    {
        if(pageId)
        {
            if([pageId integerValue]==self.pageIdentifier)
            {
                [self LoadFromCache];
                isLoaded = YES;
                [self hideHUD];
            }
        } else {
            isLoaded = YES;
            [self LoadFromCache];
        }
    }
}

-(void)progressOfDownloading:(CGFloat)_progress forHorizontalPageKey:(NSNumber*)key
{
}

- (void) loadFullView
{
	isLoaded = YES;
    self.selected = YES;
    [self LoadFromCache];
	//[self showHUD];
}

- (void) unloadFullView
{
    self.selected = NO;
	isLoaded = NO;
    imageView.image = nil;
	[self hideHUD];
}

-(void) observeValueForKeyPath: (NSString *)keyPath ofObject: (id) object
                        change: (NSDictionary *) change context: (void *) context
{
	if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) 
	{
		BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
		if (newValue) /*[self hideHUD];*/ [self performSelectorOnMainThread:@selector(hideHUD) withObject:nil waitUntilDone:NO];
		else [self performSelectorOnMainThread:@selector(showHUD) withObject:nil waitUntilDone:NO];;
	}
	
	
}


@end
