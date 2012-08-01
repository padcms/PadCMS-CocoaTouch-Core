
#import "PCGridViewCell.h"

#import "PCGridViewIndex.h"

static NSUInteger GridViewCellInstanceCount = 0;

@interface PCGridViewCell ()
{
    NSUInteger _instanceIndex;
}

@end

@implementation PCGridViewCell
@synthesize index = _index;
@synthesize instanceIndex = _instanceIndex;

- (void)dealloc
{
    --GridViewCellInstanceCount;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GridViewCellInstanceCountChanged" 
                                                        object:[NSNumber numberWithUnsignedInteger:GridViewCellInstanceCount]];

    [_index release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        _instanceIndex = GridViewCellInstanceCount;
        ++GridViewCellInstanceCount;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"GridViewCellInstanceCountChanged" 
                                                            object:[NSNumber numberWithUnsignedInteger:GridViewCellInstanceCount]];
        
        _index = nil;
    }

    return self;
}

@end
