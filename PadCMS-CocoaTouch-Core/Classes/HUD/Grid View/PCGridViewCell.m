
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

- (void)dealloc
{
    --GridViewCellInstanceCount;
    
    [_index release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        _instanceIndex = GridViewCellInstanceCount;
        ++GridViewCellInstanceCount;

        _index = nil;
    }

    return self;
}

+ (NSUInteger)instanceCount
{
    return GridViewCellInstanceCount;
}

@end
