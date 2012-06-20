//
//  PSSlideshowViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSlideshowViewController.h"

#import "MBProgressHUD.h"
#import "PCDefaultStyleElements.h"
#import "PCRevision.h"
#import "PCScrollView.h"
#import "PCStyler.h"

@interface PCSlideshowViewController(ForwardDeclaration)
    - (void) updateViewsForCurrentIndex;
@end

@implementation PCSlideshowViewController

@synthesize slidersView;
@synthesize pageControll;
@synthesize slideViewControllers;

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:PCMiniArticleElementDidDownloadNotification object:self.page];
    self.slidersView = nil;
    self.pageControll = nil;
    self.slideViewControllers = nil;
    sliderRect = CGRectZero;
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:aPage])
    {
        slidersView = nil;
        pageControll = nil;
        sliderRect = CGRectZero;
        self.slideViewControllers = [[[NSMutableArray alloc] init] autorelease];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideDownloaded:) name:PCMiniArticleElementDidDownloadNotification object:self.page];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.slidersView = [[[PCScrollView alloc] initWithFrame:self.view.frame] autorelease];
    self.slidersView.delegate = self;
    self.slidersView.contentSize = CGSizeZero;
    self.slidersView.bounces = YES;
    self.slidersView.showsVerticalScrollIndicator = NO;
    self.slidersView.showsHorizontalScrollIndicator = NO;
    self.slidersView.clipsToBounds = YES;
    self.slidersView.alwaysBounceVertical = NO;
    self.slidersView.alwaysBounceHorizontal = YES;
    self.slidersView.pagingEnabled = YES;
    self.slidersView.delaysContentTouches = NO;
    self.slidersView.autoresizesSubviews = NO;
    self.slidersView.autoresizingMask = UIViewAutoresizingNone;
    self.mainScrollView.scrollEnabled = NO;
    [self.mainScrollView addSubview:self.slidersView];
}

-(void)showSlideAtIndex:(NSUInteger)aSlide
{
    CGRect slidersViewRect = self.slidersView.frame;
    CGRect slideRect = CGRectMake(slidersViewRect.size.width*aSlide, 0, slidersViewRect.size.width, slidersViewRect.size.height);
    [self.slidersView scrollRectToVisible:slideRect animated:YES];
	[self hideSlideHUD];
	[self showHUDforSlideAtIndex:aSlide];
 
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* slideElements = [page elementsForType:PCPageElementTypeSlide];
    
    sliderRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    
    if (slideElements && [slideElements count]>0)
    {
        for (unsigned i = 0; i < [slideElements count]; i++)
        {

            PCPageElementSlide* element = [slideElements objectAtIndex:i];
            float scale = slidersView.frame.size.width/element.size.width;            
            CGSize elementSize = element.size;
            if (element.size.width*element.size.height) {
                elementSize.height *= scale;
                elementSize.width *= scale;
            } else {
                elementSize.height = slidersView.frame.size.height;
                elementSize.width = slidersView.frame.size.width;
            }

           
            CGRect newSlideRect = CGRectMake(self.slidersView.frame.size.width*i, /*0+(self.slidersView.frame.size.height-elementSize.height)*/-sliderRect.origin.y, elementSize.width, elementSize.height);
            
            NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
            
            PCPageElementViewController *slideViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
            
            [slideViewController.view setFrame:newSlideRect];
          slideViewController.element = element;
          
            [self.slideViewControllers addObject:slideViewController];
         
            [self.slidersView addSubview:slideViewController.view];
         
          
            [slideViewController release];
        }
    }
    
    [[self mainScrollView] bringSubviewToFront:self.slidersView];
    
    CGRect pageControllRect = CGRectMake(sliderRect.origin.x, sliderRect.origin.y+sliderRect.size.height-30, sliderRect.size.width, 30);
    self.pageControll = [[[PCCustomPageControll alloc] initWithFrame:pageControllRect] autorelease];
    
    NSDictionary* controllOption = nil;
    if (self.page.color)
        controllOption = [NSDictionary dictionaryWithObject:self.page.color forKey:PCButtonTintColorOptionKey];
    
    [[PCStyler defaultStyler] stylizeElement:self.pageControll withStyleName:PCSliderPageControlItemKey withOptions:controllOption];
    
    self.pageControll.numberOfPages = [[self.slidersView subviews] count];
    self.pageControll.currentPage = 0;
    [self.pageControll addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControll];
    [self.view bringSubviewToFront:self.pageControll];
    
    //[self showSlideAtIndex:0];
}

- (void) loadFullView
{
    [super loadFullView];
    
    //change slidersView contentSize and frame here for avoid subviews frame random changes
    if (!CGRectEqualToRect(sliderRect, CGRectZero))
    {
        [self.slidersView setFrame:sliderRect];
        
        [self.slidersView setContentSize:CGSizeMake([slideViewControllers count] * self.slidersView.frame.size.width,
                                                    self.slidersView.frame.size.height - 1)];
        //decrease height for avoid vertical bounce
    }
    
    for (unsigned i = 0; i < [slideViewControllers count]; i++)
    {
        UIViewController *slideController = [slideViewControllers objectAtIndex:i];
        
        CGRect newSlideRect = CGRectMake(self.view.frame.size.width * i, /*self.slidersView.frame.size.height - self.view.frame.size.height*/-sliderRect.origin.y, self.view.frame.size.width, self.view.frame.size.height);

        [slideController.view setFrame:newSlideRect];
      
    }
    
    [self updateViewsForCurrentIndex];
}

