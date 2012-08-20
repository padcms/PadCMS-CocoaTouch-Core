//
//  PCTocViewTest.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/30/12.
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
    GHAssertEquals(_givenFrame, _topTocView.frame, nil);
    
    CGRect tocFrame = _topTocView.frame;
    CGRect buttonFrame = _topTocView.button.frame;
    CGRect gridViewFrame = _topTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, nil);
    GHAssertEquals(gridViewFrame.origin, tocFrame.origin, nil);
    GHAssertEquals(buttonFrame.origin.y, gridViewFrame.size.height, nil);
}

- (void)testTopTocViewResizing
{
    _topTocView.frame = CGRectMake(0, 0, 1000, 1300);
    
    CGRect tocFrame = _topTocView.frame;
    CGRect buttonFrame = _topTocView.button.frame;
    CGRect gridViewFrame = _topTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, nil);
    GHAssertEquals(gridViewFrame.origin, tocFrame.origin, nil);
    GHAssertEquals(gridViewFrame.size.width, tocFrame.size.width, nil);
    GHAssertEquals(buttonFrame.origin.y, gridViewFrame.size.height, nil);
}

- (void)testTopTocViewStates
{
    /*
     Contract:
     1. PCTocView object just initialized should have PCTocViewStateInvalid state;
     2. Top toc view object in PCTocViewStateHidden state should be arranged above the upper edge of the container view;
     3. Top toc view object in PCTocViewStateVisible state should be arranged with gridView above the upper edge of the container view and button below it;
     4. Top toc view object in PCTocViewStateActive state should be fully visible. Top edge of the top toc view should be equal top edge of view containing it.
     */
    
    CGRect topTocViewFrame = CGRectMake(0, 0, 1000, 1300);
    
    _topTocView.frame = topTocViewFrame;
    
    GHAssertEquals(topTocViewFrame, _topTocView.frame, nil);
    GHAssertEquals(_topTocView.state, PCTocViewStateInvalid, nil);
    
    CGRect containerFrame = CGRectMake(0, 0, 1000, 5000);

    CGPoint hiddenStateCenter = CGPointMake(topTocViewFrame.size.width / 2,
                                            -(topTocViewFrame.size.height / 2));
    GHAssertEquals([_topTocView centerForState:PCTocViewStateHidden containerBounds:containerFrame], hiddenStateCenter, nil);

    CGPoint visibleStateCenter = CGPointMake(topTocViewFrame.size.width / 2,
                                             -(topTocViewFrame.size.height / 2) + _topTocView.button.frame.size.height);
    GHAssertEquals([_topTocView centerForState:PCTocViewStateVisible containerBounds:containerFrame], visibleStateCenter, nil);
    
    CGPoint activeStateCenter = CGPointMake(topTocViewFrame.size.width / 2,
                                            topTocViewFrame.size.height / 2);
    GHAssertEquals([_topTocView centerForState:PCTocViewStateActive containerBounds:containerFrame], activeStateCenter, nil);
}

#pragma mark - Bottom toc view tests

- (void)testBottomTocViewInitialLayout
{
    GHAssertEquals(_givenFrame, _bottomTocView.frame, nil);
    
    CGRect tocFrame = _bottomTocView.frame;
    CGRect buttonFrame = _bottomTocView.button.frame;
    CGRect gridViewFrame = _bottomTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, nil);
    GHAssertEquals(buttonFrame.origin, tocFrame.origin, nil);
    GHAssertEquals(gridViewFrame.origin.y, buttonFrame.size.height, nil);
}

- (void)testBottomTocViewResizing
{
    _bottomTocView.frame = CGRectMake(0, 0, 1000, 1300);
    
    CGRect tocFrame = _bottomTocView.frame;
    CGRect buttonFrame = _bottomTocView.button.frame;
    CGRect gridViewFrame = _bottomTocView.gridView.frame;
    
    GHAssertEquals(tocFrame.size.height, buttonFrame.size.height + gridViewFrame.size.height, nil);
    GHAssertEquals(buttonFrame.origin, tocFrame.origin, nil);
    GHAssertEquals(gridViewFrame.size.width, tocFrame.size.width, nil);
    GHAssertEquals(gridViewFrame.origin.y, buttonFrame.size.height, nil);
}

- (void)testBottomTocViewStates
{
    /*
     Contract:
     1. PCTocView object just initialized should have PCTocViewStateInvalid state;
     2. Bottom toc view object in PCTocViewStateHidden state should be arranged below the bottom edge of the container view;
     3. Bottom toc view object in PCTocViewStateVisible state should be arranged with gridView below the bottom edge of the container view and button above it;
     4. Bottom toc view object in PCTocViewStateActive state should be fully visible. Bottom edge of the bottom toc view should be equal bottom edge of view containing it.
     */
    
    CGRect bottomTocViewFrame = CGRectMake(0, 0, 1000, 1300);
    
    _bottomTocView.frame = bottomTocViewFrame;
    
    GHAssertEquals(bottomTocViewFrame, _bottomTocView.frame, nil);
    GHAssertEquals(_bottomTocView.state, PCTocViewStateInvalid, nil);
    
    CGRect containerFrame = CGRectMake(0, 0, 1000, 5000);

    CGPoint hiddenStateCenter = CGPointMake(bottomTocViewFrame.size.width / 2,
                                            containerFrame.size.height + (bottomTocViewFrame.size.height / 2));
    GHAssertEquals([_bottomTocView centerForState:PCTocViewStateHidden containerBounds:containerFrame], hiddenStateCenter, nil);
    
    CGPoint visibleStateCenter = CGPointMake(bottomTocViewFrame.size.width / 2,
                                            containerFrame.size.height + (bottomTocViewFrame.size.height / 2) - _bottomTocView.button.frame.size.height);
    GHAssertEquals([_bottomTocView centerForState:PCTocViewStateVisible containerBounds:containerFrame], visibleStateCenter, nil);
    
    CGPoint activeStateCenter = CGPointMake(bottomTocViewFrame.size.width / 2,
                                            containerFrame.size.height - (bottomTocViewFrame.size.height / 2));
    GHAssertEquals([_bottomTocView centerForState:PCTocViewStateActive containerBounds:containerFrame], activeStateCenter, nil);
}

@end
