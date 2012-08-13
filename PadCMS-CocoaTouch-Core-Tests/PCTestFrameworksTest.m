#import <GHUnitIOS/GHUnit.h>
#import "OCMock.h"

@interface PCTestFrameworksTest : GHTestCase

@end


@implementation PCTestFrameworksTest

- (void)testGHUnit
{
    GHAssertTrue(true, @"GHUnit Framework works wrong!");
}

- (void)testOCMock
{
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    
    NSString *returnValue = [mock lowercaseString];
    GHAssertEqualObjects(@"mocktest", returnValue, @"OCMock Framework works wrong!");
}

@end
