//
//  RevisionViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "RevisionViewController.h"

#import "AbstractBasePageViewController.h"
#import "EasyTableView.h"
#import "GalleryViewController.h"
#import "ImageCache.h"
#import "InAppPurchases.h"
#import "PCFacebookViewController.h"
#import "PCGridView.h"
#import "PCLocalizationManager.h"
#import "PCMagazineViewControllersFactory.h"
#import "PCPage.h"
#import "PCPageViewController.h"
#import "PCResourceCache.h"
#import "PCScrollView.h"
#import "PCSubscriptionMenuViewController.h"
#import "PCSummaryView.h"
#import "PCTocView.h"
#import "PCVideoManager.h"

@interface RevisionViewController ()
{
    BOOL _previewMode;
    NSUInteger _horizontalPageIndex;
    PCHudView *_hudView;
    PCShareView *_shareView;
    PCFacebookViewController *_facebookViewController;
    PCTwitterNewController *_twitterController;
    PCEmailController *_emailController;
	UIInterfaceOrientation _currentInterfaceOrientation;
    PCSubscriptionMenuViewController *_subscriptionsMenuController;
    UIPopoverController *_popoverController;
}

@property (nonatomic, retain) PCScrollView* contentScrollView;
@property (nonatomic, readonly) PCPage* initialPage;

- (void)tapGesture:(UIGestureRecognizer *)recognizer;
- (void)verticalTocDownloaded:(NSNotification *)notification;
- (void)horizontalTocDownloaded:(NSNotification *)notification;
- (void)dismiss;

@end

@implementation RevisionViewController
@synthesize delegate;
@synthesize revision = _revision;
@synthesize contentScrollView=_contentScrollView;
@synthesize currentPageViewController=_currentPageViewController;
@synthesize nextPageViewController=_nextPageViewController;
@synthesize initialPage = _initialPage;
@synthesize topSummaryView;

