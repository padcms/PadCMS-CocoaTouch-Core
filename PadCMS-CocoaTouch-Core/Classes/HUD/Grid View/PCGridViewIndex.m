
#import "PCGridViewIndex.h"

@implementation PCGridViewIndex
@synthesize row = _row;
@synthesize column = _column;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ row = %u column = %u", [super description], _row, _column];
}

@end
