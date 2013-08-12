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

#import "MBProgressHUD.h"
#import "PCConfig.h"
#import "PCDefaultStyleElements.h"
#import "PCHorizontalPageElementViewController.h"
#import "PCRevision.h"
#import "PCScrollView.h"
#import "PCStyler.h"

@interface PCHorizontalScrollingPageViewController ()
{
    PCScrollView *_paneScrollView;
    PCHorizontalPageElementViewController *_paneContentViewController;
    UIButton *_scrollRightButton;
    UIButton *_scrollLeftButton;
}

- (void)initializeScrollButtons;
- (void)deinitializeScrollButtons;
- (void)updateScrollButtons;

- (void)scrollLeftButtonTapped:(UIButton *)sender;
- (void)scrollRightButtonTapped:(UIButton *)sender;

@end

@implementation PCHorizontalScrollingPageViewController

- (void)dealloc
{
    [self deinitializeScrollButtons];
    
    _paneScrollView = nil;
    _paneContentViewController = nil;
    
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:aPage])
    {
        _paneScrollView = nil;
        _paneContentViewController = nil;
        _scrollRightButton = nil;
        _scrollLeftButton = nil;
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
    
    [_paneContentViewController loadFullViewImmediate];
    
    CGRect frame = _paneContentViewController.view.frame;
    
    frame.origin.y = -_paneScrollView.frame.origin.y;
    frame.origin.x = 0;
    [_paneContentViewController.view setFrame:frame];
    
    [_paneScrollView setContentSize:CGSizeMake([_paneContentViewController.view frame].size.width, 1)];
    [_paneScrollView setContentInset:UIEdgeInsetsMake(0, -_paneScrollView.frame.origin.x, 0, 0)];
    
    [self updateScrollButtons];
    
    _paneScrollView.scrollEnabled = YES;
}

- (void) unloadFullView
{ 
    [super unloadFullView];
    
    [_paneContentViewController unloadView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect scrollPaneRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    
    if (CGRectEqualToRect(scrollPaneRect, CGRectZero)) {
        scrollPaneRect = self.mainScrollView.bounds;
    }
    
    _paneScrollView = [[PCScrollView alloc] initWithFrame:scrollPaneRect];
    _paneScrollView.delegate = self;
    _paneScrollView.contentSize = CGSizeZero;
    _paneScrollView.showsVerticalScrollIndicator = NO;
    _paneScrollView.showsHorizontalScrollIndicator = NO;
    
    PCPageElement* scrollingPaneElement = [page firstElementForType:PCPageElementTypeScrollingPane];
    
    if (scrollingPaneElement != nil) {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:scrollingPaneElement.resource];
        _paneContentViewController = [[PCHorizontalPageElementViewController alloc] initWithResource:fullResource];
        
        if (self.page.revision.horizontalOrientation) {
            _paneContentViewController.targetHeight = 768;
        } else {
            _paneContentViewController.targetHeight = 1024;
        }
        
        [_paneScrollView addSubview:_paneContentViewController.view];
        [_paneScrollView setContentSize:_paneContentViewController.view.frame.size];
        [_paneScrollView setContentInset:UIEdgeInsetsMake(0, -_paneScrollView.frame.origin.x, 0, 0)];
    }
    
    [_paneScrollView setUserInteractionEnabled:YES];
    [mainScrollView addSubview:_paneScrollView];
    [mainScrollView setContentSize:_paneScrollView.frame.size];
    [mainScrollView bringSubviewToFront:_paneScrollView];
    
    if (_paneScrollView.frame.size.width > self.mainScrollView.frame.size.width) {
        CGRect scrollingPaneRect = _paneScrollView.frame;
        scrollingPaneRect.size.width = self.mainScrollView.frame.size.width;
        _paneScrollView.frame = scrollingPaneRect;
    }
    
    if (_paneScrollView.contentSize.width > _paneScrollView.frame.size.width) {
        _paneScrollView.contentSize = CGSizeMake(_paneScrollView.frame.size.width, _paneScrollView.contentSize.height);
    }
    
    [self initializeScrollButtons];
    
    [self.mainScrollView bringSubviewToFront:HUD];
}

