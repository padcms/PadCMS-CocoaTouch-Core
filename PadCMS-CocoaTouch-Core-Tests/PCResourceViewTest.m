#import <GHUnitIOS/GHUnit.h> 

#import "PCResourceView.h"

@interface PCResourceViewTest : GHTestCase
{
    PCResourceView *_resourceView;
}

@end

@implementation PCResourceViewTest

- (void)setUp
{
    _resourceView = [[PCResourceView alloc] init];
}

- (void)tearDown
{
    [_resourceView release];
    _resourceView = nil;
}

- (void)testResourceViewDidLoadBlock
{
    _resourceView.resourceViewDidLoadBlock = nil;
    GHAssertNil(_resourceView.resourceViewDidLoadBlock, nil);
    
    _resourceView.resourceViewDidLoadBlock = ^{
        // nothing
    };
    GHAssertNotNil(_resourceView.resourceViewDidLoadBlock, nil);
}

- (void)testNilResourceName
{
    _resourceView.resourceName = nil;
    GHAssertNil(_resourceView.image, @"PCResourceView should set image property to nil immediately after setting resourceName property to nil"); 
}

- (void)testEmptyResourceName
{
    _resourceView.resourceName = @"";
    GHAssertNil(_resourceView.image, @"PCResourceView should set image property to nil immediately after setting resourceName property to empty string"); 
}

- (void)testInvalidResourceName
{
    _resourceView.resourceName = @"invalid-resource.png";
    
    __block BOOL executionFinished = NO;
    _resourceView.resourceViewDidLoadBlock = ^{
        executionFinished = YES;
    };
    
    while (executionFinished == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        usleep(1000);
    }
    
    GHAssertNil(_resourceView.image, @"PCResourceView should not load image when resourceName does not refer to proper file"); 

}

- (void)testValidResourceName
{
    NSString *validFileName = [[NSBundle mainBundle] pathForResource:@"test-resource" 
                                                              ofType:@"png"];
    
    _resourceView.resourceName = validFileName;

    __block BOOL executionFinished = NO;
    _resourceView.resourceViewDidLoadBlock = ^{
        executionFinished = YES;
    };

    while (executionFinished == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        usleep(1000);
    }
    
    GHAssertNotNil(_resourceView.image, @"PCResourceView should load image when resourceName refers to proper file"); 
}

@end

