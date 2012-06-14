
#import <UIKit/UIKit.h>

@class PCResourceView;

@interface PCResourceLoadRequest : NSObject
{
@private // Instance variables

	NSString *_fileURL;
    
    NSString *_fileBadQualityURL;

	PCResourceView *_resourceView;

	NSUInteger _targetTag;
    
    CGFloat _scale;
}

@property (nonatomic, retain, readonly) NSString *fileURL;
@property (nonatomic, retain, readonly) NSString *fileBadQualityURL;
@property (nonatomic, retain, readonly) PCResourceView *resourceView;
@property (nonatomic, assign, readonly) NSUInteger targetTag;
@property (nonatomic, assign, readwrite) CGFloat scale;

+ (id)forView:(PCResourceView *)view fileURL:(NSString *)url fileBadQualityURL:(NSString *)urlbq;

- (id)initWithView:(PCResourceView *)view fileURL:(NSString *)url fileBadQualityURL:(NSString *)urlbq;

@end