- (id)initWithRevision:(PCRevision *)revision
       withInitialPage:(PCPage*)initialPage
           previewMode:(BOOL)previewMode
{
	self = [super init];
    
    if (self) {
        _revision = [revision retain];
        _horizontalPageIndex = 0;
        _previewMode = previewMode;

        if (initialPage == nil) {
            if (_revision.alternativeCoverPage && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                _initialPage = [_revision.alternativeCoverPage retain];
            } else {
                _initialPage = [_revision.coverPage retain];
            }
        } else {
            _initialPage = [initialPage retain];
        }
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        _shareView = nil;
        _facebookViewController = nil;
        _twitterController = nil;
        _emailController = nil;
		_currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        _subscriptionsMenuController = nil;
        _popoverController = nil;
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
	_contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.nextPageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:_initialPage];
	[self configureContentScrollForPage:_nextPageViewController.page];
    _contentScrollView.delegate = self;
	_contentScrollView.bounces = NO;
    [self.view addSubview:_contentScrollView];
	[self initTopMenu];
    

    UITapGestureRecognizer *tapGestureRecognizer = [[[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(tapGesture:)] autorelease];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];

    _hudView = [[PCHudView alloc] initWithFrame:self.view.bounds];
    _hudView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _hudView.dataSource = self;
    _hudView.delegate = self;
    _hudView.topBarView.delegate = self;
    [_hudView reloadData];
    [self.view addSubview:_hudView];
    
    if (_hudView.topTocView != nil) {
        if (_previewMode) {
            [_hudView.topTocView transitToState:PCTocViewStateHidden animated:NO];
        } else {
            [_hudView.topTocView transitToState:PCTocViewStateVisible animated:YES];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(verticalTocDownloaded:)
                                                 name:endOfDownloadingTocNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(horizontalTocDownloaded:)
                                                 name:PCHorizontalTocDidDownloadNotification
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:endOfDownloadingTocNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCHorizontalTocDidDownloadNotification
                                                  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[topSummaryView release];
	[_contentScrollView release], _contentScrollView = nil;
	[_initialPage release], _initialPage = nil;
	[super dealloc];
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
	self.contentScrollView = nil;
    
    if (_shareView != nil) {
        [_shareView release];
        _shareView = nil;
    }
    
    if (_facebookViewController != nil) {
        [_facebookViewController release];
        _facebookViewController = nil;
    }
    
    if (_twitterController != nil) {
        [_twitterController release];
        _twitterController = nil;
    }
    
    if (_emailController != nil) {
        [_emailController release];
        _emailController = nil;
    }
    
    if (_subscriptionsMenuController != nil) {
        [_subscriptionsMenuController release];
        _subscriptionsMenuController = nil;
    }
    
    if (_popoverController != nil) {
        [_popoverController release];
        _popoverController = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (self.revision.horizontalOrientation)
	{
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);

	}
	else
	{
		if (self.revision.horizontalMode)
		{
			return YES;
		}
		else
		{
			return UIInterfaceOrientationIsPortrait(interfaceOrientation);
		}
		

	}
}


-(void)configureContentScrollForPage:(PCPage*)page
{
	//Contentsize configuration
	//After every page changing we need to recalculate content size of the revision scroll view depending on links of current page. Content size must allow scrolling to neighbour pages, and at the same time block scroll in direction where page links are empty (nil).
	
	if (!page) return;
	if (page.isComplete) [[ImageCache sharedImageCache] loadPrimaryImagesForPage:page]; 
	CGFloat pageWidth = self.view.bounds.size.width;
	CGFloat pageHeight = self.view.bounds.size.height;
	int widthMultiplier = 1;
	if (page.leftPage) widthMultiplier++;
	if (page.rightPage) {
        if (!_previewMode) {
            widthMultiplier++;
        } else {
            if (_horizontalPageIndex < _revision.issue.application.previewColumnsNumber) {
                widthMultiplier++;
            } else {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:_revision.title
                                                                     message:[PCLocalizationManager localizedStringForKey:@"ALERT_MESSAGE_BUY_FULL_VERSION" value:@"Do you want to buy full version?"]
                                                                    delegate:self
                                                           cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_NO" value:@"No"]
                                                           otherButtonTitles:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_YES" value:@"Yes"], nil]
                                          autorelease];
                [alertView show];
            }
        }
    }
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
		frame.size = CGSizeMake(pageWidth, pageHeight);
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
			nextPage = _currentPageViewController.page.rightPage;
			nextPageViewFrame.origin = CGPointMake(dx + pageWidth, dy);
		}
		else {
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
			nextPage = _currentPageViewController.page.bottomPage;
			nextPageViewFrame.origin = CGPointMake(dx, dy + pageHeight);
		}
		else {
			nextPage = _currentPageViewController.page.topPage;
			nextPageViewFrame.origin = CGPointMake(dx, dy - pageHeight);
		}
	}
	
	
	if (!nextPage) return;
//	if (nextPage.isComplete) [[ImageCache sharedImageCache] loadPrimaryImagesForPage:nextPage]; 
//	NSLog(@"NEXT PAGE - %d", nextPage.identifier);
	if (_nextPageViewController.page != nextPage)
	{
        if (nextPage == _currentPageViewController.page.rightPage) {
            ++_horizontalPageIndex;
        } else if (nextPage == _currentPageViewController.page.leftPage) {
            --_horizontalPageIndex;
        }
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
//	if (_nextPageViewController.page.isComplete) [[ImageCache sharedImageCache] loadPrimaryImagesForPage:_nextPageViewController.page]; 
	BOOL isVerticalOffset = scrollView.contentOffset.x == CGRectGetMinX(_nextPageViewController.view.frame);
	BOOL isHorizontalOffset = scrollView.contentOffset.y == CGRectGetMinY(_nextPageViewController.view.frame);
	
	//If page changing has occurred we need to reconfigure scroll view with new page
	if (isVerticalOffset && isHorizontalOffset)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:_nextPageViewController.page userInfo:nil];
		[self configureContentScrollForPage:_nextPageViewController.page];
        //[self dismissVideo];
	}
}

