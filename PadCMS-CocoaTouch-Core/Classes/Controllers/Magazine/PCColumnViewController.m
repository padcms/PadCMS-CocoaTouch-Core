//
//  PCColumnViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCColumnViewController.h"
#import "PCMagazineViewControllersFactory.h"
#import "PCSliderBasedMiniArticleViewController.h"
#import "PCGoogleAnalytics.h"
#import "PCScrollView.h"

@interface PCColumnViewController(ForwardDeclaration)
- (void) updateViewsForCurrentIndex;
@end

@implementation PCColumnViewController

@synthesize column;
@synthesize magazineViewController;
@synthesize pageViewControllers;
@synthesize horizontalOrientation;

-(void)dealloc
{
    self.magazineViewController = nil;
    self.column = nil;
    
    [mainScrollView release];
    [pageViewControllers release];
    
    [super dealloc];
}

-(id)initWithColumn:(PCColumn*)aColumn
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.column = aColumn;
        pageViewControllers = nil;
        magazineViewController = nil;
        pageSize = CGSizeMake(768, 1024);
        pageViewControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) setPageSize:(CGSize) spageSize
{
    pageSize = spageSize;
}

-(void)loadView
{
    [super loadView];
    self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, pageSize.width, pageSize.height)] autorelease];
    mainScrollView = [[PCScrollView alloc] initWithFrame:CGRectMake(0, 0, pageSize.width, pageSize.height)];
    [self.view addSubview:mainScrollView];
}

-(CGSize)pageSizeForViewController:(PCPageViewController*)pageViewController
{
    return pageSize;
}

-(void)createColumnsView
{
    mainScrollView.contentSize =  CGSizeMake(pageSize.width, pageSize.height * [column.pages count]);
    for (unsigned i = 0; i < [column.pages count]; i++)
    {
        PCPage* page = [column.pages objectAtIndex:i];
        PCPageViewController* pageViewController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:page]; 
        
        if (pageViewController == nil) continue;
        
        [pageViewController setMagazineViewController:self.magazineViewController];
        [pageViewController setColumnViewController:self];
        [pageViewControllers addObject:pageViewController];
        [pageViewController.view setFrame:CGRectMake(0, pageSize.height * i, pageSize.width, pageSize.height)];
        [mainScrollView addSubview:pageViewController.view];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    mainScrollView.delegate = self;
	mainScrollView.pagingEnabled = YES;
	mainScrollView.alwaysBounceHorizontal = NO;
	mainScrollView.bounces = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.verticalScrollButtonsEnabled = YES;
    
    if (column)
        [self createColumnsView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.magazineViewController.revision.horizontalMode)
    {
        return YES;
    }
    
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

-(PCPageViewController*)showViewAtIndex:(NSInteger)index
{
    if (index < 0 || [pageViewControllers count] <= index)
        return nil;
    
   PCPageViewController* viewController =  [pageViewControllers objectAtIndex:index];
   if (viewController)
   {
       [mainScrollView scrollRectToVisible:[[viewController view] frame] animated:YES];
       return viewController;
   }
    
   return nil;
}

-(PCPageViewController*)showPage:(PCPage*)page
{
    if (page.column == self.column)
    {
        NSInteger index = [page.column.pages indexOfObject:page];
        if (index != NSNotFound && index < [pageViewControllers count] && index >= 0)
        {
            return [self showViewAtIndex:index];
        }
    }
    return nil;
}

- (void) loadFullPageAtIndex:(NSInteger) index
{
    if(index >= 0 && index < [pageViewControllers count])
    {
        PCPageViewController *currentPage = [pageViewControllers objectAtIndex:index];
		dispatch_async(dispatch_get_main_queue(), ^{
			[currentPage loadFullView];
		});
        
      
    }
}

- (void) unloadFullPageAtIndex:(NSInteger) index
{
    if(index >= 0 && index < [pageViewControllers count])
    {
        PCPageViewController *currentPage = [pageViewControllers objectAtIndex:index];
		dispatch_async(dispatch_get_main_queue(), ^{
			[currentPage unloadFullView];
		});
        
    }
}

- (NSInteger) currentPageIndex
{
    return mainScrollView.contentOffset.y / mainScrollView.frame.size.height;
}

- (PCPageViewController*)currentPageViewController
{
    if([self currentPageIndex] >= 0 && [self currentPageIndex] < [pageViewControllers count])
    {
        return [pageViewControllers objectAtIndex:[self currentPageIndex]];
    }
    return nil;
}

- (void) updateViewsForCurrentIndex
{
    NSInteger currentIndex = [self currentPageIndex];
    
    for(int i = 0; i < [pageViewControllers count]; ++i)
    {
        if(ABS(currentIndex - i) > 1)
        {
            [self unloadFullPageAtIndex:i];
        }
        else
        {
            [self loadFullPageAtIndex:i];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
        [self updateViewsForCurrentIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [PCGoogleAnalytics trackPageView:[self currentPageViewController].page];
    if (!self.currentPageViewController.page.isComplete)
    {
       [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.currentPageViewController.page userInfo:nil];
    }
  [self updateViewsForCurrentIndex];    
	[self.currentPageViewController showHUD];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateViewsForCurrentIndex];
}

- (void) loadFullView
{
    [self updateViewsForCurrentIndex];
}

- (void) unloadFullView
{
    for(unsigned i = 0; i < [pageViewControllers count]; ++i)
    {
        [self unloadFullPageAtIndex:i];
    }
}

@end
