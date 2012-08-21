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

- (void)updateHud;

@end

@implementation RRHudController
@synthesize revision = _revision;
@synthesize previewMode = _previewMode;
@synthesize hudView = _hudView;

- (id)init
{
    self = [super init];
    if (self != nil) {
        _revision = nil;
        _previewMode = NO;
        _hudView = [[PCHudView alloc] init];
        _hudView.backgroundColor = [UIColor orangeColor];
//        _hudView.dataSource = self;
//        _hudView.delegate = self;
        _hudView.topBarView.delegate = self;
    }
    return self;
}

#pragma mark - private methods

- (void)updateHud
{
    if (_revision == nil) {
        return;
    }
}

- (void)tocDownloaded:(NSNotification *)notification
{
    [self updateHud];
}

#pragma mark - public methods

- (void)update
{
    [self updateHud];
}

- (void)handleTap
{
    if (_revision == nil) {
        return;
    }
    
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
}

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self updateHud];
}

#pragma mark - PCHudViewDataSource

- (CGSize)hudView:(PCHudView *)hudView itemSizeInToc:(PCGridView *)tocView
{
    return CGSizeZero;
}

- (UIImage *)hudView:(PCHudView *)hudView summaryImageForIndex:(NSUInteger)index
{
    return nil;
}

- (NSString *)hudView:(PCHudView *)hudView summaryTextForIndex:(NSUInteger)index
{
    return nil;
}


- (UIImage *)hudView:(PCHudView *)hudView tocImageForIndex:(NSUInteger)index
{
    return nil;
}

- (NSUInteger)hudViewTocItemsCount:(PCHudView *)hudView
{
    return 0;
}

#pragma mark - PCHudViewDelegate

- (void)hudView:(PCHudView *)hudView didSelectIndex:(NSUInteger)index
{
}

#pragma mark - PCTopBarViewDelegate

- (void)topBarView:(PCTopBarView *)topBarView summaryButtonTapped:(UIButton *)button
{
    if (_hudView.summaryView.hidden) {
        [_hudView showSummaryInView:_hudView.superview atPoint:button.center animated:YES];
    } else {
        [_hudView hideSummaryAnimated:YES];
    }
}

@end
