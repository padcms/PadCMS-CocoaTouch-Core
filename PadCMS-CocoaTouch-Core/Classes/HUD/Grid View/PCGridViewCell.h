
#import <UIKit/UIKit.h>

@class PCGridViewIndex;

@interface PCGridViewCell : UIView

@property (retain, nonatomic) PCGridViewIndex *index;
@property (readonly, nonatomic) NSUInteger instanceIndex;

@end