- (void) unloadFullView
{
    [super unloadFullView];
	[self hideSlideHUD];
    
    for(PCPageElementViewController *slideViewController in self.slideViewControllers)
    {
        [slideViewController unloadView];
    }
}

- (void) updateViewsForCurrentIndex
{
    if (self.slideViewControllers.count == 0) {
        return;
    }
    
    PCPageElement* currentElement = [[self.slideViewControllers objectAtIndex:self.pageControll.currentPage] element];
    if (currentElement && !currentElement.isComplete && self.pageControll.currentPage != 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:currentElement ];
    }
    
    
    if(self.slidersView != nil)
    { 
        self.slidersView.scrollEnabled = YES;
    }
    
    for(int i = 0; i < [self.slideViewControllers count]; ++i)
    {
        if(ABS(self.pageControll.currentPage - i) > 1)
        {
            [[self.slideViewControllers objectAtIndex:i] unloadView];
        }
        else
        {
            [[self.slideViewControllers objectAtIndex:i] loadFullViewImmediate];
        }
    }
}

/*
- (CGRect)activeZoneRectForType:(NSString*)zoneType
{
    PCPageElement* pageElement = [page firstElementForType:PCPageElementTypeBackground];
    if(pageElement != nil)
    {
        return [self getActiveZoneRectFor:pageElement type:zoneType viewController:self.backgroundViewController];
    }
    
    return CGRectZero;
}
 */

-(void)showHUDforSlideAtIndex:(NSInteger)index
{
    if (self.slideViewControllers.count == 0) {
        return;
    }
    
	if (!isLoaded) return;
	if (!self.page.isComplete) return;
	PCPageElement* currentElement = [[self.slideViewControllers objectAtIndex:index] element];
	if (currentElement.isComplete) return;
	if (slideHUD)
	{
		if (slideHUD.tag == index+100)  return;
		currentElement.progressDelegate = nil;
		[slideHUD removeFromSuperview];
		[slideHUD release];
		slideHUD = nil;
	}
	
	
	slideHUD = [[MBProgressHUD alloc] initWithView:self.view];
	slideHUD.tag = index+100;
	//slideHUD.frame = CGRectMake(0, 0, 60.0f, 60.f);
	slideHUD.center = CGPointMake(/*index*sliderRect.size.width +*/ sliderRect.origin.x + sliderRect.size.width/2, sliderRect.origin.y + sliderRect.size.height/2);
	NSLog(@"FRAme HUD - %@", NSStringFromCGRect(slideHUD.frame));
	[self.view addSubview:slideHUD];
	slideHUD.mode = MBProgressHUDModeAnnularDeterminate;
	currentElement.progressDelegate = slideHUD;
	[slideHUD show:YES];
}

-(void)hideSlideHUD
{
	if (slideHUD)
	{
		[slideHUD hide:YES];
		PCPageElement* currentElement = [[self.slideViewControllers objectAtIndex:slideHUD.tag - 100] element];
		currentElement.progressDelegate = nil;
		[slideHUD removeFromSuperview];
		[slideHUD release];
		slideHUD = nil;
	}
}


-(void)changePage:(id)sender
{
    [self showSlideAtIndex:self.pageControll.currentPage];
}

- (void) afterScroll
{
    self.pageControll.currentPage = lrint(self.slidersView.contentOffset.x/self.slidersView.frame.size.width);
    
    [self updateViewsForCurrentIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        [self afterScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self hideSlideHUD];
	[self showHUDforSlideAtIndex:lrint(self.slidersView.contentOffset.x/self.slidersView.frame.size.width)];
    [self afterScroll];    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self afterScroll];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.slidersView)
    {
            if (scrollView.contentOffset.x < 0)
            {
                if (self.pageControll.currentPage == 0)
                {
                    if([self.magazineViewController showPrevColumn])
                    {
                        scrollView.scrollEnabled = NO;
                    }
                }
            }
            
            if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width)
            {
                if (self.pageControll.currentPage == self.pageControll.numberOfPages-1)
                {
                    if([self.magazineViewController showNextColumn])
                    {
                        scrollView.scrollEnabled = NO;
                    }
                }
            }
    }
}


- (void)slideDownloaded:(NSNotification*)notif
{
	PCPageElementMiniArticle* downloadedElement = [[notif userInfo] objectForKey:@"element"];
  PCPageElement* currentElement = [[self.slideViewControllers objectAtIndex:self.pageControll.currentPage] element];
	if (slideHUD)
	{
		if (slideHUD.tag == 100 + self.pageControll.currentPage)
		{
			[self hideSlideHUD];
		}
	}
	if (currentElement == downloadedElement)
	{
    [self updateViewsForCurrentIndex];
	}
}

@end
