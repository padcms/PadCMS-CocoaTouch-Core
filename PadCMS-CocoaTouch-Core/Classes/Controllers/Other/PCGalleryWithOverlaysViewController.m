//
//  PCGalleryWithOverlaysViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Oleg Zhitnik on 04.07.12.
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

#import "PCGalleryWithOverlaysViewController.h"
#import "PCPage.h"
#import "PCScrollView.h"
#import "PCPageElementGallery.h"
#import "MBProgressHUD.h"

#define kHUDTag 1911

@interface PCGalleryWithOverlaysViewController ()
- (void)updateGallery:(NSNotification*)notif;
- (void)createImageViews;
- (void)showPhotoAtIndex:(NSInteger)currentIndex;
- (void)showImageAtIndex:(NSUInteger)index;
- (void)hideImageAtIndex:(NSUInteger)index;
- (void)afterScroll;
- (void)hideHUDAtIndex:(NSUInteger)index;
- (void)showHUDAtIndex:(NSUInteger)index;
- (void)removeImageViews;
- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer;
- (void)popupAction:(UIButton*)sender;
@end

@implementation PCGalleryWithOverlaysViewController
@synthesize page = _page;
@synthesize mainScrollView = _mainScrollView;
@synthesize galleryID = _galleryID;
@synthesize horizontalOrientation = _horizontalOrientation;
@synthesize galleryElements = _galleryElements;
@synthesize imageViews = _imageViews;
@synthesize overlayImageViews;
@synthesize currentPage;

- (id) initWithPage: (PCPage *)initialPage
{
	self = [super init];
    if (self)
	{
        _mainScrollView = nil;
        self.page = initialPage;
        _horizontalOrientation = FALSE;
        _galleryID = -1;
        currentPage = 0;
        _currentIndex = NSIntegerMax;
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCGalleryElementDidDownloadNotification object:self.page];
    if (_galleryElements)
    {
        [_galleryElements release], _galleryElements = nil;
    }
    [_imageViews release], _imageViews = nil;
    [_mainScrollView release], _mainScrollView = nil;
    [_page release]; _page = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGallery:) name:PCGalleryElementDidDownloadNotification object:self.page];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.imageViews = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeImageViews];
    _currentIndex = NSIntegerMax;
    self.galleryID = -1;
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    if(_horizontalOrientation)
    {
        self.view.frame = CGRectMake(0, 0, 768, 1024);
    } else {
        self.view.frame = CGRectMake(0, 0, 1024, 768);
    }
    
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    self.galleryElements = tempArray;
    [tempArray release];
    
    self.mainScrollView = [[[PCScrollView alloc] initWithFrame:self.view.frame] autorelease];
	[self.view addSubview:self.mainScrollView];
	self.mainScrollView.pagingEnabled = YES;
	self.mainScrollView.bounces = NO;
	self.mainScrollView.alwaysBounceHorizontal = NO;
    self.mainScrollView.delegate = self;
    
    NSArray *pageGalleryElements = [self.page elementsForType:PCPageElementTypeGallery];
    
    if (self.galleryID > 0)
    {
        for (PCPageElementGallery *galleryElement in pageGalleryElements)
        {
            if (galleryElement.galleryID == self.galleryID)
            {
                [self.galleryElements addObject:galleryElement];
            }
        }
    }
    
    else 
    {
        [self.galleryElements addObjectsFromArray:pageGalleryElements];
    }
    
    if(_horizontalOrientation)
    {
        self.mainScrollView.contentSize = CGSizeMake(768, 1024 * [self.galleryElements count]);
    } else {
        self.mainScrollView.contentSize = CGSizeMake(1024, 768 * [self.galleryElements count]);
    }
    
    if (![self.galleryElements lastObject]) return;
    
    currentPage = 0;
    [self createImageViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Private

-(void)updateGallery:(NSNotification*)notif
{
    PCPageElement* galleryElement = [[notif userInfo] objectForKey:@"element"];
	NSUInteger index = [self.galleryElements indexOfObject:galleryElement];
	if (index == NSNotFound)
	{
		NSLog(@"NSNot foung result for index while updating gallery");
		return;
	}
	[self hideHUDAtIndex:index];
    
    NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:galleryElement.resource];
	NSInteger currentIndex = lrint(self.mainScrollView.contentOffset.y/self.mainScrollView.frame.size.height);
	if ([[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath] && !(ABS(currentIndex - index) > 1))
	{
		UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
		[[self.imageViews objectAtIndex:index] setImage:image];
	}
}

- (void)createImageViews
{	
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    self.imageViews = tempArray;
    [tempArray release];
    
    for (int i=0; i<[self.galleryElements count]; i++)
    {
		UIImageView* imageView;
        
        if(_horizontalOrientation)
        {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, i*1024, 768, 1024)];
        } else {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, i*768, 1024, 768)];
        }
		
		imageView.userInteractionEnabled = YES;
        CGRect      frame = imageView.frame;
        imageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        imageView.frame = frame;
        
        PCPageElement* element = [self.galleryElements objectAtIndex:i];
		NSArray* popups = [[element.dataRects allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@",PCPDFActiveZonePopup]];
		for (NSString* type in popups) {
			NSLog(@"POPUP - %@", type);
			CGRect rect = [element rectForElementType:type];
			if (!CGRectEqualToRect(rect, CGRectZero))
			{
				CGSize pageSize = imageView.bounds.size;
				float scale = pageSize.width/element.size.width;
				rect.size.width *= scale;
				rect.size.height *= scale;
				rect.origin.x *= scale;
				rect.origin.y *= scale;
				rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
				UIButton* popup = [UIButton buttonWithType:UIButtonTypeCustom];
				[popup setFrame:rect];
				popup.tag = 100 + [[type lastPathComponent] intValue];
				[popup addTarget:self action:@selector(popupAction:) forControlEvents:UIControlEventTouchUpInside];
				//popup.backgroundColor = [UIColor redColor];
				[imageView addSubview:popup];			
			}
		}
		
		[self.imageViews addObject:imageView];
		[self.mainScrollView addSubview:imageView];
		[imageView release];
    }
	
	[self showPhotoAtIndex:self.currentPage];
}

