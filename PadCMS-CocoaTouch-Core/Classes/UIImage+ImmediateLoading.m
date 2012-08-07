//
//  UIImage+ImmediateLoading.m
//  SwapTest
//
//  Created by Julian Asamer on 3/11/11.
//  Code taken from https://gist.github.com/259357
//

#import "UIImage+ImmediateLoading.h"

@implementation UIImage (UIImage_ImmediateLoading)

+ (UIImage*)imageImmediateLoadWithContentsOfFile:(NSString*)path {
    return [[[UIImage alloc] initImmediateLoadWithContentsOfFile: path] autorelease];
}

- (UIImage*) initImmediateLoadWithContentsOfFile:(NSString*)path {
    UIImage *image = [UIImage imageWithContentsOfFile:path];
   /* CGImageRef imageRef = [image CGImage];
    CGRect rect = CGRectMake(0.f, 0.f, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       rect.size.width,
                                                       rect.size.height,
                                                       CGImageGetBitsPerComponent(imageRef),
                                                       CGImageGetBytesPerRow(imageRef),
                                                       CGImageGetColorSpace(imageRef),
                                                       kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
                                                       );
    //kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little are the bit flags required so that the main thread doesn't have any conversions to do.
    
    CGContextDrawImage(bitmapContext, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage* decompressedImage = [[UIImage alloc] initWithCGImage: decompressedImageRef];
    CGImageRelease(decompressedImageRef);
    CGContextRelease(bitmapContext);
    [image release];
    
    return decompressedImage;*/
	
	CGImageRef imageRef = image.CGImage;
    // System only supports RGB, set explicitly and prevent context error
    // if the downloaded image is not the supported format
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(imageRef),
                                                 CGImageGetHeight(imageRef),
                                                 8,
                                                 // width * 4 will be enough because are in ARGB format, don't read from the image
                                                 CGImageGetWidth(imageRef) * 4,
                                                 colorSpace,
                                                 // kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little 
                                                 // makes system don't need to do extra conversion when displayed.
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little); 
    CGColorSpaceRelease(colorSpace);
	
    if ( ! context) {
        return nil;
    }
    
    CGRect rect = (CGRect){CGPointZero, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)};
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef];
    CGImageRelease(decompressedImageRef);
	
    return [decompressedImage autorelease];
}

@end