-(void) deviceOrientationDidChange:(NSNotification*)notif
{
        
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (!UIDeviceOrientationIsValidInterfaceOrientation(orientation)) return;
	
	if (_currentInterfaceOrientation == (UIInterfaceOrientation)orientation) return;
	_currentInterfaceOrientation = (UIInterfaceOrientation)orientation;
	
	
	[_hudView reloadData];
	
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        if (_revision.verticalTocLoaded && _revision.horizontalTocLoaded) {
            [_hudView.topBarView setSummaryButtonHidden:NO animated:YES];
        } else {
            [_hudView.topBarView setSummaryButtonHidden:YES animated:YES];
        }
    } else {
        [_hudView.topBarView setSummaryButtonHidden:YES animated:YES];
        [_hudView hideSummaryAnimated:YES];
    }

		
	if (_currentPageViewController.page.onRotatePage) {
		[self gotoPage:_currentPageViewController.page.onRotatePage];
		return;
	}
	
	if (_contentScrollView.dragging || _contentScrollView.decelerating) return;
	PCPageElementBody* bodyElement = (PCPageElementBody*)[_currentPageViewController.page firstElementForType:PCPageElementTypeBody];
	
	if (bodyElement && bodyElement.showGalleryOnRotate)
	{
		if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
		{
			[self showGallery];
		}
		else {
			[self.navigationController popToViewController:self animated:NO];
		}
	}
}

/*-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self deviceOrientationDidChange];
}*/

/*- (void)dismissVideo
{
    if (_videoManager)
    {
        [_videoManager dismissVideo];
        [_videoManager release], _videoManager = nil;
    }
}*/

#pragma mark PCActionDelegate methods

-(void)showGallery
{
	if (!_contentScrollView.dragging && !_contentScrollView.decelerating)
	{
		[self.navigationController pushViewController:[[[GalleryViewController alloc] initWithPage:_currentPageViewController.page] autorelease]  animated:NO];
	}
	 
}

-(void)gotoPage:(PCPage *)page
{
	self.nextPageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:page];
	if (!_nextPageViewController.page.isComplete)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:_nextPageViewController.page userInfo:nil];
	}
	[self configureContentScrollForPage:_nextPageViewController.page];
	
    //[self dismissVideo];
}

- (void)showVideo:(UIView *)videoView
{
    [self.view addSubview:videoView];
    [self.view bringSubviewToFront:videoView];
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

- (void)tapGesture:(UIGestureRecognizer *)recognizer
{
    if (_hudView.topTocView != nil) {
        PCTocView *topTocView = _hudView.topTocView;
        
        if (topTocView.state == PCTocViewStateActive) {
            [topTocView transitToState:PCTocViewStateVisible animated:YES];
        }
    }
    
    if (_hudView.bottomTocView != nil) {
        PCTocView *bottomTocView = _hudView.bottomTocView;
        
        if (bottomTocView.state == PCTocViewStateActive) {
            [bottomTocView transitToState:PCTocViewStateVisible animated:YES];
        } else if (bottomTocView.state == PCTocViewStateHidden) {
            [bottomTocView transitToState:PCTocViewStateVisible animated:YES];
        } else if (bottomTocView.state == PCTocViewStateVisible) {
            [bottomTocView transitToState:PCTocViewStateHidden animated:YES];
        }
    }
    
    if (_shareView != nil) {
        [_shareView dismiss];
    }
}

- (void)verticalTocDownloaded:(NSNotification *)notification
{
    [_hudView reloadData];
}

- (void)horizontalTocDownloaded:(NSNotification *)notification
{
    [_hudView reloadData];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:UIButton.class] ||
        touch.view.tag == CELL_CONTENT_TAG) {
        return NO;
    }
    
    return YES;
}

#pragma mark - PCHudViewDataSource

- (CGSize)hudView:(PCHudView *)hudView itemSizeInToc:(PCGridView *)tocView
{
    if (tocView == hudView.topTocView.gridView) {
        return CGSizeMake(150, self.view.bounds.size.height / 2);
    } else if (tocView == hudView.bottomTocView.gridView) {
        if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            return CGSizeMake(150, 340 /*viewSize.height / 3*/);
        } else {
            return CGSizeMake(250, 192 /*viewSize.height / 4*/);
        }
    } else if (tocView == hudView.summaryView.gridView) {
        return CGSizeMake(314, 100);
    }
    
    return CGSizeZero;
}

- (UIImage *)hudView:(PCHudView *)hudView summaryImageForIndex:(NSUInteger)index
{
    NSArray *tocItems = _revision.validVerticalTocItems;
    
    if (tocItems != nil && tocItems.count > index) {
        PCTocItem *tocItem = [tocItems objectAtIndex:index];
        
        PCResourceCache *cache = [PCResourceCache defaultResourceCache];
        NSString *imagePath = [_revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbSummary];
        UIImage *image = [cache objectForKey:imagePath];
        if (image == nil) {
            image = [UIImage imageWithContentsOfFile:imagePath];
            [cache setObject:image forKey:imagePath];
        }
        
        return image;
    }
    
    return nil;
}

