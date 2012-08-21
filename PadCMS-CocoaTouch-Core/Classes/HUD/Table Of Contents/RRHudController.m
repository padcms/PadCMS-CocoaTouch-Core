//
//  RRHudController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/21/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "RRHudController.h"

#import "PCGridView.h"
#import "PCResourceCache.h"
#import "PCRevision.h"
#import "PCSummaryView.h"
#import "PCTocItem.h"
#import "PCTopBarView.h"

@interface RRHudController ()
{
    PCRevision *_revision;
    BOOL _previewMode;
    PCHudView *_hudView;
}

- (void)tocDownloaded:(NSNotification *)notification;

- (void)delegateDismissAllPopups;
- (void)delegateSelectedTocItem:(PCTocItem *)tocItem;
- (void)delegateTopBarView:(PCTopBarView *)topBarView buttonTapped:(UIButton *)button;

@end

@implementation RRHudController
@synthesize delegate;
@synthesize revision = _revision;
@synthesize previewMode = _previewMode;
@synthesize hudView = _hudView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:endOfDownloadingTocNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PCHorizontalTocDidDownloadNotification
                                                  object:nil];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _revision = nil;
        _previewMode = NO;
        _hudView = [[PCHudView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
        _hudView.dataSource = self;
        _hudView.delegate = self;
        _hudView.topBarView.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tocDownloaded:)
                                                     name:endOfDownloadingTocNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tocDownloaded:)
                                                     name:PCHorizontalTocDidDownloadNotification
                                                   object:nil];

    }
    return self;
}

#pragma mark - private methods

- (void)tocDownloaded:(NSNotification *)notification
{
    [self update];
}

#pragma mark - public methods

- (void)update
{
    if (_revision == nil) {
        return;
    }
    
    if (_hudView.topTocView != nil) {
        if (_previewMode) {
            [_hudView.topTocView transitToState:RRViewStateHidden animated:NO];
            [_hudView.topBarView transitToState:RRViewStateHidden animated:NO];
        } else {
            [_hudView.topTocView transitToState:RRViewStateVisible animated:YES];
        }
    }
    
    if (!_previewMode && _revision.verticalTocLoaded && _revision.horizontalTocLoaded) {
        
        if (_hudView.bottomTocView != nil) {
            
            if (_hudView.topBarView.state == RRViewStateVisible) {
                [_hudView.bottomTocView transitToState:RRViewStateVisible animated:YES];
            }
        }
        
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            [_hudView.topBarView setSummaryButtonHidden:NO animated:NO];
        } else {
            [_hudView.topBarView setSummaryButtonHidden:YES animated:NO];
            [self delegateDismissAllPopups];
        }
        
    } else {
        
        if (_hudView.bottomTocView != nil) {
            [_hudView.bottomTocView transitToState:RRViewStateHidden animated:NO];
        }
        [_hudView.topBarView setSummaryButtonHidden:YES animated:NO];
    }
    
    [_hudView reloadData];
}

