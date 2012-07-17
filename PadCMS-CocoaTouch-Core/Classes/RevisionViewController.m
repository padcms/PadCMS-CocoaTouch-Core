//
//  RevisionViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "RevisionViewController.h"
#import "PCMagazineViewControllersFactory.h"
#import "PCPageViewController.h"
#import "PCPage.h"
#import "AbstractBasePageViewController.h"

@interface RevisionViewController ()
@property (nonatomic, retain) UIScrollView* contentScrollView;
@end

@implementation RevisionViewController
@synthesize revision = _revision;
@synthesize contentScrollView=_contentScrollView;
@synthesize currentPageViewController=_currentPageViewController;
@synthesize nextPageViewController=_nextPageViewController;

- (id)initWithRevision:(PCRevision *)revision
{
	self = [super init];
    
    if (self) {
        _revision = [revision retain];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.backgroundColor = [UIColor whiteColor];
    _contentScrollView.showsVerticalScrollIndicator = YES;
    _contentScrollView.showsHorizontalScrollIndicator = YES;
	_contentScrollView.directionalLockEnabled = YES;
	self.nextPageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:[self.revision coverPage]];
	[self configureContentScrollForPage:_nextPageViewController.page];
    _contentScrollView.delegate = self;
	_contentScrollView.bounces = NO;
    [self.view addSubview:_contentScrollView];
}

-(void)dealloc
{
	[_contentScrollView release], _contentScrollView = nil;
	[super dealloc];
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
	self.contentScrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


-(void)configureContentScrollForPage:(PCPage*)page
{
	//configue contentsize
	if (!page) return;
	CGFloat pageWidth = self.view.bounds.size.width;
	CGFloat pageHeight = self.view.bounds.size.height;
	int widthMultiplier = 1;
	if (page.leftPage) widthMultiplier++;
	if (page.rightPage) widthMultiplier++;
	int heightMultiplier = 1;
	if (page.topPage) heightMultiplier++;
	if (page.bottomPage) heightMultiplier++;
	_contentScrollView.delegate = nil;
	_contentScrollView.contentSize = CGSizeMake(pageWidth*widthMultiplier, pageHeight*heightMultiplier);
	_contentScrollView.delegate = self;
	
	//configure offset
	CGFloat dx = page.leftPage?pageWidth:0;
	CGFloat dy = page.topPage?pageHeight:0;
	//_contentScrollView.contentOffset = CGPointMake(dx, dy);
	CGRect scrollBounds = _contentScrollView.bounds;
	scrollBounds.origin = CGPointMake(dx, dy);
	_contentScrollView.bounds = scrollBounds;
	
	if (self.currentPageViewController.page != page)
	{
		[_currentPageViewController.view removeFromSuperview];
		self.currentPageViewController = _nextPageViewController;
		CGRect frame = self.currentPageViewController.view.frame;
		frame.origin = CGPointMake(dx, dy);	
		self.currentPageViewController.view.frame = frame;
		if (!self.currentPageViewController.view.superview)
		{
			[_currentPageViewController loadFullView];
			[_contentScrollView addSubview:self.currentPageViewController.view];
		}
		
		self.nextPageViewController = nil;
		
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.decelerating && !scrollView.dragging) return;
	
	CGFloat pageWidth = self.view.bounds.size.width;
	CGFloat pageHeight = self.view.bounds.size.height;
	CGFloat dx = _currentPageViewController.page.leftPage ? pageWidth : 0;
	CGFloat dy = _currentPageViewController.page.topPage ? pageHeight : 0;
	CGRect nextPageViewFrame = self.currentPageViewController.view.frame;
	PCPage* nextPage = nil;
	if ((!_currentPageViewController.page.topPage && !_currentPageViewController.page.bottomPage) || abs(dx-scrollView.contentOffset.x)>abs(dy-scrollView.contentOffset.y))
	{
		CGRect scrollBounds = scrollView.bounds;
		scrollBounds.origin = CGPointMake(scrollView.contentOffset.x, dy);
		_contentScrollView.bounds = scrollBounds;
		
		if (scrollView.contentOffset.x > dx ) {
			NSLog(@"right");
			nextPage = _currentPageViewController.page.rightPage;
			nextPageViewFrame.origin = CGPointMake(dx + pageWidth, dy);
		}
		else {
			NSLog(@"left");
			nextPage = _currentPageViewController.page.leftPage;
			nextPageViewFrame.origin = CGPointMake(dx - pageWidth, dy);
		}
	}
	else
	{
		CGRect scrollBounds = scrollView.bounds;
		scrollBounds.origin = CGPointMake(dx, scrollView.contentOffset.y);
		_contentScrollView.bounds = scrollBounds;
		
		if (scrollView.contentOffset.y > dy ) {
			NSLog(@"bottom");
			nextPage = _currentPageViewController.page.bottomPage;
			nextPageViewFrame.origin = CGPointMake(dx, dy + pageHeight);
		}
		else {
			NSLog(@"top");
			nextPage = _currentPageViewController.page.topPage;
			nextPageViewFrame.origin = CGPointMake(dx, dy - pageHeight);
		}
	}
	
	
	if (!nextPage) return;
	NSLog(@"NEXT PAGE - %d", nextPage.identifier);
	if (_nextPageViewController.page != nextPage)
	{
		
		[_nextPageViewController.view removeFromSuperview], self.nextPageViewController = nil;
		self.nextPageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:nextPage];
		self.nextPageViewController.view.frame = nextPageViewFrame;
		[_nextPageViewController loadFullView];
		[_contentScrollView addSubview:self.nextPageViewController.view];
	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	BOOL isVerticalOffset = scrollView.contentOffset.x == CGRectGetMinX(_nextPageViewController.view.frame);
	BOOL isHorizontalOffset = scrollView.contentOffset.y == CGRectGetMinY(_nextPageViewController.view.frame);
	
	if (isVerticalOffset && isHorizontalOffset)
	{
		[self configureContentScrollForPage:_nextPageViewController.page];
	}
	
	
}

@end