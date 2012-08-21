
#import <GHUnitIOS/GHUnit.h>
#import "OCMock.h"

#import "RevisionViewController.h"
#import "PCRevision.h"

@interface RRRevisionViewController_HudStatesTest : GHTestCase
{
    RevisionViewController *_revisionViewController;
    id _revisionMock;
}

@end


@implementation RRRevisionViewController_HudStatesTest

- (void)setUp
{
    _revisionMock = [OCMockObject mockForClass:NSObject.class];
    _revisionViewController = [[RevisionViewController alloc] initWithRevision:_revisionMock
                                                               withInitialPage:nil
                                                                   previewMode:NO];
}

- (void)tearDown
{
    [_revisionViewController release];
    [_revisionMock release];
}

@end