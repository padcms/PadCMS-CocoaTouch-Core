
#import "PCResourceView.h"

@implementation PCResourceView

#pragma mark Properties

@synthesize operation = _operation;
@synthesize targetTag = _targetTag;

#pragma mark PCResourceView instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.backgroundColor = [UIColor clearColor];

		imageView = [[UIImageView alloc] initWithFrame:self.bounds];

		imageView.autoresizesSubviews = NO;
		imageView.userInteractionEnabled = NO;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.autoresizingMask = UIViewAutoresizingNone;
		imageView.backgroundColor = [UIColor clearColor];

		[self addSubview:imageView];
        
        loaded = NO;
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[imageView release], imageView = nil;

	[super dealloc];
}

- (void)showImage:(UIImage *)image
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	imageView.image = image; // Show image
    [imageView setFrame:CGRectMake(0, 0, imageView.frame.size.width, image.size.height*imageView.frame.size.width/image.size.width)];

    if(image != nil)
    {
        loaded = YES;
    }
}

- (void)showTouched:(BOOL)touched
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
}

- (void)removeFromSuperview
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	_targetTag = 0; // Clear target tag

	[self.operation cancel], self.operation = nil;

	[super removeFromSuperview];
}

- (void)reuse
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	_targetTag = 0; // Clear target tag

	[self.operation cancel], self.operation = nil;

	imageView.image = nil; // Release image
    
    loaded = NO;
}

- (BOOL)isLoaded
{
    return loaded;
}

@end
