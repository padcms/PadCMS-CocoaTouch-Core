
#import <UIKit/UIKit.h>

@interface PCResourceView : UIView
{
@private // Instance variables

	NSUInteger _targetTag;

	NSOperation *_operation;

@protected // Instance variables

	UIImageView *imageView;
    
    BOOL loaded;
}

@property (assign, readwrite) NSOperation *operation;

@property (nonatomic, assign, readwrite) NSUInteger targetTag;

- (void)showImage:(UIImage *)image;

- (void)showTouched:(BOOL)touched;

- (void)reuse;

- (BOOL)isLoaded;

@end
