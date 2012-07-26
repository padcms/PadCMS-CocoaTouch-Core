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
#import "PCScrollView.h"
#import "AbstractBasePageViewController.h"
#import "GalleryViewController.h"

@interface RevisionViewController ()
@property (nonatomic, retain) PCScrollView* contentScrollView;
@end

@implementation RevisionViewController
@synthesize revision = _revision;
@synthesize contentScrollView=_contentScrollView;
@synthesize currentPageViewController=_currentPageViewController;
@synthesize nextPageViewController=_nextPageViewController;
@synthesize topSummaryView;

- (id)initWithRevision:(PCRevision *)revision
{
	self = [super init];
    
    if (self) {
        _revision = [revision retain];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationDidChange)
													 name:@"UIDeviceOrientationDidChangeNotification"
												   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
	UIViewController *viewController = [[UIViewController alloc] init];
	[self presentModalViewController:viewController animated:NO];
	[self dismissModalViewControllerAnimated:NO];
	[viewController release];
    [super viewDidLoad];
	_contentScrollView = [[PCScrollView alloc] initWithFrame:self.view.bounds];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.backgroundColor = [UIColor whiteColor];
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
	_contentScrollView.directionalLockEnabled = YES;
	self.nextPageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:[self.revision coverPage]];
	[self configureContentScrollForPage:_nextPageViewController.page];
    _contentScrollView.delegate = self;
	_contentScrollView.bounces = NO;
    [self.view addSubview:_contentScrollView];
	[self initTopMenu];
}

-(void)dealloc
{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[topSummaryView release];
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
	if (self.revision.horizontalOrientation)
	{
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);

	}
	else
	{
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);

	}
}


-(void)configureContentScrollForPage:(PCPage*)page
{
	//Contentsize configuration
	//After every page changing we need to recalculate content size of the revision scroll view depending on links of current page. Content size must allow scrolling to neighbour pages, and at the same time block scroll in direction where page links are empty (nil).
	
	if (!page) return;
	CGFloat pageWidth = self.view.bounds.size.width;
	CGFloat pageHeight = self.view.bounds.size.height;
	int widthMultiplier = 1;
	if (page.leftPage) widthMultiplier++;
	if (page.rightPage) widthMultiplier++;
	int heightMultiplier = 1;
	if (page.topPage) heightMultiplier++;
	if (page.bottomPage) heightMultiplier++;
	//To prevent calling delegate methods after changing content size delegate set to nil
	_contentScrollView.delegate = nil;
	_contentScrollView.contentSize = CGSizeMake(pageWidth*widthMultiplier, pageHeight*heightMultiplier);
	_contentScrollView.delegate = self;
	
	//configure offset
	//We need to determin the position of current page after changing content size
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
			_currentPageViewController.delegate = self;
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
	//This if determin the direction of scroll (horizontal or vertical)
	if ((!_currentPageViewController.page.topPage && !_currentPageViewController.page.bottomPage) || abs(dx-scrollView.contentOffset.x)>abs(dy-scrollView.contentOffset.y))
	{
		//This code prevent any diagonal scrolling
		CGRect scrollBounds = scrollView.bounds;
		scrollBounds.origin = CGPointMake(scrollView.contentOffset.x, dy);
		_contentScrollView.bounds = scrollBounds;
		
		//here we determin the direction of horizontal scroll (right or left)
		if (scrollView.contentOffset.x > dx ) {
	//		NSLog(@"right");
			nextPage = _currentPageViewController.page.rightPage;
			nextPageViewFrame.origin = CGPointMake(dx + pageWidth, dy);
		}
		else {
	//		NSLog(@"left");
			nextPage = _currentPageViewController.page.leftPage;
			nextPageViewFrame.origin = CGPointMake(dx - pageWidth, dy);
		}
	}
	else
	{
		//This code prevent any diagonal scrolling
		CGRect scrollBounds = scrollView.bounds;
		scrollBounds.origin = CGPointMake(dx, scrollView.contentOffset.y);
		_contentScrollView.bounds = scrollBounds;
		
		//Here we determin the direction of vertical scrll (top or bottom)
		if (scrollView.contentOffset.y > dy ) {
	//		NSLog(@"bottom");
			nextPage = _currentPageViewController.page.bottomPage;
			nextPageViewFrame.origin = CGPointMake(dx, dy + pageHeight);
		}
		else {
	//		NSLog(@"top");
			nextPage = _currentPageViewController.page.topPage;
			nextPageViewFrame.origin = CGPointMake(dx, dy - pageHeight);
		}
	}
	
	
	if (!nextPage) return;
//	NSLog(@"NEXT PAGE - %d", nextPage.identifier);
	if (_nextPageViewController.page != nextPage)
	{
		
		[_nextPageViewController.view removeFromSuperview], self.nextPageViewController = nil;
		self.nextPageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:nextPage];
		self.nextPageViewController.view.frame = nextPageViewFrame;
		_nextPageViewController.delegate = self;
		[_nextPageViewController loadFullView];
		[_contentScrollView addSubview:self.nextPageViewController.view];
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	
	BOOL isVerticalOffset = scrollView.contentOffset.x == CGRectGetMinX(_nextPageViewController.view.frame);
	BOOL isHorizontalOffset = scrollView.contentOffset.y == CGRectGetMinY(_nextPageViewController.view.frame);
	
	//If page changing has occurred we need to reconfigure scroll view with new page
	if (isVerticalOffset && isHorizontalOffset)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:_nextPageViewController.page userInfo:nil];
		[self configureContentScrollForPage:_nextPageViewController.page];
	}
	
	
}