- (void)initializeScrollButtons
{
    if ([PCConfig isScrollingPageHorizontalScrollButtonsDisabled]) {
        return;
    }
    
    NSDictionary *buttonOption = nil;
    UIColor *pageColor = self.page.color;
    if (pageColor != nil) {
        buttonOption = [NSDictionary dictionaryWithObject:self.page.color
                                                   forKey:PCButtonTintColorOptionKey];
    }
    // Scroll right button
    _scrollRightButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    
    [[PCStyler defaultStyler] stylizeElement:_scrollRightButton withStyleName:PCScrollControlKey 
                                 withOptions:buttonOption];
    
    CGRect paneScrollViewFrame = _paneScrollView.frame;
    CGRect scrollRightButtonFrame = 
    CGRectMake(paneScrollViewFrame.origin.x + paneScrollViewFrame.size.width - _scrollRightButton.frame.size.height,
               paneScrollViewFrame.origin.y + (paneScrollViewFrame.size.height - _scrollRightButton.frame.size.width) / 2,
               _scrollRightButton.frame.size.height,
               _scrollRightButton.frame.size.width);
    
    _scrollRightButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _scrollRightButton.frame = scrollRightButtonFrame;
    [_scrollRightButton addTarget:self action:@selector(scrollRightButtonTapped:) 
                 forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:_scrollRightButton];
    
    _scrollLeftButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [[PCStyler defaultStyler] stylizeElement:_scrollLeftButton 
                               withStyleName:PCScrollControlKey 
                                 withOptions:buttonOption];    
    
    // Scroll left button
    CGRect  scrollLeftButtonFrame = 
    CGRectMake(paneScrollViewFrame.origin.x,
               paneScrollViewFrame.origin.y + (paneScrollViewFrame.size.height - _scrollLeftButton.frame.size.width) / 2,
               _scrollLeftButton.frame.size.height, 
               _scrollLeftButton.frame.size.width);
    
    _scrollLeftButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [_scrollLeftButton setFrame:scrollLeftButtonFrame];
    [_scrollLeftButton addTarget:self action:@selector(scrollLeftButtonTapped:) 
                forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:_scrollLeftButton];

    [self updateScrollButtons];
}

- (void)deinitializeScrollButtons
{
    if (_scrollLeftButton != nil) {
        [_scrollLeftButton removeFromSuperview];
        [_scrollLeftButton release];
        _scrollLeftButton = nil;
    }

    if (_scrollRightButton != nil) {
        [_scrollRightButton removeFromSuperview];
        [_scrollRightButton release];
        _scrollRightButton = nil;
    }
}

- (void)updateScrollButtons
{
    _paneScrollView.scrollEnabled = YES;
    
    if (_scrollLeftButton) {
        _scrollLeftButton.hidden = _paneScrollView.contentOffset.x <= 0;
    }
    
    if (_scrollRightButton) {
        _scrollRightButton.hidden = (_paneScrollView.contentOffset.x >= 
        _paneScrollView.contentSize.width - _paneScrollView.frame.size.width);
    }
}

- (void)scrollLeftButtonTapped:(UIButton *)sender
{
    [_paneScrollView scrollLeft];
    [self updateScrollButtons];
}

- (void)scrollRightButtonTapped:(UIButton *)sender
{
    [_paneScrollView scrollRight];
    [self updateScrollButtons];
}

#pragma mark - UIScrollViewDelegate
 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _paneScrollView) {
        if (scrollView.decelerating) {
            return;
        }
        
        if (scrollView.contentOffset.x < 0) {
            _paneScrollView.scrollEnabled = NO;
            [self.magazineViewController showPrevColumn];
            return;
        }
        
        if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width) {
            _paneScrollView.scrollEnabled = NO;
            [self.magazineViewController showNextColumn];
            return;
        }
        
        [self updateScrollButtons];
    }
}

@end
