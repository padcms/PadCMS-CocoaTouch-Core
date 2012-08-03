//
//  PCTocViewTest.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/30/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import "PCTocView.h"
#import "PCGridView.h"

@interface PCTocViewTest : GHTestCase
{
    CGRect _givenFrame;
    PCTocView *_topTocView;
    PCTocView *_bottomTocView;
}
@end


@implementation PCTocViewTest

- (void)setUp
{
    _givenFrame = CGRectMake(0, 0, 500, 750);
    _topTocView = [[PCTocView topTocViewWithFrame:_givenFrame] retain];
    _bottomTocView = [[PCTocView bottomTocViewWithFrame:_givenFrame] retain];
}

- (void)tearDown
{
    [_topTocView release];
    [_bottomTocView release];
}

#pragma mark - Top toc view tests

- (void)testTopTocViewInitialLayout
{
    GHAssertEquals(_givenFrame, _topTocView.frame, @"");
    
    CGRect tocFrame = _topTocView.frame;
    CGRect buttonFrame = _topTocView.button.frame;
    CGRect gridViewFrame = _topTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, @"");
    GHAssertEquals(gridViewFrame.origin, tocFrame.origin, @"");
    GHAssertEquals(buttonFrame.origin.y, gridViewFrame.size.height, @"");
}

- (void)testTopTocViewResizing
{
    _topTocView.frame = CGRectMake(0, 0, 1000, 1300);
    
    CGRect tocFrame = _topTocView.frame;
    CGRect buttonFrame = _topTocView.button.frame;
    CGRect gridViewFrame = _topTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, @"");
    GHAssertEquals(gridViewFrame.origin, tocFrame.origin, @"");
    GHAssertEquals(gridViewFrame.size.width, tocFrame.size.width, @"");
    GHAssertEquals(buttonFrame.origin.y, gridViewFrame.size.height, @"");
}

- (void)testTopTocViewStates
{
    /*
     _topTocView.frame = CGRectMake(0, 0, 1000, 1300);
     
     CGRect tocViewFrame = _topTocView.frame;
     CGRect buttonFrame = _topTocView.button.frame;
     
     CGPoint hiddenStateCenter = CGPointMake(tocViewFrame.size.width / 2,
     -(tocViewFrame.size.height / 2));
     GHAssertEquals([_topTocView hiddenStateCenterForRect:CGRectZero], hiddenStateCenter, @"");
     
     CGPoint visibleStateCenter = CGPointMake(tocViewFrame.size.width / 2,
     (-tocViewFrame.size.height / 2) + (buttonFrame.size.height / 2));
     GHAssertEquals([_topTocView visibleStateCenterForRect:CGRectZero], visibleStateCenter, @"");
     
     CGPoint activeStateCenter = CGPointMake(tocViewFrame.size.width / 2,
     tocViewFrame.size.height / 2);
     GHAssertEquals([_topTocView activeStateCenterForRect:CGRectZero], activeStateCenter, @"");
     */
}

#pragma mark - Bottom toc view tests

- (void)testBottomTocViewInitialLayout
{
    GHAssertEquals(_givenFrame, _bottomTocView.frame, @"");
    
    CGRect tocFrame = _bottomTocView.frame;
    CGRect buttonFrame = _bottomTocView.button.frame;
    CGRect gridViewFrame = _bottomTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, @"");
    GHAssertEquals(buttonFrame.origin, tocFrame.origin, @"");
    GHAssertEquals(gridViewFrame.origin.y, buttonFrame.size.height, @"");
}

- (void)testBottomTocViewResizing
{
    _bottomTocView.frame = CGRectMake(0, 0, 1000, 1300);
    
    CGRect tocFrame = _bottomTocView.frame;
    CGRect buttonFrame = _bottomTocView.button.frame;
    CGRect gridViewFrame = _bottomTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, @"");
    GHAssertEquals(buttonFrame.origin, tocFrame.origin, @"");
    GHAssertEquals(gridViewFrame.size.width, tocFrame.size.width, @"");
    GHAssertEquals(gridViewFrame.origin.y, buttonFrame.size.height, @"");
}

- (void)testBottomTocViewStates
{
    /*
     _bottomTocView.frame = CGRectMake(0, 0, 1000, 1300);
     
     CGRect tocViewFrame = _bottomTocView.frame;
     CGRect buttonFrame = _bottomTocView.button.frame;
     CGRect containerFrame = CGRectMake(0, 0, 1000, 1700);
     
     CGPoint hiddenStateCenter = CGPointMake(tocViewFrame.size.width / 2,
     containerFrame.size.height + (tocViewFrame.size.height / 2));
     GHAssertEquals([_bottomTocView hiddenStateCenterForRect:containerFrame], hiddenStateCenter, @"");
     
     CGPoint visibleStateCenter = CGPointMake(tocViewFrame.size.width / 2,
     containerFrame.size.height + (tocViewFrame.size.height / 2) - (buttonFrame.size.height / 2));
     GHAssertEquals([_bottomTocView visibleStateCenterForRect:containerFrame], visibleStateCenter, @"");
     
     CGPoint activeStateCenter = CGPointMake(tocViewFrame.size.width / 2,
     containerFrame.size.height - tocViewFrame.size.height / 2);
     GHAssertEquals([_bottomTocView activeStateCenterForRect:containerFrame], activeStateCenter, @"");
     */
}

@end
