//
//  PCKioskGalleryItem.m
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

#import <QuartzCore/QuartzCore.h>
#import "PCKioskGalleryItem.h"

@interface PCKioskGalleryItem()
-(void) assignCoverImage:(UIImage*) coverImage;
@end

@implementation PCKioskGalleryItem

@synthesize drawReflection = _drawReflection;
@synthesize dataSource = _dataSource;
@synthesize revisionIndex = _revisionIndex;

@synthesize angle, image;

-(void) dealloc {
	self.image = nil;
	
	[super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _drawReflection = YES;
    }
    return self;
}

- (void)animationDidStop:(CABasicAnimation*)animation finished:(BOOL)flag {
	NSString* animtype = [animation valueForKey:@"animtype"];

	BOOL start    = FALSE;
	id   delegate = nil;
	if ([animtype isEqualToString:@"center"]) {
		self.angle = RADIANS(180.0);
		start = TRUE;

	} else if ([animtype isEqualToString:@"back"]) {
		self.angle = RADIANS(0.0);
		delegate   = self;
		start = TRUE;
	}
	
	if (start) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
		CATransform3D transform = CATransform3DRotate(self.transform, self.angle, 0.0, 1.0, 0.0);
		
		animation.toValue   = [NSValue valueWithCATransform3D:transform];
		animation.duration  = DURATION_ROTATE;
		animation.fillMode  = kCAFillModeForwards;
		animation.removedOnCompletion = NO;
		animation.delegate  = delegate;
		animation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		
		[self addAnimation:animation forKey:@""];
	} else {
		[self removeAllAnimations];
		 
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:kCATransactionAnimationDuration];
			self.transform = [animation.toValue CATransform3DValue];
		[CATransaction commit];
	}
}

- (void)drawInContext:(CGContextRef)theContext {
	CGRect rect = self.bounds;
	
	// Draw image
	CGContextSaveGState(theContext);
	
    CGContextTranslateCTM(theContext, 0, rect.size.height);
    CGContextScaleCTM(theContext, 1.0, -1.0);
	
	UIImage     *img = self.image ? self.image : [self.dataSource revisionCoverImageWithIndex:self.revisionIndex andDelegate:self];

    if(img)
    {
        if(img!=self.image)     // process only once
        {
            [self assignCoverImage:img];
            img = self.image;
        }
        rect.origin.y    = rect.size.height - IMAGE_HEIGHT - 10;
        rect.size.height = IMAGE_HEIGHT;
        
//        rect.origin.y    = re;
//        rect.size.height = img.size.height;
//        rect = CGRectMake(0, rect.size.height - IMAGE_HEIGHT, img.size.width, img.size.height);
        
        CGContextDrawImage(theContext, rect, img.CGImage);
    }
	
    CGContextRestoreGState(theContext); 
	
	// Draw reflection
    if (_drawReflection)
    {
        CGGradientRef glossGradient;
        CGColorSpaceRef rgbColorspace;
        
        rect.origin.y = IMAGE_HEIGHT + 10;
        CGContextDrawImage(theContext, rect, img.CGImage);
        
        size_t num_locations = 2;
        CGFloat locations[2] = { 0.0, 1.0 };
        CGFloat components[8] = { 0.0, 0.0, 0.0, 0.50,  // Start color
            0.0, 0.0, 0.0, 1.00 }; // End color
        
        rgbColorspace = CGColorSpaceCreateDeviceRGB();
        glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
        
        CGPoint topCenter = CGPointMake(self.bounds.size.width / 2, IMAGE_HEIGHT + 10);
        CGPoint midCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
        CGContextDrawLinearGradient(theContext, glossGradient, topCenter, midCenter, 0);
        
        CGGradientRelease(glossGradient);
        
        CGColorSpaceRelease(rgbColorspace);		
    }
}

- (void)setDrawReflection:(BOOL)drawReflection
{
    if (_drawReflection != drawReflection) {
        _drawReflection = drawReflection;
        [self setNeedsDisplay];
    }
}

#pragma mark PCKioskCoverImageProcessingProtocol


-(void) updateCoverImage:(UIImage*) coverImage
{
    [self assignCoverImage:coverImage];
    [self setNeedsDisplay];
}

-(void) downloadingCoverImageFailed
{
    
}

-(void) assignCoverImage:(UIImage*) coverImage
{
    if(coverImage)
    {
        CGFloat         srcWidth = coverImage.size.width,
                        srcHeight = coverImage.size.height;
        
        CGFloat         scale = ((float)(IMAGE_WIDTH)) / srcWidth;
        
        CGFloat         newWidth = srcWidth * scale,
                        newHeight = srcHeight * scale;
        
        CGFloat         marginLeft = 0.0, marginTop = 0.0;
        
        if(newHeight > IMAGE_HEIGHT)    // height is bigger
        {
            scale = ((float)(IMAGE_HEIGHT)) / srcHeight;
            newWidth = srcWidth * scale;
            newHeight = srcHeight * scale;
            marginLeft = (IMAGE_WIDTH - newHeight) / 2;
        } else if(newHeight < IMAGE_HEIGHT)
                {
                    marginTop = IMAGE_HEIGHT - newHeight;
                }
        
        /*
        CGRect      rect = self.bounds;
            
        CGFloat scale = ((float)(IMAGE_WIDTH)) / coverImage.size.width;
        CGSize newSize = CGSizeMake(coverImage.size.width * scale, coverImage.size.height * scale);
        rect = CGRectMake(0, 0, newSize.width, newSize.height*5/3);
        self.bounds = rect;
        */
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmapContext = CGBitmapContextCreate(NULL, IMAGE_WIDTH, IMAGE_HEIGHT, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        
        CGRect     imageRect = CGRectMake(marginLeft, 0, newWidth, newHeight);

        // fill with white color image area
        CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
        CGContextFillRect(bitmapContext, imageRect);
        
        // draw image
        CGContextDrawImage(bitmapContext, imageRect, coverImage.CGImage);
        
        CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(bitmapContext);
        UIImage *result = [UIImage imageWithCGImage:mainViewContentBitmapContext];
        CGImageRelease(mainViewContentBitmapContext);
        CGContextRelease(bitmapContext);
        
        //////////////////
        /*
         NSLog(@"IMG: %.0f x %.0f", result.size.width, result.size.height);
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *path = nil;
        if ([paths count] > 0) {
            NSString * libPath = [paths objectAtIndex:0];
            path = [libPath stringByAppendingPathComponent:[NSString stringWithFormat:@"fc%d.png", self.revisionIndex]];
        }
        if(path)
        {
            [UIImagePNGRepresentation(result) writeToFile:path atomically:YES];
        }
        */
        //////////////////
        self.image = nil;
        self.image = result;
        
    } else {
        self.image = nil;
        self.image = coverImage;
    }
}

@end
