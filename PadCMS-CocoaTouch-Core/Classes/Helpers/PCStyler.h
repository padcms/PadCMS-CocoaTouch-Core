//
//  PCStyler.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCMacros.h"

PADCMS_EXTERN NSString * PCButtonImagesKey;
PADCMS_EXTERN NSString * PCButtonImageNormalKey;
PADCMS_EXTERN NSString * PCButtonImageSelectedKey;
PADCMS_EXTERN NSString * PCButtonTintColorOptionKey;

PADCMS_EXTERN NSString * PCButtonBackgroundUseColorTintKey;
PADCMS_EXTERN NSString * PCButtonBackgroundImageNameKey;
PADCMS_EXTERN NSString * PCButtonForegroundImageNameKey;
PADCMS_EXTERN NSString * PCSizeKey;
PADCMS_EXTERN NSString * PCSizeHeightKey;
PADCMS_EXTERN NSString * PCSizeWidthKey; 
PADCMS_EXTERN NSString * PCButtonBackgroundStretchableKey; 
PADCMS_EXTERN NSString * PCLeftCapWidth;
PADCMS_EXTERN NSString * PCTopCapHeight;
PADCMS_EXTERN NSString * PCButtonMarginKey;
PADCMS_EXTERN NSString * PCButtonMarginXKey;
PADCMS_EXTERN NSString * PCButtonMarginYKey;
PADCMS_EXTERN NSString * PCButtonPositionKey;
PADCMS_EXTERN NSString * PCButtonPositionTopRightCornerKey;
PADCMS_EXTERN NSString * PCButtonParentViewFrameKey;

@interface PCStyler : NSObject
{
    NSDictionary* styleSheet;
}

+(PCStyler*)defaultStyler;
-(id)initWithDictionary:(NSDictionary*)aStyleSheet;
-(void)stylizeElement:(id)aElement withStyleName:(NSString*)styleName withOptions:(NSDictionary*)styleOption;
+(float)getVerticalMiniArticleScrollerOffset;

+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor overlay:(UIImage*) overlayImage;

@end
