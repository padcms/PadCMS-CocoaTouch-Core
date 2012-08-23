//
//  PCHudController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 8/21/12.
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

#import "PCHudController.h"

#import "PCGridView.h"
#import "PCResourceCache.h"
#import "PCRevision.h"
#import "PCSummaryView.h"
#import "PCTocItem.h"
#import "PCTopBarView.h"

#define VerticalTocDownloadedNotification @"endOfDownloadingTocNotification"
#define HorizontalTocDownloadedNotification @"PCHorizontalTocDidDownloadNotification"

@interface PCHudController ()
{
    PCRevision *_revision;
    BOOL _previewMode;
    PCHudView *_hudView;
}

- (void)tocDownloaded:(NSNotification *)notification;

- (void)delegateDismissAllPopups;
- (void)delegateSelectedTocItem:(PCTocItem *)tocItem;
- (void)delegateTopBarView:(PCTopBarView *)topBarView buttonTapped:(UIButton *)button;
- (void)delegateTopBarView:(PCTopBarView *)topBarView searchText:(NSString *)searchText;

@end

@implementation PCHudController
@synthesize delegate;
@synthesize revision = _revision;
@synthesize previewMode = _previewMode;
@synthesize hudView = _hudView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VerticalTocDownloadedNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HorizontalTocDownloadedNotification
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
                                                     name:VerticalTocDownloadedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tocDownloaded:)
                                                     name:HorizontalTocDownloadedNotification
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
            [_hudView.topTocView transitToState:PCViewStateHidden animated:NO];
            [_hudView.topBarView transitToState:PCViewStateHidden animated:NO];
        } else {
            [_hudView.topTocView transitToState:PCViewStateVisible animated:YES];
        }
    }
    
    if (!_previewMode && _revision.verticalTocLoaded && _revision.horizontalTocLoaded) {
        
        if (_hudView.bottomTocView != nil) {
            
            if (_hudView.topBarView.state == PCViewStateVisible) {
                [_hudView.bottomTocView transitToState:PCViewStateVisible animated:YES];
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
            [_hudView.bottomTocView transitToState:PCViewStateHidden animated:NO];
        }
        [_hudView.topBarView setSummaryButtonHidden:YES animated:NO];
    }
    
    [_hudView reloadData];
}

- (void)tap
{
    if (_revision == nil) {
        return;
    }
    
    if (_hudView.summaryView != nil) {
        [_hudView hideSummaryAnimated:YES];
    }
    
    if (_hudView.topTocView != nil) {
        
        if (_previewMode) {
            
            if (_hudView.topBarView.state == PCViewStateVisible) {
                [_hudView.topBarView transitToState:PCViewStateHidden animated:YES];
                [self delegateDismissAllPopups];
            } else {
                [_hudView.topBarView transitToState:PCViewStateVisible animated:YES];
            }
        } else {
            if (_hudView.bottomTocView.state == PCViewStateVisible) {
                [_hudView.topTocView transitToState:PCViewStateActive animated:YES];
            } else {
                [_hudView.topTocView transitToState:PCViewStateVisible animated:YES];
                [self delegateDismissAllPopups];
            }
        }
        
        return;
    }
    
    if (!_previewMode && _revision.verticalTocLoaded && _revision.horizontalTocLoaded) {
        
        if (_hudView.bottomTocView != nil) {
            if (_hudView.bottomTocView.state == PCViewStateVisible) {
                [_hudView.bottomTocView transitToState:PCViewStateHidden animated:YES];
                [_hudView.topBarView transitToState:PCViewStateHidden animated:YES];
                [self delegateDismissAllPopups];
            } else {
                [_hudView.bottomTocView transitToState:PCViewStateVisible animated:YES];
                [_hudView.topBarView transitToState:PCViewStateVisible animated:YES];
            }
        }
    } else {
        
        if (_hudView.topBarView.state == PCViewStateHidden) {
            [_hudView.topBarView transitToState:PCViewStateVisible animated:YES];
        } else {
            [_hudView.topBarView transitToState:PCViewStateHidden animated:YES];
            [self delegateDismissAllPopups];
        }
    }
}

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
    
    if (_hudView.topTocView != nil && _hudView.topTocView.state == PCViewStateActive) {
        [_hudView.topTocView transitToState:PCViewStateVisible animated:YES];
    }
    
    if (_hudView.bottomTocView != nil && _hudView.bottomTocView.state == PCViewStateActive) {
        [_hudView.bottomTocView transitToState:PCViewStateVisible animated:YES];
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

- (void)topBarView:(PCTopBarView *)topBarView searchText:(NSString *)searchText
{
    [self delegateTopBarView:topBarView searchText:searchText];
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

- (void)delegateTopBarView:(PCTopBarView *)topBarView searchText:(NSString *)searchText
{
    if ([self.delegate respondsToSelector:@selector(hudController:topBarView:searchText:)]) {
        [self.delegate hudController:self topBarView:topBarView searchText:searchText];
    }
    
    if (_hudView.topTocView != nil && _hudView.topTocView.state == PCViewStateActive) {
        [_hudView.topTocView transitToState:PCViewStateVisible animated:YES];
    }
}

@end
