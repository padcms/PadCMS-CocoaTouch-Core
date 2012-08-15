//
//  PCShareViewTest.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 8/15/12.
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
#import "OCMock.h"
#import "PCShareView.h"

@interface PCShareViewTest : GHTestCase
{
    PCShareView *_shareView;
    id _shareViewDelegateMock;
}

@end


@implementation PCShareViewTest

- (void)setUp
{
    [super setUp];
    
    _shareView = [[PCShareView alloc] init];
    _shareViewDelegateMock = [[OCMockObject mockForProtocol:@protocol(PCShareViewDelegate)] retain];
    _shareView.delegate = _shareViewDelegateMock;
}

- (void)tearDown
{
    [super tearDown];
    
    [_shareView release];
    [_shareViewDelegateMock release];
}

- (void)testPresenting
{
    /*
     Contract:
     1. Share view @property presented should be NO by-default;
     2. Share view @property presented should be NO if it was presented in a nil view;
     3. Share view @property presented should be YES if it was presented in a non nil view;
     4. Share view @property presented should be NO if it was dismissed.
     */
    
    GHAssertEquals(_shareView.presented, NO, nil);
    
    [_shareView presentInView:nil atPoint:CGPointZero];
    GHAssertEquals(_shareView.presented, NO, nil);
    
    UIView *containerView = [[[UIView alloc] init] autorelease];
    [_shareView presentInView:containerView atPoint:CGPointZero];
    GHAssertEquals(_shareView.presented, YES, nil);
    
    [_shareView dismiss];
    GHAssertEquals(_shareView.presented, NO, nil);
}

- (void)testActions
{
    /*
     Contract:
     1. Share view should invoke delegate methods when one of the sharing buttons touched.
     */
    
    NSArray *facebookActions = [_shareView.facebookButton actionsForTarget:_shareView forControlEvent:UIControlEventTouchUpInside];
    
    GHAssertNotNil(facebookActions, nil);
    
    SEL facebookAction = NSSelectorFromString([facebookActions objectAtIndex:0]);
    [[_shareViewDelegateMock expect] shareViewFacebookShare:OCMOCK_ANY];
    [_shareView performSelector:facebookAction];
    [_shareViewDelegateMock verify];


    NSArray *twitterActions = [_shareView.twitterButton actionsForTarget:_shareView forControlEvent:UIControlEventTouchUpInside];
    
    GHAssertNotNil(twitterActions, nil);
    
    SEL twitterAction = NSSelectorFromString([twitterActions objectAtIndex:0]);
    [[_shareViewDelegateMock expect] shareViewTwitterShare:OCMOCK_ANY];
    [_shareView performSelector:twitterAction];
    [_shareViewDelegateMock verify];

    NSArray *emailActions = [_shareView.emailButton actionsForTarget:_shareView forControlEvent:UIControlEventTouchUpInside];
    
    GHAssertNotNil(emailActions, nil);
    
    SEL emailAction = NSSelectorFromString([emailActions objectAtIndex:0]);
    [[_shareViewDelegateMock expect] shareViewEmailShare:OCMOCK_ANY];
    [_shareView performSelector:emailAction];
    [_shareViewDelegateMock verify];
}

@end