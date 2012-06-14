//
//  PCScrollingPageViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 09.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCScrollingPageViewController.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"
#import "MBProgressHUD.h"
//#import "PCPageElementsViewFactory.h"
#import "PCRevision.h"
#import "PCScrollView.h"

@interface PCScrollingPageViewController(ForwardDeclaration)
-(void)updateScrollButtonsWithOffset:(CGPoint)contentOffset;
@end

@implementation PCScrollingPageViewController

@synthesize scrollingPane;
@synthesize scrollingPaneContentView;

- (void)dealloc
{
    [scrollDownButton removeFromSuperview];
    [scrollDownButton release];
    scrollDownButton = nil;
    
    [scrollUpButton removeFromSuperview];
    [scrollUpButton release];
    scrollUpButton = nil;
    
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
        scrollDownButton = nil;
        scrollUpButton = nil;
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
    
    [self.scrollingPane setContentSize:CGSizeMake(1,[self.scrollingPaneContentView.view frame].size.height)];
    [self.scrollingPane setContentInset:UIEdgeInsetsMake(0, -self.scrollingPane.frame.origin.x, 0, 0)];

    [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
}

- (void) unloadFullView
{ 
    [super unloadFullView];
    
    [self.scrollingPaneContentView unloadView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
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
        
        self.scrollingPaneContentView = [[[PCPageElementViewController alloc] initWithResource:fullResource] autorelease];
            
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
    
    scrollDownButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    
    NSDictionary* buttonOption = nil;
    if (self.page.color)
        buttonOption = [NSDictionary dictionaryWithObject:self.page.color forKey:PCButtonTintColorOptionKey];
    
    [[PCStyler defaultStyler] stylizeElement:scrollDownButton withStyleName:PCScrollControlKey withOptions:buttonOption];
    
    CGRect  scrollingPaneRect = self.scrollingPane.frame;
    
    CGRect scrollDownButtonRect = CGRectMake(scrollingPaneRect.origin.x + (scrollingPaneRect.size.width - scrollDownButton.frame.size.width)/2, scrollingPaneRect.origin.y + scrollingPaneRect.size.height - scrollDownButton.frame.size.height, scrollDownButton.frame.size.width, scrollDownButton.frame.size.height);
    [scrollDownButton setFrame:scrollDownButtonRect];
    [scrollDownButton addTarget:self action:@selector(scrollDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:scrollDownButton];
    
    scrollUpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [[PCStyler defaultStyler] stylizeElement:scrollUpButton withStyleName:PCScrollControlKey withOptions:buttonOption];    
    
    CGRect  scrollUpButtonRect = CGRectMake(scrollingPaneRect.origin.x + (scrollingPaneRect.size.width - scrollUpButton.frame.size.width)/2, scrollingPaneRect.origin.y, scrollUpButton.frame.size.width, scrollUpButton.frame.size.height);
    scrollUpButton.transform = CGAffineTransformMakeScale(1, -1);
    [scrollUpButton setFrame:scrollUpButtonRect];
    [scrollUpButton addTarget:self action:@selector(scrollUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:scrollUpButton];
    [self.mainScrollView bringSubviewToFront:HUD];
      
    [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
}

-(void)updateScrollButtonsWithOffset:(CGPoint)contentOffset
{
    [scrollUpButton setHidden:(contentOffset.y <= 0)];
    [scrollDownButton setHidden:(contentOffset.y >= self.scrollingPane.contentSize.height-self.scrollingPane.frame.size.height)];
}

-(void)scrollDown:(id)sender
{
    CGPoint contentOffset = [self.scrollingPane contentOffset];
    contentOffset.y += self.scrollingPane.frame.size.height;
    if (contentOffset.y > (self.scrollingPane.contentSize.height - self.scrollingPane.frame.size.height))
        contentOffset.y = (self.scrollingPane.contentSize.height - self.scrollingPane.frame.size.height);
    [self.scrollingPane  setContentOffset:contentOffset animated:YES];
    [self updateScrollButtonsWithOffset:contentOffset];
}

-(void)scrollUp:(id)sender
{
    CGPoint contentOffset = [self.scrollingPane contentOffset];
    contentOffset.y -= self.scrollingPane.frame.size.height;
    if (contentOffset.y < 0)
        contentOffset.y = 0;
    [self.scrollingPane  setContentOffset:contentOffset animated:YES];
    [self updateScrollButtonsWithOffset:contentOffset];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollingPane)
        [self updateScrollButtonsWithOffset:[self.scrollingPane contentOffset]];
}


@end
