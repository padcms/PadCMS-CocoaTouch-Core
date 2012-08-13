//
//  PCStyler.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.02.12.
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

#import "PCStyler.h"
#import "PCConfig.h"
#import "PCCustomPageControll.h"

NSString * PCButtonImagesKey                    = @"PCButtonImages";
NSString * PCButtonImageNormalKey               = @"PCButtonImageNormal";
NSString * PCButtonImageSelectedKey             = @"PCButtonImageSelected";

NSString * PCButtonTintColorOptionKey           = @"PCButtonTintColor";

NSString * PCButtonBackgroundUseColorTintKey    = @"PCButtonBackgroundUseColorTint";
NSString * PCButtonBackgroundImageNameKey       = @"PCButtonBackgroundImageName";
NSString * PCButtonForegroundImageNameKey       = @"PCButtonForegroundImageName";
NSString * PCSizeKey                            = @"PCSize";
NSString * PCSizeHeightKey                      = @"PCSizeHeight";
NSString * PCSizeWidthKey                       = @"PCSizeWidth"; 
NSString * PCButtonBackgroundStretchableKey     = @"PCButtonBackgroundStretchable"; 
NSString * PCLeftCapWidth                       = @"PCLeftCapWidth";
NSString * PCTopCapHeight                       = @"PCTopCapHeight";
NSString * PCButtonMarginKey                    = @"PCButtonMargin";
NSString * PCButtonMarginXKey                   = @"PCButtonMarginX";
NSString * PCButtonMarginYKey                   = @"PCButtonMarginY";
NSString * PCButtonPositionKey                  = @"PCButtonPosition";
NSString * PCButtonPositionTopRightCornerKey    = @"PCButtonPositionTopRightCorner";
NSString * PCButtonPositionBottomRightCornerKey = @"PCButtonPositionBottomRightCorner";
NSString * PCButtonParentViewFrameKey           = @"PCButtonParentViewFrame";

@implementation PCStyler

-(void)dealloc
{
    [styleSheet release];
    styleSheet = nil;
    [super dealloc];
}

+(PCStyler*)defaultStyler
{
    static PCStyler* defaultStyler = nil;
    if (defaultStyler == nil)
    {
        defaultStyler = [[PCStyler alloc] initWithDictionary:[PCConfig defaultStyleSheet]]; 
    }
    return defaultStyler;
}

+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor overlay:(UIImage*) overlayImage
{
	UIGraphicsEndImageContext();
	UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    
    if (theColor)
    {
        [theColor set];
        CGContextFillRect(ctx, area);
	}
    
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, baseImage.CGImage);
	
	
	if (overlayImage != nil) 
    {
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
		CGContextDrawImage(ctx, area, overlayImage.CGImage);
	}
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(id)initWithDictionary:(NSDictionary*)aStyleSheet
{
    if (self = [super init]) 
    {
        styleSheet = [aStyleSheet retain];
    }
    return self;
}

