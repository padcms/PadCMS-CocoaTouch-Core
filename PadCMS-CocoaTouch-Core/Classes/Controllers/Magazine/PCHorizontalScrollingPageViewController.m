//
//  PCHorizontalScrollingPageViewController.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 24.05.12.
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

#import "PCHorizontalScrollingPageViewController.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"
#import "MBProgressHUD.h"
#import "PCRevision.h"
#import "PCScrollView.h"

@interface PCHorizontalScrollingPageViewController ()
- (void)updateScrollButtonsWithOffset:(CGPoint)contentOffset;
- (void)afterScroll;
@end

@implementation PCHorizontalScrollingPageViewController

@synthesize scrollingPane;
@synthesize scrollingPaneContentView;

- (void)dealloc
{
    [scrollRightButton removeFromSuperview];
    [scrollRightButton release];
    scrollRightButton = nil;
    
    [scrollLeftButton removeFromSuperview];
    [scrollLeftButton release];
    scrollLeftButton = nil;
    
    self.scrollingPane = nil;
    self.scrollingPaneContentView = nil;
    
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:aPage])
    {
        scrollingPane = nil;
        scrollingPaneContentView = nil;
        scrollRightButton = nil;
        scrollLeftButton = nil;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
}

- (void) loadFullView
{
    [super loadFullView];
    
    [self.scrollingPaneContentView loadFullViewImmediate];
    
    CGRect frame = self.scrollingPaneContentView.view.frame;
    
    frame.origin.y = -self.scrollingPane.frame.origin.y;
    frame.origin.x = 0;
    [self.scrollingPaneContentView.view setFrame:frame];
    
    [self.scrollingPane setContentSize:CGSizeMake([self.scrollingPaneContentView.view frame].size.width, 1)];
    [self.scrollingPane setContentInset:UIEdgeInsetsMake(0, -self.scrollingPane.frame.origin.x, 0, 0)];
    
    [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
    
    self.scrollingPane.scrollEnabled = YES;
}

- (void) unloadFullView
{ 
    [super unloadFullView];
    
    [self.scrollingPaneContentView unloadView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Scroll pan
    CGRect scrollPaneRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    
    if (CGRectEqualToRect(scrollPaneRect, CGRectZero))
        scrollPaneRect = [[self mainScrollView] bounds];
    
    self.scrollingPane = [[[PCScrollView alloc] initWithFrame:scrollPaneRect] autorelease];
    self.scrollingPane.delegate = self;
    self.scrollingPane.contentSize = CGSizeZero;
    self.scrollingPane.showsVerticalScrollIndicator = NO;
    self.scrollingPane.showsHorizontalScrollIndicator = NO;
    
    PCPageElement* scrollingPaneElement = [page firstElementForType:PCPageElementTypeScrollingPane];
    if (scrollingPaneElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:scrollingPaneElement.resource];
        
        self.scrollingPaneContentView = [[[PCHorizontalPageElementViewController alloc] initWithResource:fullResource] autorelease];
        
        self.scrollingPaneContentView.targetHeight = 768;
        
        [self.scrollingPane addSubview:self.scrollingPaneContentView.view];
        [self.scrollingPane setContentSize:self.scrollingPaneContentView.view.frame.size];
        [self.scrollingPane setContentInset:UIEdgeInsetsMake(0, -self.scrollingPane.frame.origin.x, 0, 0)];
    }
    
    [self.scrollingPane setUserInteractionEnabled:YES];
    [self.mainScrollView addSubview: self.scrollingPane];
    [self.mainScrollView setContentSize: self.scrollingPane.frame.size];
    [self.mainScrollView bringSubviewToFront: self.scrollingPane];
    
    if (self.scrollingPane.frame.size.width > self.mainScrollView.frame.size.width)
    {
        CGRect scrollingPaneRect = self.scrollingPane.frame;
        scrollingPaneRect.size.width = self.mainScrollView.frame.size.width;
        self.scrollingPane.frame = scrollingPaneRect;
    }
    
    if (self.scrollingPane.contentSize.width > self.scrollingPane.frame.size.width)
    {
        self.scrollingPane.contentSize = CGSizeMake(self.scrollingPane.frame.size.width, self.scrollingPane.contentSize.height);
    }
    
    // Buttons
    scrollRightButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    
    NSDictionary* buttonOption = nil;
    if (self.page.color)
        buttonOption = [NSDictionary dictionaryWithObject:self.page.color forKey:PCButtonTintColorOptionKey];
    
    [[PCStyler defaultStyler] stylizeElement:scrollRightButton withStyleName:PCScrollControlKey withOptions:buttonOption];
    
    CGRect  scrollingPaneRect = self.scrollingPane.frame;

    CGRect scrollRightButtonRect = CGRectMake(scrollingPaneRect.origin.x + scrollingPaneRect.size.width - scrollRightButton.frame.size.height,
                                              scrollingPaneRect.origin.y + (scrollingPaneRect.size.height - scrollRightButton.frame.size.width)/2,
                                              scrollRightButton.frame.size.height, scrollRightButton.frame.size.width);
    
    scrollRightButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [scrollRightButton setFrame:scrollRightButtonRect];
    [scrollRightButton addTarget:self action:@selector(scrollRight:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:scrollRightButton];
    
    scrollLeftButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [[PCStyler defaultStyler] stylizeElement:scrollLeftButton withStyleName:PCScrollControlKey withOptions:buttonOption];    
    
    CGRect  scrollLeftButtonRect = CGRectMake(scrollingPaneRect.origin.x,
                                              scrollingPaneRect.origin.y + (scrollingPaneRect.size.height - scrollLeftButton.frame.size.width)/2,
                                              scrollLeftButton.frame.size.height, scrollLeftButton.frame.size.width);
    scrollLeftButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [scrollLeftButton setFrame:scrollLeftButtonRect];
    [scrollLeftButton addTarget:self action:@selector(scrollLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:scrollLeftButton];
    [self.mainScrollView bringSubviewToFront:HUD];
    
    [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
}

-(void)updateScrollButtonsWithOffset:(CGPoint)contentOffset
{
    [scrollLeftButton setHidden:(contentOffset.x <= 0)];
    [scrollRightButton setHidden:(contentOffset.x >= self.scrollingPane.contentSize.width-self.scrollingPane.frame.size.width)];
}

-(void)scrollRight:(id)sender
{
    CGPoint contentOffset = [self.scrollingPane contentOffset];
    contentOffset.x += self.scrollingPane.frame.size.width;
    if (contentOffset.x > (self.scrollingPane.contentSize.width - self.scrollingPane.frame.size.width))
        contentOffset.x = (self.scrollingPane.contentSize.width - self.scrollingPane.frame.size.width);
    [self.scrollingPane  setContentOffset:contentOffset animated:YES];
    [self updateScrollButtonsWithOffset:contentOffset];
}

-(void)scrollLeft:(id)sender
{
    CGPoint contentOffset = [self.scrollingPane contentOffset];
    contentOffset.x -= self.scrollingPane.frame.size.width;
    if (contentOffset.x < 0)
        contentOffset.x = 0;
    [self.scrollingPane  setContentOffset:contentOffset animated:YES];
    [self updateScrollButtonsWithOffset:contentOffset];
    
}

- (void)afterScroll
{
    if(self.scrollingPane)
        self.scrollingPane.scrollEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        if (scrollView == self.scrollingPane)
        {
            [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
        }
        
        [self afterScroll];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollingPane)
    {
        [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
        [self afterScroll];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollingPane)
    {
        [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
        [self afterScroll];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollingPane)
    {
        if(scrollView.decelerating) return;
        if (scrollView.contentOffset.x < 0)
        {
            if([self.magazineViewController showPrevColumn])
            {
                NSLog(@"PREV!!");
                scrollView.scrollEnabled = NO;
            }
        }
        
        if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width)
        {
            if([self.magazineViewController showNextColumn])
            {
                scrollView.scrollEnabled = NO;
            }
        }
    }
}
@end