- (void)handleTap
{
    if (_revision == nil) {
        return;
    }
    
//    if (_shareView != nil) {
//        [_shareView dismiss];
//    }
    
    if (_hudView.summaryView != nil) {
        [_hudView hideSummaryAnimated:YES];
    }
    
    if (_hudView.topTocView != nil) {
        
        if (_previewMode) {
            
            if (_hudView.topBarView.state == RRViewStateVisible) {
                [_hudView.topBarView transitToState:RRViewStateHidden animated:YES];
                [self delegateDismissAllPopups];
            } else {
                [_hudView.topBarView transitToState:RRViewStateVisible animated:YES];
            }
        } else {
            if (_hudView.bottomTocView.state == RRViewStateVisible) {
                [_hudView.topTocView transitToState:RRViewStateActive animated:YES];
            } else {
                [_hudView.topTocView transitToState:RRViewStateVisible animated:YES];
            }
        }
        
        return;
    }
    
    if (!_previewMode && _revision.verticalTocLoaded && _revision.horizontalTocLoaded) {
        
        if (_hudView.bottomTocView != nil) {
            if (_hudView.bottomTocView.state == RRViewStateVisible) {
                [_hudView.bottomTocView transitToState:RRViewStateHidden animated:YES];
                [_hudView.topBarView transitToState:RRViewStateHidden animated:YES];
                [self delegateDismissAllPopups];
            } else {
                [_hudView.bottomTocView transitToState:RRViewStateVisible animated:YES];
                [_hudView.topBarView transitToState:RRViewStateVisible animated:YES];
            }
        }
    } else {
        
        if (_hudView.topBarView.state == RRViewStateHidden) {
            [_hudView.topBarView transitToState:RRViewStateVisible animated:YES];
        } else {
            [_hudView.topBarView transitToState:RRViewStateHidden animated:YES];
            [self delegateDismissAllPopups];
        }
    }

    /*
    if (!_previewMode && _revision.verticalTocLoaded && _revision.horizontalTocLoaded) {
        
        if (_hudView.bottomTocView != nil) {
            if (_hudView.bottomTocView.state == RRViewStateVisible) {
                [_hudView.bottomTocView transitToState:RRViewStateHidden animated:YES];
                [_hudView.topBarView transitToState:RRViewStateHidden animated:YES];
            } else {
                [_hudView.bottomTocView transitToState:RRViewStateVisible animated:YES];
                [_hudView.topBarView transitToState:RRViewStateVisible animated:YES];
            }
        }
    } else {
        
        if (_hudView.topBarView.state == RRViewStateHidden) {
            [_hudView.topBarView transitToState:RRViewStateVisible animated:YES];
        } else {
            [_hudView.topBarView transitToState:RRViewStateHidden animated:YES];
        }
    }
    
    if (_hudView.summaryView != nil) {
        [_hudView hideSummaryAnimated:YES];
    }
    */
}
/*
- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self updateHud];
}
*/
#pragma mark - PCHudViewDataSource

- (CGSize)hudView:(PCHudView *)hudView itemSizeInToc:(PCGridView *)tocView
{
    if (tocView == hudView.topTocView.gridView) {
        return CGSizeMake(150, 384);
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
    
    PCTocItem *tocItem = nil;
    
    if (UIInterfaceOrientationIsLandscape(currentOrientation) &&
        [_revision supportsInterfaceOrientation:currentOrientation] &&
        _revision.horizontalMode) {
        tocItem = [_revision.validHorizontalTocItems objectAtIndex:index];
    } else {
        tocItem = [_revision.validVerticalTocItems objectAtIndex:index];
    }
    
    if (tocItem != nil) {
        [self delegateSelectedTocItem:tocItem];
    }
    
    if (_hudView.topTocView != nil && _hudView.topTocView.state == RRViewStateActive) {
        [_hudView.topTocView transitToState:RRViewStateVisible animated:YES];
    }
    
    if (_hudView.bottomTocView != nil && _hudView.bottomTocView.state == RRViewStateActive) {
        [_hudView.bottomTocView transitToState:RRViewStateVisible animated:YES];
    }
    
    [_hudView hideSummaryAnimated:YES];
}

#pragma mark - PCTopBarViewDelegate

- (void)topBarView:(PCTopBarView *)topBarView buttonTapped:(UIButton *)button
{
    if (button == topBarView.summaryButton) {
        if (_hudView.summaryView.hidden) {
            [_hudView showSummaryInView:_hudView.superview atPoint:button.center animated:YES];
        } else {
            [_hudView hideSummaryAnimated:YES];
        }
    }
    
    [self delegateTopBarView:topBarView buttonTapped:button];
}

#pragma mark - delegate methods

- (void)delegateDismissAllPopups
{
    if (_hudView.summaryView != nil && _hudView.summaryView.hidden == NO) {
        [_hudView hideSummaryAnimated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(hudControllerDismissAllPopups:)]) {
        [self.delegate hudControllerDismissAllPopups:self];
    }
}

- (void)delegateSelectedTocItem:(PCTocItem *)tocItem
{
    if ([self.delegate respondsToSelector:@selector(hudController:selectedTocItem:)]) {
        [self.delegate hudController:self selectedTocItem:tocItem];
    }
}

- (void)delegateTopBarView:(PCTopBarView *)topBarView buttonTapped:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(hudController:topBarView:buttonTapped:)]) {
        [self.delegate hudController:self topBarView:topBarView buttonTapped:button];
    }
}

@end