-(void)stylizeElement:(id)aElement withStyleName:(NSString*)styleName withOptions:(NSDictionary*)styleOption
{
    if ([styleSheet objectForKey:styleName])
    {
        NSDictionary* elementStyle = [styleSheet objectForKey:styleName];
        if ([aElement respondsToSelector:@selector(setImage:forState:)])
        {
            if ([elementStyle objectForKey:PCButtonImagesKey])
            {
                NSDictionary* buttonsImages = [elementStyle objectForKey:PCButtonImagesKey];
                for (NSString* key in [buttonsImages allKeys])
                {
                    NSDictionary* imageOption = [buttonsImages objectForKey:key];
                    NSString* imageBackgroundName = nil;
                    NSString* imageForegroundName = nil;
                    
                    BOOL isUseTintColor = NO;
                    
                    if ([imageOption objectForKey:PCButtonBackgroundUseColorTintKey])
                        isUseTintColor = [[imageOption objectForKey:PCButtonBackgroundUseColorTintKey] boolValue];
                    
                    if ([imageOption objectForKey:PCButtonBackgroundImageNameKey])
                        imageBackgroundName = [imageOption objectForKey:PCButtonBackgroundImageNameKey];

                    if ([imageOption objectForKey:PCButtonForegroundImageNameKey])
                        imageForegroundName = [imageOption objectForKey:PCButtonForegroundImageNameKey];

                    UIControlState state = UIControlStateNormal;
                    
                    if ([key isEqualToString:PCButtonImageNormalKey])
                        state = UIControlStateNormal;
                    
                    if ([key isEqualToString:PCButtonImageSelectedKey])
                        state = UIControlStateSelected;
                    
                    UIImage* imageBackground = nil;
                    UIImage* imageForeground = nil;
                    
                    if (imageBackgroundName != nil)
                        imageBackground = [UIImage imageNamed:imageBackgroundName];
                    
                    if (imageForegroundName != nil)
                        imageForeground = [UIImage imageNamed:imageForegroundName];
                    
                    UIImage* buttonImage = nil;
                    
                    if (isUseTintColor && styleOption && [styleOption objectForKey:PCButtonTintColorOptionKey])
                    {
                        buttonImage = [PCStyler colorizeImage:imageBackground color:[styleOption objectForKey:PCButtonTintColorOptionKey] overlay:imageForeground];
                    }
                    else
                    {
                        buttonImage = [PCStyler colorizeImage:imageBackground color:nil overlay:imageForeground];
                    }
                    
                    if ([imageOption objectForKey:PCButtonBackgroundStretchableKey]&&[imageOption objectForKey:PCTopCapHeight]&&[imageOption objectForKey:PCLeftCapWidth])
                    {
                        CGFloat leftCapWidth = [[imageOption objectForKey:PCLeftCapWidth] floatValue];
                        CGFloat topCapHeight = [[imageOption objectForKey:PCTopCapHeight] floatValue];
                        buttonImage = [buttonImage stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
                    }
                    
                    if ([imageOption objectForKey:PCButtonMarginKey])
                    {
                        NSDictionary* marginOption = [imageOption objectForKey:PCButtonMarginKey];
                        if ([aElement respondsToSelector:@selector(setFrame:)])
                        {
                            CGFloat marginX = 0;
                            CGFloat marginY = 0;
                            if ([marginOption objectForKey:PCButtonMarginXKey])
                            {
                                marginX = [[marginOption objectForKey:PCButtonMarginXKey] floatValue];
                            }
                            if ([marginOption objectForKey:PCButtonMarginYKey])
                            {
                                marginY = [[marginOption objectForKey:PCButtonMarginYKey] floatValue];
                            }
                            CGRect frame = [aElement frame];
                            frame = CGRectMake(frame.origin.x + marginX, frame.origin.y + marginY, frame.size.width, frame.size.height);
                            if ([imageOption objectForKey:PCButtonPositionKey])
                            {
                                if ([styleOption objectForKey:PCButtonParentViewFrameKey])
                                {
                                    CGRect parentFrame = [[styleOption objectForKey:PCButtonParentViewFrameKey] CGRectValue];
                                    NSString *position = [imageOption objectForKey:PCButtonPositionKey];
                                    if ([position isEqualToString:PCButtonPositionTopRightCornerKey])
                                    {
                                        frame = CGRectMake(parentFrame.size.width - (marginX + frame.size.width), marginY, frame.size.width, frame.size.height);
                                    }
									else if ([position isEqualToString:PCButtonPositionBottomRightCornerKey]) {
										 frame = CGRectMake(parentFrame.size.width - (marginX + frame.size.width), parentFrame.size.height - (marginY + frame.size.height),  frame.size.width, frame.size.height);
									}
                                }
                            }
                            [aElement setFrame:frame]; 
                        }
                    }
                    
                    if (buttonImage)
                    {
                        [(UIButton*)aElement setImage:buttonImage forState:state];
                        
                        if ([aElement respondsToSelector:@selector(frame)]&&[aElement isKindOfClass:[UIButton class]])
                        {
                            CGRect frame = [aElement frame];
                            frame.size.width = buttonImage.size.width;
                            frame.size.height = buttonImage.size.height;
                            if ([aElement respondsToSelector:@selector(setFrame:)])
                            {
                                [aElement setFrame:frame]; 
                            }
                        }
                    }
                }
            }
        }
        
        if ([elementStyle objectForKey:PCSizeKey]&&[[elementStyle objectForKey:PCSizeKey] objectForKey:PCSizeWidthKey]&&[[elementStyle objectForKey:PCSizeKey] objectForKey:PCSizeHeightKey])
        {
            CGFloat width = [[[elementStyle objectForKey:PCSizeKey] objectForKey:PCSizeWidthKey] floatValue];
            CGFloat height = [[[elementStyle objectForKey:PCSizeKey] objectForKey:PCSizeHeightKey] floatValue];
            
            if ([aElement respondsToSelector:@selector(setDotSize:)])
            {
                [aElement setDotSize: CGSizeMake(width, height)];
            }
            
            else if ([aElement respondsToSelector:@selector(frame)])
            {
                CGRect frame = [aElement frame];
                frame.size.width = width;
                frame.size.height = height;
                if ([aElement respondsToSelector:@selector(setFrame:)])
                {
                    [aElement setFrame:frame]; 
                }
            }
        }
    }
}

+(float)getVerticalMiniArticleScrollerOffset
{
  NSNumber* offset = [[PCConfig defaultStyleSheet] objectForKey:@"PCVerticalMiniArticleScrollerOffset"];
  if (offset)
  {
    return [offset floatValue];
  }
  return 0;
}


@end