- (NSString *)hudView:(PCHudView *)hudView summaryTextForIndex:(NSUInteger)index
{
    NSArray *tocItems = _revision.validVerticalTocItems;
    
    if (tocItems != nil && tocItems.count > index) {
        PCTocItem *tocItem = [tocItems objectAtIndex:index];
        return tocItem.title;
    }
    
    return nil;
}


- (UIImage *)hudView:(PCHudView *)hudView tocImageForIndex:(NSUInteger)index
{
    PCTocItem *tocItem = nil;
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation) &&
        [_revision supportsInterfaceOrientation:currentOrientation] &&
        _revision.horizontalMode) {
        tocItem = [_revision.validHorizontalTocItems objectAtIndex:index];
    } else {
        tocItem = [_revision.validVerticalTocItems objectAtIndex:index];
    }
    
    PCResourceCache *cache = [PCResourceCache defaultResourceCache];
    
    NSString *imagePath = [_revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
    
    UIImage *image = [cache objectForKey:imagePath];
    
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        [cache setObject:image forKey:imagePath];
    }
    
    return image;
}

- (NSUInteger)hudViewTocItemsCount:(PCHudView *)hudView
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation) &&
        [_revision supportsInterfaceOrientation:currentOrientation] &&
        _revision.horizontalMode) {
        if (_revision.horizontalTocLoaded) {
            return _revision.validHorizontalTocItems.count;
        }
    } else {
        if (_revision.verticalTocLoaded) {
            return _revision.validVerticalTocItems.count;
        }
    }
    
    return 0;
}

#pragma mark - PCHudViewDelegate

- (void)hudView:(PCHudView *)hudView didSelectIndex:(NSUInteger)index
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation) &&
        [_revision supportsInterfaceOrientation:currentOrientation] &&
        _revision.horizontalMode) {
        PCTocItem *tocItem = [_revision.validHorizontalTocItems objectAtIndex:index];
        NSArray *revisionPages = _revision.pages;
        for (PCPage *page in revisionPages) {
            if (page.identifier == tocItem.firstPageIdentifier) {
                [self gotoPage:page];
                break;
            }
        }
    } else {
        PCTocItem *tocItem = [_revision.validVerticalTocItems objectAtIndex:index];
        NSArray *revisionPages = _revision.pages;
        for (PCPage *page in revisionPages) {
            if (page.identifier == tocItem.firstPageIdentifier) {
                [self gotoPage:page];
                break;
            }
        }
    }
}

- (void)hudView:(PCHudView *)hudView willTransitToc:(PCTocView *)tocView toState:(PCTocViewState)state
{
    if (tocView == hudView.topTocView) {
        [hudView.topBarView hideKeyboard];
    }
    
    if (tocView == hudView.bottomTocView && state == PCTocViewStateHidden) {
        [_hudView hideSummaryAnimated:YES];
    }
}

- (void)hudView:(PCHudView *)hudView didTransitToc:(PCTocView *)tocView toState:(PCTocViewState)state
{
}

#pragma makr - PCTopBarViewDelegate

- (void)topBarView:(PCTopBarView *)topBarView backButtonTapped:(UIButton *)button
{
    [self dismiss];
}

- (void)topBarView:(PCTopBarView *)topBarView summaryButtonTapped:(UIButton *)button
{
    if (_hudView.summaryView.hidden) {
        [_hudView showSummaryInView:self.view atPoint:button.center animated:YES];
    } else {
        [_hudView hideSummaryAnimated:YES];
    }
}

- (void)topBarView:(PCTopBarView *)topBarView subscriptionsButtonTapped:(UIButton *)button
{
    if (!_subscriptionsMenuController)
        _subscriptionsMenuController = [[PCSubscriptionMenuViewController alloc] initWithSubscriptionFlag:[self.revision.issue.application hasIssuesProductID]];
    if (!_popoverController)
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:_subscriptionsMenuController];   
    [_popoverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)topBarView:(PCTopBarView *)topBarView shareButtonTapped:(UIButton *)button
{
    if (_shareView == nil) {
        _shareView = [[PCShareView configuredShareView] retain];
        _shareView.delegate = self;
    }
    
    if (_shareView.presented) {
        [_shareView dismiss];
    } else {
        [_shareView presentInView:self.view atPoint:button.center];
    }
}

