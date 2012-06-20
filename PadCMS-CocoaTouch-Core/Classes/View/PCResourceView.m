//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

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
