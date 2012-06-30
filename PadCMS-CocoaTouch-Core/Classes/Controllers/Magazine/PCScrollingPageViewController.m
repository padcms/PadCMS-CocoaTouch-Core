//
//  PCScrollingPageViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 09.02.12.
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

#import "PCScrollingPageViewController.h"

#import "MBProgressHUD.h"
#import "PCConfig.h"
#import "PCDefaultStyleElements.h"
#import "PCRevision.h"
#import "PCScrollView.h"
#import "PCStyler.h"

@interface PCScrollingPageViewController()
{
    PCScrollView *_paneScrollView;
    PCPageElementViewController *_paneContentViewController;
    UIButton *_scrollDownButton;
    UIButton *_scrollUpButton;
}

- (void)initializeScrollButtons;
- (void)deinitializeScrollButtons;
- (void)updateScrollButtons;

- (void)scrollDownButtonTapped:(UIButton *)sender;
- (void)scrollUpButtonTapped:(UIButton *)sender;

@end

@implementation PCScrollingPageViewController

- (void)dealloc
{
    [self deinitializeScrollButtons];

    [_paneContentViewController release];
    [_paneScrollView release];
    
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:aPage])
    {
        _paneScrollView = nil;
        _paneContentViewController = nil;
        _scrollDownButton = nil;
        _scrollUpButton = nil;
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
    
    [_paneScrollView setContentSize:CGSizeMake(1, [_paneContentViewController.view frame].size.height)];
    [_paneScrollView setContentInset:UIEdgeInsetsMake(0, -_paneScrollView.frame.origin.x, 0, 0)];

    [self updateScrollButtons];
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
        scrollPaneRect = [[self mainScrollView] bounds];
    }
    
    _paneScrollView = [[PCScrollView alloc] initWithFrame:scrollPaneRect];
    _paneScrollView.delegate = self;
    _paneScrollView.contentSize = CGSizeZero;
    _paneScrollView.showsVerticalScrollIndicator = NO;
    _paneScrollView.showsHorizontalScrollIndicator = NO;
    
    PCPageElement* scrollingPaneElement = [page firstElementForType:PCPageElementTypeScrollingPane];
    if (scrollingPaneElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:scrollingPaneElement.resource];
        
        _paneContentViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
            
        [_paneScrollView addSubview:_paneContentViewController.view];
        [_paneScrollView setContentSize:_paneContentViewController.view.frame.size];
        [_paneScrollView setContentInset:UIEdgeInsetsMake(0, -_paneScrollView.frame.origin.x, 0, 0)];
    }
    
    [_paneScrollView setUserInteractionEnabled:YES];
    [self.mainScrollView addSubview: _paneScrollView];
    [self.mainScrollView setContentSize: _paneScrollView.frame.size];
    [self.mainScrollView bringSubviewToFront: _paneScrollView];
    
    if (_paneScrollView.frame.size.width > self.mainScrollView.frame.size.width)
    {
        CGRect scrollingPaneRect = _paneScrollView.frame;
        scrollingPaneRect.size.width = self.mainScrollView.frame.size.width;
        _paneScrollView.frame = scrollingPaneRect;
    }
    
    if (_paneScrollView.contentSize.width > _paneScrollView.frame.size.width)
    {
        _paneScrollView.contentSize = CGSizeMake(_paneScrollView.frame.size.width, _paneScrollView.contentSize.height);
    }
    
    [self initializeScrollButtons];
    [self.mainScrollView bringSubviewToFront:HUD];
}

- (void)initializeScrollButtons
{
    if ([PCConfig isScrollingPageVerticalScrollButtonsDisabled]) {
        return;
    }
    
    CGRect scrollingPaneFrame = _paneScrollView.frame;

    NSDictionary *buttonOption = nil;
    UIColor *pageColor = self.page.color;
    if (pageColor != nil) {
        buttonOption = [NSDictionary dictionaryWithObject:pageColor forKey:PCButtonTintColorOptionKey];
    }

    _scrollDownButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [[PCStyler defaultStyler] stylizeElement:_scrollDownButton withStyleName:PCScrollControlKey withOptions:buttonOption];
    
    CGRect scrollDownButtonRect = 
    CGRectMake(scrollingPaneFrame.origin.x + (scrollingPaneFrame.size.width - _scrollDownButton.frame.size.width) / 2,
               scrollingPaneFrame.origin.y + scrollingPaneFrame.size.height - _scrollDownButton.frame.size.height,
               _scrollDownButton.frame.size.width,
               _scrollDownButton.frame.size.height);
    
    [_scrollDownButton setFrame:scrollDownButtonRect];
    [_scrollDownButton addTarget:self action:@selector(scrollDownButtonTapped:) 
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:_scrollDownButton];
    
    _scrollUpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [[PCStyler defaultStyler] stylizeElement:_scrollUpButton withStyleName:PCScrollControlKey 
                                 withOptions:buttonOption];    
    
    CGRect  scrollUpButtonRect = 
    CGRectMake(scrollingPaneFrame.origin.x + (scrollingPaneFrame.size.width - _scrollUpButton.frame.size.width) / 2,
               scrollingPaneFrame.origin.y,
               _scrollUpButton.frame.size.width, 
               _scrollUpButton.frame.size.height);
    
    _scrollUpButton.transform = CGAffineTransformMakeScale(1, -1);
    [_scrollUpButton setFrame:scrollUpButtonRect];
    [_scrollUpButton addTarget:self action:@selector(scrollUpButtonTapped:) 
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:_scrollUpButton];
    
    [self updateScrollButtons];
}

- (void)deinitializeScrollButtons
{
    if (_scrollUpButton != nil) {
        [_scrollUpButton removeFromSuperview];
        [_scrollUpButton release];
        _scrollUpButton = nil;
    }

    if (_scrollDownButton != nil) {
        [_scrollDownButton removeFromSuperview];
        [_scrollDownButton release];
        _scrollDownButton = nil;
    }
}

- (void)updateScrollButtons
{
    if (_scrollDownButton != nil) {
        _scrollDownButton.hidden = (_paneScrollView.contentOffset.y >= 
        _paneScrollView.contentSize.height - _paneScrollView.frame.size.height);
    }

    if (_scrollUpButton != nil) {
        _scrollUpButton.hidden = _paneScrollView.contentOffset.y <= 0;
    }
}

- (void)scrollDownButtonTapped:(UIButton *)sender
{
    [_paneScrollView scrollDown];
    [self updateScrollButtons];
}

- (void)scrollUpButtonTapped:(UIButton *)sender
{
    [_paneScrollView scrollUp];
    [self updateScrollButtons];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateScrollButtons];
}

@end