-(void)showGallery
{
	if (!_contentScrollView.dragging && !_contentScrollView.decelerating)
	{
		[self.navigationController pushViewController:[[[GalleryViewController alloc] initWithPage:_currentPageViewController.page] autorelease]  animated:NO];
	}
	 
}
-(void) deviceOrientationDidChange
{
	if (_contentScrollView.dragging || _contentScrollView.decelerating) return;
	PCPageElementBody* bodyElement = (PCPageElementBody*)[_currentPageViewController.page firstElementForType:PCPageElementTypeBody];
	
	if (bodyElement && bodyElement.showGalleryOnRotate)
	{
		if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
		{
			[self showGallery];
		}
		else {
			[self.navigationController popToViewController:self animated:NO];
		}
	}
}

-(void)gotoPage:(PCPage *)page
{
	self.nextPageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:page];
	[self configureContentScrollForPage:_nextPageViewController.page];
}

- (void)showTopBar
{
    
	
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        topMenuView.hidden = NO;
        topMenuView.alpha = 0.75f;
        [self.view bringSubviewToFront:topMenuView];
    } 
}

- (void)hideTopBar
{
    topMenuView.hidden = YES;
    topMenuView.alpha = 0;
    [self.view sendSubviewToBack:topMenuView];
    
   }


- (void)initTopMenu
{
    topMenuView.hidden = YES;
    topMenuView.alpha = 0;
    [topMenuView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 43)];
	
    int lastTocSummaryIndex = -1;
    if ([_revision.toc count] > 0)
    {
        for (int i = [_revision.toc count]-1; i >= 0; i--)
		{
			PCTocItem *tempTocItem = [_revision.toc objectAtIndex:i];
			if (tempTocItem.thumbSummary)
			{
				lastTocSummaryIndex = i;
				break;
			}
		}
        if (lastTocSummaryIndex != -1)
        {
            PCTocItem* tocItem = [_revision.toc objectAtIndex:lastTocSummaryIndex];
            NSString* imagePath = [_revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbSummary];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
		}
    }
    
    [self.view addSubview:topMenuView];
    
  }

- (void) adjustHelpButton
{
    BOOL        hide = NO;
    
    if (_revision.helpPages)
    {
		if([[_revision.helpPages objectForKey:@"horizontal"] isEqualToString:@""] && [[_revision.helpPages objectForKey:@"vertical"] isEqualToString:@""])
		{
			hide = YES;
		}
    }
}

- (void)tapAction:(UIGestureRecognizer *)sender
{
       
    if (_revision.horizontalOrientation) {
        [topMenuView setFrame:CGRectMake(0, 0, 1024, 43)];
    } else {
        [topMenuView setFrame:CGRectMake(0, 0, 768, 43)];
    }
	
    [UIView animateWithDuration:0.3f animations:^{
		
        if ([_revision.toc count] > 0)
        {
            int lastTocStripeIndex = -1;
			
            for (int i = [_revision.toc count]-1; i >= 0; i--)
            {
                PCTocItem *tempTocItem = [_revision.toc objectAtIndex:i];
                if (tempTocItem.thumbStripe)
                {
                    lastTocStripeIndex = i;
                    break;
                }
            }
			
            if (lastTocStripeIndex != -1)
            {
                PCTocItem* tocItem = [_revision.toc objectAtIndex:lastTocStripeIndex];
                NSString *imagePath = [_revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
				
                if (fileExists) {
                   
                } else {
                    
                }
               
			}
        } 
        
        else {
            
        }
        
                
        if (topMenuView.hidden) {
            [self showTopBar];
        } else {
            [self hideTopBar];
           
        }
        
        if (!topSummaryView.hidden) {
            topSummaryView.hidden = YES;
            topSummaryView.alpha = 0;
        }
        
               
    }];
}


@end