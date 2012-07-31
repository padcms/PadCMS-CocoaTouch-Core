//
//  UIImage+CombinedImage.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/31/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CombinedImage)

+ (UIImage *)combinedImage:(UIImage *)baseImage overlayImage:(UIImage *)overlayImage color:(UIColor *)color;

@end
