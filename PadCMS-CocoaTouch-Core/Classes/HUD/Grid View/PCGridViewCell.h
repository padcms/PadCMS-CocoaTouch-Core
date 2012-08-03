
#import <UIKit/UIKit.h>

@class PCGridViewIndex;

@interface PCGridViewCell : UIView

@property (retain, nonatomic) PCGridViewIndex *index;

+ (NSUInteger)instanceCount;

@end
