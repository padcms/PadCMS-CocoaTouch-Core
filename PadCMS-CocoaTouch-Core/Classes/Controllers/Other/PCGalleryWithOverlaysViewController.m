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
- (void)galleryElementTapped:(UIGestureRecognizer *)gestureRecognizer;
@end

@implementation PCGalleryWithOverlaysViewController
@synthesize page = _page;
@synthesize mainScrollView = _mainScrollView;
@synthesize galleryID = _galleryID;
@synthesize horizontalOrientation = _horizontalOrientation;
@synthesize galleryElements = _galleryElements;
@synthesize galleryImageViews = _galleryImageViews;
@synthesize currentPage;
@synthesize zoomableViews = _zoomableViews;
@synthesize galleryPopupImageViews = _galleryPopupImageViews;
@synthesize popupsIndexes = _popupsIndexes;
@synthesize popupsGalleryElementLinks = _popupsGalleryElementLinks;
@synthesize popupsZones = _popupsZones;

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
    [_galleryImageViews release], _galleryImageViews = nil;
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
    self.galleryImageViews = nil;
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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
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
		[[self.galleryImageViews objectAtIndex:index] setImage:image];
	}
}

- (void)createImageViews
{	
    self.galleryImageViews = [[[NSMutableArray alloc] init] autorelease];
    self.zoomableViews = [[[NSMutableArray alloc] init] autorelease];
    self.galleryPopupImageViews = [[[NSMutableArray alloc] init] autorelease];
    self.popupsIndexes = [[[NSMutableArray alloc] init] autorelease];
    self.popupsGalleryElementLinks = [[[NSMutableArray alloc] init] autorelease];
    self.popupsZones = [[[NSMutableArray alloc] init] autorelease];
    
    CGRect              elementRect, rotatedRect;
    CGFloat             tmp;
    
    if(_horizontalOrientation)
    {
        elementRect = CGRectMake(0, 0, 768, 1024);
    } else {
        elementRect = CGRectMake(0, 0, 1024, 768);
    }

    self.view.frame = elementRect;
    rotatedRect = elementRect;
    tmp = rotatedRect.size.width;
    rotatedRect.size.width = rotatedRect.size.height;
    rotatedRect.size.height = tmp;
    
    for (int i=0; i<[self.galleryElements count]; i++)
    {
        PCPageElementGallery    *pageElement = [self.galleryElements objectAtIndex:i];
        
        
        UIView          *galleryElementView = [[UIView alloc] initWithFrame:CGRectMake(0, elementRect.size.height * i, elementRect.size.width, elementRect.size.height)];
        UIImageView     *galleryElementImageView = [[UIImageView alloc] initWithFrame:elementRect];

        if(pageElement.zoomable)   // zoom support [UIView]-[UIScrollView]-[UIView](zoomable)-[UIView](rotated)-[UIImageView](gallery element)
        {                          //                  '----[UIImageView](popup)(rotated) ...
            UIScrollView    *innerScrollView = [[UIScrollView alloc] initWithFrame:elementRect];
            [galleryElementView addSubview:innerScrollView];
            [innerScrollView release];
            
            UIView          *zoomView = [[UIView alloc] initWithFrame:elementRect];
            [innerScrollView addSubview:zoomView];
            [zoomView release];
            
            UIView          *rotateView = [[UIView alloc] initWithFrame:elementRect];
            [zoomView addSubview:rotateView];
            [rotateView release];
            
            [rotateView addSubview:galleryElementImageView];
            [galleryElementImageView release];
            
            rotateView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            rotateView.frame = elementRect;
            galleryElementImageView.frame = rotatedRect;
            
            innerScrollView.tag = 1000 + i;
            [self.zoomableViews addObject:zoomView];
            
            innerScrollView.delegate = self;
            innerScrollView.bouncesZoom = NO;
            innerScrollView.maximumZoomScale = 2.0;
            innerScrollView.zoomScale = 1;
        } else {                   // no zoom      [UIView]-[UIImageView](gallery element)(rotated)
                                   //                  '----[UIImageView](popup)(rotated) ...
            [galleryElementView addSubview:galleryElementImageView];
            [galleryElementImageView release];
            galleryElementImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            galleryElementImageView.frame = elementRect;
            [self.zoomableViews addObject:[NSNull null]];
        }
        
        // Popups
        NSArray* popups = [[pageElement.dataRects allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@",PCPDFActiveZonePopup]];
        if([popups count]>0)
        {
            UIImageView     *popupImageView = [[UIImageView alloc] initWithFrame:elementRect];
            popupImageView.hidden = YES;
            [galleryElementView addSubview:popupImageView];
            [self.galleryPopupImageViews addObject:popupImageView];
            [popupImageView release];
            popupImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            popupImageView.frame = elementRect;

            for (NSString* type in popups)
            {
                NSInteger       popupIndex = [[type lastPathComponent] intValue] - 1;
                
//                NSLog(@"Gallery item %d - POPUP - %@", i, type);

                CGRect      rect = [pageElement rectForElementType:type];
                
                if (!CGRectEqualToRect(rect, CGRectZero))
                {
                    CGSize pageSize = rotatedRect.size;
                    float scale = pageSize.width/pageElement.size.width;
                    rect.size.width *= scale;
                    rect.size.height *= scale;
                    rect.origin.x *= scale;
                    rect.origin.y *= scale;
                    CGFloat     newX = pageElement.size.height*scale - rect.origin.y - rect.size.height;
                    CGFloat     newY = pageElement.size.width*scale - rect.origin.x - rect.size.width;
                    rect.origin.x = newX;
                    rect.origin.y = newY;
                    
                    tmp = rect.size.width;
                    rect.size.width = rect.size.height;
                    rect.size.height = tmp;
                } else {
                    rect = elementRect;
                }
                [self.popupsZones addObject:[NSValue valueWithCGRect:rect]];
                [self.popupsGalleryElementLinks addObject:[NSNumber numberWithInteger:i]];
                [self.popupsIndexes addObject:[NSNumber numberWithInteger:popupIndex]];
            }
        } else {
            [self.galleryPopupImageViews addObject:[NSNull null]];
        }
        
        [self.galleryImageViews addObject:galleryElementImageView];
        [self.mainScrollView addSubview:galleryElementView];
        [galleryElementView release];
        
        galleryElementView.tag = 1000 + i;
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(galleryElementTapped:)];
        tapGestureRecognizer.cancelsTouchesInView = NO;
        [galleryElementView  addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
    }

	[self showPhotoAtIndex:self.currentPage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    NSInteger       index = aScrollView.tag - 1000;
    
    if(index>=0 && index<[self.galleryElements count])
    {
        if ([self.zoomableViews objectAtIndex:index]!=[NSNull null])
        {
            return [self.zoomableViews objectAtIndex:index];
        }
    }
    return nil;
}

- (void)galleryElementTapped:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger       galleryElementIndex = gestureRecognizer.view.tag - 1000;
    
    if(galleryElementIndex>=0 && galleryElementIndex<[self.galleryElements count])
    {
        
        // check if this gallery element has any popups
        if([self.galleryPopupImageViews objectAtIndex:galleryElementIndex]!=[NSNull null])
        {
            UIImageView     *popupImageView = [self.galleryPopupImageViews objectAtIndex:galleryElementIndex];
            
            if(popupImageView.image)            // tapped when any of popup's is showed, hide this popup and clear
            {
                popupImageView.image = nil;
                popupImageView.hidden = YES;
            } else {                            // no popups is showed
                // check if tap falls in any of zone
                CGPoint         tapLocation = [gestureRecognizer locationInView:self.view];

                for (int i=0; i<[self.popupsGalleryElementLinks count]; i++)
                {
                    NSNumber        *popupGalleryIndex = [self.popupsGalleryElementLinks objectAtIndex:i];
                    
                    if([popupGalleryIndex integerValue]==galleryElementIndex) // popup associated with current page
                    {
                        NSValue         *zone = [self.popupsZones objectAtIndex:i];
                        CGRect           popupZone = [zone CGRectValue];
                        
//                        NSLog(@"TAP %.0f, %0.f, zone rect = %.0f, %0.f, %.0fx%0.f, result=%d", tapLocation.x, tapLocation.y, popupZone.origin.x, popupZone.origin.y, popupZone.size.width, popupZone.size.height, CGRectContainsPoint(popupZone, tapLocation));

                        if(CGRectContainsPoint(popupZone, tapLocation)) // popup finded, show them
                        {
                            NSNumber        *popupIndex = [self.popupsIndexes objectAtIndex:i];
                            
                            NSArray* popupsElements = [self.page elementsForType:PCPageElementTypePopup];
                            PCPageElement*popupElement = [popupsElements objectAtIndex:[popupIndex integerValue]];
                            if (!popupElement.isComplete)
                                [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:popupElement];
                            NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:popupElement.resource];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                if (popupElement.isComplete && [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath])
                                {
                                    UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [popupImageView setImage:image];
                                        popupImageView.hidden = NO;
                                    });
                                    
                                }
                            });
                            break;
                        }
                    }
                }
            }
        }
    }
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
	if ([[self.galleryImageViews objectAtIndex:index] image]) return;
	PCPageElement* galleryElement = ((PCPageElement*)[self.galleryElements objectAtIndex:index]);
	NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:galleryElement.resource];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if (galleryElement.isComplete && [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath])
		{
			UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
			dispatch_async(dispatch_get_main_queue(), ^{
				[[self.galleryImageViews objectAtIndex:index] setImage:image];
                NSLog(@"GO element with id=%d res=%@", galleryElement.identifier, galleryElement.resource);
			});
			
		}
	});
}