- (void)topBarView:(PCTopBarView *)topBarView helpButtonTapped:(UIButton *)button
{
}

- (void)topBarView:(PCTopBarView *)topBarView searchText:(NSString *)searchText
{
	NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
	PCSearchViewController* searchViewController = [[PCSearchViewController alloc] initWithNibName:@"PCSearchViewController" bundle:bundle];
	searchViewController.searchKeyphrase = searchText;
	searchViewController.revision = _revision;
	searchViewController.delegate = self;
	[self.navigationController pushViewController:searchViewController animated:NO];
	
	[searchViewController release];

}

#pragma mark - delegate methods
- (void)dismiss
{
    if ([self.delegate respondsToSelector:@selector(revisionViewControllerDidDismiss:)]) {
        [self.delegate revisionViewControllerDidDismiss:self];
        [[PCVideoManager sharedVideoManager] setIsStartVideoShown:NO];
    }
}

#pragma mark - PCSearchViewControllerDelegate

- (void) showRevisionWithIdentifier:(NSInteger) revisionIdentifier andPageIndex:(NSInteger) pageIndex
{
	[self dismissPCSearchViewController:nil];
	NSAssert(pageIndex >= 0 && pageIndex < [_revision.pages count], @"pageIndex not within range");
	[self gotoPage:[_revision.pages objectAtIndex:pageIndex]];
	
}

-(void)dismissPCSearchViewController:(PCSearchViewController *)currentPCSearchViewController
{
	[self.navigationController popViewControllerAnimated:NO];
	
	UIViewController *viewController = [[UIViewController alloc] init];
	[self presentModalViewController:viewController animated:NO];
	[self dismissModalViewControllerAnimated:NO];
	[viewController release];
}

#pragma mark - PCShareViewDelegate

- (void)shareViewFacebookShare:(PCShareView *)shareView
{
    if (_facebookViewController == nil) {
        NSString *facebookMessage = [[_revision.issue.application.notifications objectForKey:PCFacebookNotificationType]objectForKey:PCApplicationNotificationMessageKey];
        _facebookViewController = [[PCFacebookViewController alloc] initWithMessage:facebookMessage];
    }
    
    [_facebookViewController initFacebookSharer];
}

- (void)shareViewTwitterShare:(PCShareView *)shareView
{
    if (_twitterController == nil) {
        NSString *twitterMessage = [[self.revision.issue.application.notifications objectForKey:PCTwitterNotificationType]objectForKey:PCApplicationNotificationMessageKey];
        _twitterController = [[PCTwitterNewController alloc] initWithMessage:twitterMessage];
        _twitterController.delegate = self;
    }
    
    [_twitterController showTwitterController];
}

- (void)shareViewEmailShare:(PCShareView *)shareView
{
    if (_emailController == nil) {
        NSDictionary *emailMessage = [self.revision.issue.application.notifications objectForKey:PCEmailNotificationType];
        _emailController = [[PCEmailController alloc] initWithMessage:emailMessage];
        _emailController.delegate = self;
    }
    
    [_emailController emailShow];
}

#pragma mark - PCTwitterNewControllerDelegate

- (void)dismissPCNewTwitterController:(TWTweetComposeViewController *)currentPCTwitterNewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPCNewTwitterController:(TWTweetComposeViewController *)tweetController
{
    [self presentViewController:tweetController animated:YES completion:nil];
}

#pragma mark - PCEmailControllerDelegate

- (void)dismissPCEmailController:(MFMailComposeViewController *)currentPCEmailController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPCEmailController:(MFMailComposeViewController *)emailControllerToShow
{
    [self presentViewController:emailControllerToShow animated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
//    NSLog(@"Revision : %@", buttonTitle);
    
    if ([buttonTitle isEqualToString:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_YES"
                                                                            value:@"Yes"]]) {
        if ([[InAppPurchases sharedInstance] canMakePurchases]) {
            [[InAppPurchases sharedInstance] purchaseForProductId:_revision.issue.productIdentifier];
        } else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_MAKE_PURCHASE"
                                                                                                           value:@"You can't make the purchase"]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
                                                  otherButtonTitles:nil] autorelease];
			[alert show];
        }
    }
}

@end