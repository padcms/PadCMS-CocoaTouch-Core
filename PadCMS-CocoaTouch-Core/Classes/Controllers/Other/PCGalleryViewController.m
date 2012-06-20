//
//  PCGalleryViewController.m
//  Pad CMS
//
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

#import "PCGalleryViewController.h"
#import "PCPageElement.h"
#import "PCCustomPageControll.h"
#import "PCStyler.h"
#import "PCPage.h"
#import "PCDefaultStyleElements.h"
#import "PCRevision.h"
#import "PCMacros.h"
#import "MBProgressHUD.h"
#import "PCData.h"
#import "PCScrollView.h"

#define PC_GALLERY_VIEW_FRAME_WIDTH 768
#define PC_GALLERY_VIEW_FRAME_HEIGHT 1024
#define kHUDTag 191

@interface PCGalleryViewController ()

- (void) afterScroll;
- (void) deviceOrientationDidChange;
- (void) hideHUDAtIndex:(NSUInteger)index;
- (void) showHUDAtIndex:(NSUInteger)index;
- (void) createImageViews;
- (void) removeImageViews;

@end

@implementation PCGalleryViewController

@synthesize mainScrollView = _mainScrollView;
@synthesize images = _images;
@synthesize pageControll = _pageControll;
@synthesize page = _page;
@synthesize delegate = _delegate;
@synthesize currentViewRect = _currentViewRect;
@synthesize progressBarsArray = _progressBarsArray;
@synthesize imageViews=_imageViews;
@synthesize horizontalOrientation = _horizontalOrientation;
@synthesize galleryID = _galleryID;

- (id) initWithPage: (PCPage *)initialPage
{
	self = [super init];
    if (self)
	{
        _pageControll = nil;
        _images = nil;
        _mainScrollView = nil;
          self.page = initialPage;
        _delegate = nil;
        _progressBarsArray = nil;
        _currentViewRect = CGRectZero;
		_currentIndex = NSIntegerMax;
        _horizontalOrientation = FALSE;
        _galleryID = -1;
	}
	
	return self;
}

- (void)dealloc
{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCGalleryElementDidDownloadNotification object:self.page];
    if (_images)
    {
        [_images release], _images = nil;
    }
	[_imageViews release], _imageViews = nil;
    [_mainScrollView release], _mainScrollView = nil;
    [_pageControll release], _pageControll = nil;
    [_page release]; _page = nil;
    [_progressBarsArray release], _progressBarsArray = nil;
    _currentViewRect = CGRectZero;
    _delegate = nil;
    
    [super dealloc];
}

