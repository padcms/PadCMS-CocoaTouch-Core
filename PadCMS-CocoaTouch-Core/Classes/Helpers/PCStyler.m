//
//  PCStyler.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCStyler.h"
#import "PCConfig.h"

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
                            CGFloat marginX = [[marginOption objectForKey:PCButtonMarginXKey] floatValue];
                            CGFloat marginY = [[marginOption objectForKey:PCButtonMarginYKey] floatValue];
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
                                        frame = CGRectMake(parentFrame.size.width - (marginX + frame.size.width), frame.origin.y + marginY, frame.size.width, frame.size.height);
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

            if ([aElement respondsToSelector:@selector(frame)])
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