-(void)popupAction:(UIButton*)sender
{
	
	for (UIView* v in sender.superview.subviews) {
		if ([v isKindOfClass:[UIImageView class]])
		{
			[v removeFromSuperview];
			if (v.tag == sender.tag) return;
		}
	}
	int index = sender.tag - 100 - 1;
	NSArray* popupsElements = [self.page elementsForType:PCPageElementTypePopup];
	PCPageElement*popupElement = [popupsElements objectAtIndex:index];
	if (!popupElement.isComplete)
		[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:popupElement];
	NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:popupElement.resource];
	UIImageView* popupView = [[UIImageView alloc] initWithFrame:sender.superview.bounds];
	popupView.tag = sender.tag;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if (popupElement.isComplete && [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath])
		{
			UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
			dispatch_async(dispatch_get_main_queue(), ^{
				[popupView setImage:image];
			});
			
		}
	});
	
	popupView.userInteractionEnabled = YES;
	UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	//tapGestureRecognizer.delegate = self;
    [popupView  addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];
	[sender.superview addSubview:popupView];
	[sender.superview sendSubviewToBack:popupView];
	[popupView release];
}

-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
	[gestureRecognizer.view removeFromSuperview];
}

-(void)showPhotoAtIndex:(NSInteger)currentIndex
{
	if (currentIndex < 0 || currentIndex >= [self.galleryElements count]) return;
	PCPageElement* element = (PCPageElement*)[self.galleryElements objectAtIndex:currentIndex];
	if (!element.isComplete)
		[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:element];
	if (_currentIndex != currentIndex)
	{
		_currentIndex = currentIndex;
		if (!element.isComplete)
		{
			[self showHUDAtIndex:_currentIndex];
			for (int i =0; i < [self.galleryElements count]; ++i) {
				if (i != _currentIndex)
				{
					[self hideHUDAtIndex:i];
				}
			}
		}
		
		for (int i =0; i < [self.galleryElements count]; ++i)
		{
			if (ABS(currentIndex - i) > 1)
			{
				[self hideImageAtIndex:i];	
			}
			else
			{
				[self showImageAtIndex:i];
			}
		}
	}
}

-(void)showImageAtIndex:(NSUInteger)index
{
	if ([[self.imageViews objectAtIndex:index] image]) return;
	PCPageElement* galleryElement = ((PCPageElement*)[self.galleryElements objectAtIndex:index]);
	NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:galleryElement.resource];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if (galleryElement.isComplete && [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath])
		{
			UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
			dispatch_async(dispatch_get_main_queue(), ^{
				[[self.imageViews objectAtIndex:index] setImage:image];
                NSLog(@"GO element with id=%d res=%@", galleryElement.identifier, galleryElement.resource);
			});
			
		}
	});
}

- (void)removeImageViews
{
    for (int i=0; i<[self.imageViews count]; i++)
    {
        [[self.imageViews objectAtIndex:i] removeFromSuperview];
        [self hideHUDAtIndex:i];
    }
    self.imageViews = nil;
}

-(void)hideImageAtIndex:(NSUInteger)index
{
	[[self.imageViews objectAtIndex:index] setImage:nil];
}

-(void)showHUDAtIndex:(NSUInteger)index
{
	PCPageElement* element = (PCPageElement*)[self.galleryElements objectAtIndex:index];
	if (element.isComplete) return;
	UIImageView* currentImageView = ((UIImageView*)[self.imageViews objectAtIndex:index]);
	UIView* prevHUD = [currentImageView viewWithTag:kHUDTag];
	if (prevHUD != nil)
	{
		[self hideHUDAtIndex:index];
	}
	MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:currentImageView];
	HUD.tag = kHUDTag;
	[currentImageView addSubview:HUD];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	((PCPageElement*)[self.galleryElements objectAtIndex:index]).progressDelegate = HUD;
	[HUD show:YES];
    [HUD release], HUD = nil;
}

-(void)hideHUDAtIndex:(NSUInteger)index
{
	UIImageView* currentImageView = ((UIImageView*)[self.imageViews objectAtIndex:index]);
	MBProgressHUD* HUD = (MBProgressHUD*)[currentImageView viewWithTag:kHUDTag];
	if (HUD)
	{
		[HUD hide:YES];
		((PCPageElement*)[self.galleryElements objectAtIndex:index]).progressDelegate = nil;
		[HUD removeFromSuperview];
		HUD = nil;
	}
}

- (void) afterScroll
{
    self.currentPage = lrint(self.mainScrollView.contentOffset.y/self.mainScrollView.frame.size.height);
}

#pragma mark UIScrollViewDelegate methods

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	scrollView.userInteractionEnabled = NO;
    [self afterScroll]; 
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	scrollView.userInteractionEnabled = YES;
	NSInteger currentIndex = lrint(self.mainScrollView.contentOffset.y/self.mainScrollView.frame.size.height);
	[self showPhotoAtIndex:currentIndex];
    [self afterScroll]; 
}

@end