- (void)removeImageViews
{
    for (int i=0; i<[self.galleryImageViews count]; i++)
    {
        [[self.galleryImageViews objectAtIndex:i] removeFromSuperview];
        [self hideHUDAtIndex:i];
    }
    self.galleryImageViews = nil;
}

-(void)hideImageAtIndex:(NSUInteger)index
{
	[[self.galleryImageViews objectAtIndex:index] setImage:nil];
    
    // clear popups
    UIImageView     *popupImageView = [self.galleryPopupImageViews objectAtIndex:index];
    popupImageView.image = nil;
}

-(void)showHUDAtIndex:(NSUInteger)index
{
	PCPageElement* element = (PCPageElement*)[self.galleryElements objectAtIndex:index];
	if (element.isComplete) return;
	UIImageView* currentImageView = ((UIImageView*)[self.galleryImageViews objectAtIndex:index]);
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
	UIImageView* currentImageView = ((UIImageView*)[self.galleryImageViews objectAtIndex:index]);
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
    if(scrollView!=self.mainScrollView)return;
	scrollView.userInteractionEnabled = NO;
    [self afterScroll]; 
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView!=self.mainScrollView)return;
	scrollView.userInteractionEnabled = YES;
	NSInteger currentIndex = lrint(self.mainScrollView.contentOffset.y/self.mainScrollView.frame.size.height);
	[self showPhotoAtIndex:currentIndex];
    [self afterScroll]; 
}

@end
