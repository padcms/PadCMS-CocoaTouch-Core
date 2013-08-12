//
//  UIImage+CombinedImage.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/31/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "UIImage+CombinedImage.h"

@implementation UIImage (CombinedImage)

+ (UIImage *)combinedImage:(UIImage *)baseImage overlayImage:(UIImage *)overlayImage color:(UIColor *)color
{
	UIGraphicsEndImageContext();
	UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, rect, baseImage.CGImage);
    
    if (color != nil) {
        [color set];
        CGContextFillRect(context, rect);
	}
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextDrawImage(context, rect, baseImage.CGImage);
	
	
	if (overlayImage != nil) {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
		CGContextDrawImage(context, rect, overlayImage.CGImage);
	}
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)recoloredImage:(UIImage *)baseImage color:(UIColor *)color
{
  UIGraphicsEndImageContext();
	UIGraphicsBeginImageContext(baseImage.size);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGRect rect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
  
  CGContextScaleCTM(context, 1, -1);
  CGContextTranslateCTM(context, 0, -rect.size.height);
  
  CGContextSaveGState(context);
  CGContextClipToMask(context, rect, baseImage.CGImage);
  CGContextSetBlendMode(context, kCGBlendModeMultiply);
  CGContextDrawImage(context, rect, baseImage.CGImage);
  
  if (color != nil) {
    [color set];
    CGContextFillRect(context, rect);
	}
  
  CGContextRestoreGState(context);
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return newImage;
}

@end
