//
//  SlideshowViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/24/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "SlideshowViewController.h"
#import "PCPageElement.h"
#import "PCScrollView.h"
#import "PCCustomPageControll.h"
#import "PCStyler.h"

@interface SlideshowViewController ()
@property (nonatomic, retain) NSMutableSet* visibleElementControllers;
@end

@implementation SlideshowViewController
@synthesize slideScrollView=_slideScrollView;
@synthesize slideElements=_slideElements;
@synthesize visibleElementControllers=_visibleElementControllers;
@synthesize pageControll=_pageControll;

-(void)dealloc
{
	[_visibleElementControllers release], _visibleElementControllers = nil;
	[_slideElements release], _slideElements = nil;
	[_slideScrollView release], _slideScrollView = nil;
	[_pageControll release], _pageControll = nil;
	[super dealloc];
}

-(void)releaseViews
{
	[super releaseViews];
	self.visibleElementControllers = nil;
	self.slideScrollView = nil;
	self.slideElements = nil;
	self.pageControll = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) [self showHUD];
	if (!_page.isComplete) return;
	[self loadBackground];
	self.slideElements = [_page elementsForType:PCPageElementTypeSlide];
	for (int i = 0; i < [_slideElements count]; ++i) {
		[[_slideElements objectAtIndex:i] setWeight:i];
	}
	
	if ([_slideElements count] > 0)
	{
		self.visibleElementControllers = [NSMutableSet set];
		[_slideScrollView removeFromSuperview];
		[_slideScrollView release];
		_slideScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		_slideScrollView.pagingEnabled = YES;
		_slideScrollView.backgroundColor = [UIColor whiteColor];
		_slideScrollView.showsVerticalScrollIndicator = NO;
		_slideScrollView.showsHorizontalScrollIndicator = NO;
		_slideScrollView.directionalLockEnabled = YES;
//		_slideScrollView.clipsToBounds = YES;
		_slideScrollView.delegate = self;
		_slideScrollView.bounces = NO;
		_slideScrollView.backgroundColor = [UIColor clearColor];
		
		CGRect frame = [self activeZoneRectForType:PCPDFActiveZoneScroller];
		[_slideScrollView setFrame:frame];
		_slideScrollView.contentSize = CGSizeMake(frame.size.width * [self.slideElements count], frame.size.height); 
	//	_slideScrollView.backgroundColor = [UIColor yellowColor];
		[self.view addSubview:_slideScrollView];
		[self tilePages];
		
		
		
		CGRect pageControllRect = CGRectMake(frame.origin.x, frame.origin.y+frame.size.height-30, frame.size.width, 30);
		self.pageControll = [[[PCCustomPageControll alloc] initWithFrame:pageControllRect] autorelease];
		
		NSDictionary* controllOption = nil;
		if (self.page.color)
			controllOption = [NSDictionary dictionaryWithObject:self.page.color forKey:PCButtonTintColorOptionKey];
		
		[[PCStyler defaultStyler] stylizeElement:self.pageControll withStyleName:PCSliderPageControlItemKey withOptions:controllOption];
		
		self.pageControll.numberOfPages = [_slideElements count];
		self.pageControll.currentPage = 0;
		[self.pageControll addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
		[self.view addSubview:self.pageControll];
		[self.view bringSubviewToFront:self.pageControll];
		
	}
}

- (void)tilePages 
{
    // Calculate which pages are visible
    CGRect visibleBounds = _slideScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self.slideElements count] - 1);
    NSLog(@"FIRST - %d, LAST - %d", firstNeededPageIndex, lastNeededPageIndex);
    //removing not visible images
	NSMutableSet* pagesToRemove = [[NSMutableSet alloc] init];
	for (PageElementViewController *controller in _visibleElementControllers) {
        if (controller.element.weight < firstNeededPageIndex || controller.element.weight > lastNeededPageIndex) {
            [pagesToRemove addObject:controller];
            [controller.elementView removeFromSuperview];
        }
    }
    [_visibleElementControllers minusSet:pagesToRemove];
	[pagesToRemove release];
	
    // add missing images
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingImageForIndex:index]) {
			PCPageElement* galleryElement = [self.slideElements objectAtIndex:index];
			PageElementViewController* elementController = [[PageElementViewController alloc] initWithElement:galleryElement andFrame:CGRectMake(_slideScrollView.bounds.size.width * index, 0.0, _slideScrollView.bounds.size.width, _slideScrollView.bounds.size.height)];
			elementController.elementView.scrollView.bounds = _slideScrollView.frame;
			elementController.elementView.userInteractionEnabled = NO;
			[_slideScrollView addSubview:elementController.elementView];
            [_visibleElementControllers addObject:elementController];
			[elementController release];
        }
    }    
}

- (BOOL)isDisplayingImageForIndex:(NSUInteger)index
{
    BOOL foundImage = NO;
    for (PageElementViewController *controller in _visibleElementControllers) {
        if (controller.element.weight == index) {
            foundImage = YES;
            break;
        }
    }
    return foundImage;
}

-(void)changePage:(id)sender
{
   
	CGRect slidersViewRect = self.slideScrollView.frame;
    CGRect slideRect = CGRectMake(slidersViewRect.size.width*self.pageControll.currentPage, 0, slidersViewRect.size.width, slidersViewRect.size.height);
    [self.slideScrollView scrollRectToVisible:slideRect animated:YES];
	

}

#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tilePages];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	self.pageControll.currentPage = lrint(self.slideScrollView.contentOffset.x/self.slideScrollView.frame.size.width);
}


@end