- (void) viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGallery:) name:PCGalleryElementDidDownloadNotification object:self.page];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    if(_horizontalOrientation)
    {
        self.view.frame = CGRectMake(0, 0, PC_GALLERY_VIEW_FRAME_HEIGHT, PC_GALLERY_VIEW_FRAME_WIDTH);
    } else {
        self.view.frame = CGRectMake(0, 0, PC_GALLERY_VIEW_FRAME_WIDTH, PC_GALLERY_VIEW_FRAME_HEIGHT);
    }
    
    self.currentViewRect = self.view.frame;
    
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    self.images = tempArray;
    [tempArray release];
    
    self.mainScrollView = [[[PCScrollView alloc] initWithFrame:self.view.frame] autorelease];
	[self.view addSubview:self.mainScrollView];
	self.mainScrollView.pagingEnabled = YES;
	self.mainScrollView.bounces = NO;
	self.mainScrollView.alwaysBounceHorizontal = NO;
    
    UIButton* btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *buttonOption = [NSDictionary dictionaryWithObject:[NSValue valueWithCGRect:self.view.frame] forKey:PCButtonParentViewFrameKey];
    if (self.page.color)
    {
        buttonOption = [NSDictionary dictionaryWithObjectsAndKeys:self.page.color, PCButtonTintColorOptionKey, [NSValue valueWithCGRect:self.view.frame], PCButtonParentViewFrameKey,  nil];
    }
    [[PCStyler defaultStyler] stylizeElement:btnReturn withStyleName:PCGallaryReturnButtonKey withOptions:buttonOption];
    [btnReturn setFrame:CGRectMake(0, 0, btnReturn.frame.size.width, btnReturn.frame.size.height)];
	[[PCStyler defaultStyler] stylizeElement:btnReturn withStyleName:PCGallaryReturnButtonKey withOptions:buttonOption];
	[btnReturn addTarget:self action:@selector(btnReturnTap:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnReturn];
    
	self.mainScrollView.delegate = self;
    
  	self.imageViews = nil;

    NSArray *galleryElements = [self.page elementsForType:PCPageElementTypeGallery];
    
    if (self.galleryID > 0)
    {
        for (PCPageElementGallery *galleryElement in galleryElements)
        {
            if (galleryElement.galleryID == self.galleryID)
            {
                [self.images addObject:galleryElement];
            }
        }
    }
    
    else 
    {
        [self.images addObjectsFromArray:galleryElements];
    }
    
    if(_horizontalOrientation)
    {
        self.mainScrollView.contentSize = CGSizeMake(PC_GALLERY_VIEW_FRAME_HEIGHT * [self.images count], PC_GALLERY_VIEW_FRAME_WIDTH);
    } else {
        self.mainScrollView.contentSize = CGSizeMake(PC_GALLERY_VIEW_FRAME_WIDTH * [self.images count], PC_GALLERY_VIEW_FRAME_WIDTH);
    }
    
    CGRect pageControlRect;
    
    if(_horizontalOrientation)
    {
        pageControlRect = CGRectMake(0, PC_GALLERY_VIEW_FRAME_WIDTH-35, PC_GALLERY_VIEW_FRAME_HEIGHT, 30);
    } else {
        pageControlRect = CGRectMake(0, PC_GALLERY_VIEW_FRAME_HEIGHT-35, PC_GALLERY_VIEW_FRAME_WIDTH, 30);
    }
    
	self.pageControll = [[[PCCustomPageControll alloc] initWithFrame:pageControlRect] autorelease];
    NSDictionary* controllOption = nil;
    if (self.page.color)
    {
        controllOption = [NSDictionary dictionaryWithObject:self.page.color forKey:PCButtonTintColorOptionKey];
    }
    
    [[PCStyler defaultStyler] stylizeElement:self.pageControll withStyleName:PCGalleryPageControlItemKey withOptions:controllOption];
    
    self.pageControll.numberOfPages = [self.images count];
    self.pageControll.currentPage = 0;
    [self.pageControll addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.pageControll];
    [self.view bringSubviewToFront:self.pageControll];
    
    if (![self.images lastObject]) return;
    [self createImageViews];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeImageViews];
    _currentIndex = NSIntegerMax;
    self.galleryID = -1;
    NSLog(@"self.images - %@, self.imageviews - %@", self.images, self.imageViews);
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.imageViews = nil;
    [super viewDidUnload];
}

- (void)createImageViews
{	
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    self.imageViews = tempArray;
    [tempArray release];
    
    for (int i=0; i<[self.images count]; i++)
    {
		UIImageView* imageView;
        
        if(_horizontalOrientation)
        {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * PC_GALLERY_VIEW_FRAME_HEIGHT, 0, PC_GALLERY_VIEW_FRAME_HEIGHT, PC_GALLERY_VIEW_FRAME_WIDTH)];
        } else {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * PC_GALLERY_VIEW_FRAME_WIDTH, 0, PC_GALLERY_VIEW_FRAME_WIDTH, PC_GALLERY_VIEW_FRAME_HEIGHT)];
        }
		
		imageView.userInteractionEnabled = YES;
		
		PCPageElement* element = [self.images objectAtIndex:i];
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
	
	[self showPhotoAtIndex:self.pageControll.currentPage];
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
	NSLog(@"POPUP tag - %d", sender.tag);
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

/*-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *) touch {
	
	CGPoint point = [touch locationInView:touch.view.superview];
	UIView* view = [touch.view.superview hitTest:point withEvent:nil];
	if (([view isKindOfClass:[UIButton class]])) {
		return NO;
	}
	return YES;
}*/



- (void)removeImageViews
{
    for (int i=0; i<[self.imageViews count]; i++)
    {
        [[self.imageViews objectAtIndex:i] removeFromSuperview];
        [self hideHUDAtIndex:i];
    }
    self.imageViews = nil;
}

