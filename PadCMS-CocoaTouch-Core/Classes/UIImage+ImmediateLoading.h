//
//  UIImage+ImmediateLoading.h
//  SwapTest
//
//  Created by Julian Asamer on 3/11/11.
//  Code taken from https://gist.github.com/259357
//

#import <Foundation/Foundation.h>

@interface UIImage (UIImage_ImmediateLoading)

- (UIImage*) initImmediateLoadWithContentsOfFile:(NSString*)path;
+ (UIImage*)imageImmediateLoadWithContentsOfFile:(NSString*)path;

@end