- (void)btnReturnTap:(id)sender
{
    if (self.delegate)
    {
        [self.delegate galleryViewControllerWillDismiss];
    }
    else
    {
        NSLog(@"PCGalleryViewController delegate not defined");
    }
}

- (void) deviceOrientationDidChange
{
    if(self.horizontalOrientation) return;
    
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        [self btnReturnTap:nil];
    }
}
- (void)changePage:(id)sender
{
    [self setCurrentPhoto:self.pageControll.currentPage];
	[self showPhotoAtIndex:self.pageControll.currentPage];
}

- (void)setCurrentPhoto:(int)index
{
    if(_horizontalOrientation)
    {
        self.currentViewRect = CGRectMake(index * PC_GALLERY_VIEW_FRAME_HEIGHT, 0, PC_GALLERY_VIEW_FRAME_HEIGHT, PC_GALLERY_VIEW_FRAME_WIDTH);
    } else {
        self.currentViewRect = CGRectMake(index * PC_GALLERY_VIEW_FRAME_WIDTH, 0, PC_GALLERY_VIEW_FRAME_WIDTH, PC_GALLERY_VIEW_FRAME_HEIGHT);
    }
    [self.mainScrollView scrollRectToVisible:self.currentViewRect animated:YES];
    self.pageControll.currentPage = index;
}

- (void) afterScroll
{
    self.pageControll.currentPage = lrint(self.mainScrollView.contentOffset.x/self.mainScrollView.frame.size.width);
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
	NSInteger currentIndex = lrint(self.mainScrollView.contentOffset.x/self.mainScrollView.frame.size.width);
	[self showPhotoAtIndex:currentIndex];
    [self afterScroll]; 
}

-(void)updateGallery:(NSNotification*)notif
{
	PCPageElement* galleryElement = [[notif userInfo] objectForKey:@"element"];
	NSUInteger index = [self.images indexOfObject:galleryElement];
	if (index == NSNotFound)
	{
		NSLog(@"NSNot foung result for index while updating gallery");
		return;
	}
	[self hideHUDAtIndex:index];

    NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:galleryElement.resource];
	NSInteger currentIndex = lrint(self.mainScrollView.contentOffset.x/self.mainScrollView.frame.size.width);
	if ([[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath] && !(ABS(currentIndex - index) > 1))
	{
		UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
		[[self.imageViews objectAtIndex:index] setImage:image];
	}
}

-(void)showHUDAtIndex:(NSUInteger)index
{
	PCPageElement* element = (PCPageElement*)[self.images objectAtIndex:index];
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
	((PCPageElement*)[self.images objectAtIndex:index]).progressDelegate = HUD;
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
		((PCPageElement*)[self.images objectAtIndex:index]).progressDelegate = nil;
		[HUD removeFromSuperview];
		HUD = nil;
	}
}

-(void)showImageAtIndex:(NSUInteger)index
{
	if ([[self.imageViews objectAtIndex:index] image]) return;
	PCPageElement* galleryElement = ((PCPageElement*)[self.images objectAtIndex:index]);
	NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:galleryElement.resource];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if (galleryElement.isComplete && [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath])
		{
			UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
			dispatch_async(dispatch_get_main_queue(), ^{
				[[self.imageViews objectAtIndex:index] setImage:image];
			});
			
		}
	});
	
}

-(void)hideImageAtIndex:(NSUInteger)index
{
	[[self.imageViews objectAtIndex:index] setImage:nil];
}

-(void)showPhotoAtIndex:(NSInteger)currentIndex
{
	if (currentIndex < 0 || currentIndex >= [self.images count]) return;
	PCPageElement* element = (PCPageElement*)[self.images objectAtIndex:currentIndex];
	if (!element.isComplete)
		[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:element];
	if (_currentIndex != currentIndex)
	{
		_currentIndex = currentIndex;
		if (!element.isComplete)
		{
			[self showHUDAtIndex:_currentIndex];
			for (int i =0; i < [self.images count]; ++i) {
				if (i != _currentIndex)
				{
					[self hideHUDAtIndex:i];
				}
			}
		}
		
		for (int i =0; i < [self.images count]; ++i)
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


@end
