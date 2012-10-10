//
//  UIView+plist.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Mikhail Kotov on 9/21/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "UIView+plist.h"
#import "UIColor+HexString.h"
#import "PCLocalizationManager.h"

#define Enabled @"Enabled"
#define Visible @"Visible"
#define Frame @"Frame"
#define Height @"Height"
#define Width @"Width"
#define X @"X"
#define Y @"Y"
#define AutoResizingMask @"AutoResizingMask"
#define NormalState @"NormalState"
#define HighlightedState @"HighlightedState"
#define DisabledState @"DisabledState"
#define SelectedState @"SelectedState"
#define BackgroundImage @"BackgroundImage"
#define BackgroundColor @"BackgroundColor"
#define Text @"Text"
#define LocalKey @"LocalKey"
#define Value @"Value"
#define Font @"Font"
#define Name @"Name"
#define Size @"Size"
#define Image @"Image"
#define ARLeft @"AutoresizingFlexibleLeftMargin"
#define ARWidth @"AutoresizingFlexibleWidth"
#define ARRight @"AutoresizingFlexibleRightMargin"
#define ARTop @"AutoresizingFlexibleTopMargin"
#define ARHeight @"AutoresizingFlexibleHeight"
#define ARBottom @"AutoresizingFlexibleBottomMargin"

@interface NSDictionary (valueOrDef)

-(id)valueForKey:(NSString *)key orDefault:(id)defaultValue;
-(CGFloat)floatForKey:(NSString *)key orDefault:(CGFloat)defaultValue;
-(NSString*)localStringFromTextDictionary;
-(UIFont*)fontFromDictionary;
@end

@implementation NSDictionary (valueOrDef)

-(id)valueForKey:(NSString *)key orDefault:(id)defaultValue{
    id temp = [self valueForKey:key];
    return temp?temp:defaultValue;
}

-(CGFloat)floatForKey:(NSString *)key orDefault:(CGFloat)defaultValue{
    id temp = [self valueForKey:key];
    return temp?[temp floatValue]:defaultValue;
}

-(NSString*)localStringFromTextDictionary{
    NSString* result;
    if ([self valueForKey:LocalKey]) {
        result = [PCLocalizationManager localizedStringForKey:[self valueForKey: LocalKey] value:[self valueForKey: Value]];
    }
    else
        result = [self valueForKey:Value orDefault:@""];
    return result;
}

-(UIFont*)fontFromDictionary{
    return [UIFont fontWithName:[self valueForKey: Name orDefault:@"Helvetica"] size:[self floatForKey:Size orDefault:18]];
}

@end

@implementation UIView (plist)
-(NSUInteger)AutoresizingMaskFromArray:(NSArray*)anArray{
    NSUInteger result = UIViewAutoresizingNone;
    for (NSString* curString in anArray) {
        if ([curString isEqualToString:ARLeft]) result |= UIViewAutoresizingFlexibleLeftMargin;
        else if ([curString isEqualToString:ARWidth]) result |= UIViewAutoresizingFlexibleWidth;
        else if ([curString isEqualToString:ARRight]) result |= UIViewAutoresizingFlexibleRightMargin;
        else if ([curString isEqualToString:ARTop]) result |= UIViewAutoresizingFlexibleTopMargin;
        else if ([curString isEqualToString:ARHeight]) result |= UIViewAutoresizingFlexibleHeight;
        else if ([curString isEqualToString:ARBottom]) result |= UIViewAutoresizingFlexibleBottomMargin;
    }
    return result;
}

-(void)setUIFromDictionary:(NSDictionary*)aUIDictionary forState:(UIControlState)aControlState{
    if (aUIDictionary && aUIDictionary.count) {
        id curElement = [aUIDictionary valueForKey:BackgroundImage];
        if (curElement) {
            [(UIButton*)self setBackgroundImage:[UIImage imageNamed:curElement] forState:aControlState];
        }
        curElement = [aUIDictionary valueForKey:Image];
        if (curElement) {
            [(UIButton*)self setImage:[UIImage imageNamed:curElement] forState:aControlState];
        }
        curElement = [aUIDictionary valueForKey:Text];
        if (curElement) {
            [(UIButton*)self setTitle: [curElement localStringFromTextDictionary] forState:aControlState];
        }
    }
}

-(void)styledWithDictionary:(NSDictionary*)aDictionary{
    if (aDictionary && [aDictionary isKindOfClass:[NSDictionary class]] && aDictionary.count) {
        id curElement;
        // Visible
        curElement = [aDictionary valueForKey:Visible];
        [self setHidden:curElement?(![curElement boolValue]):NO];
        // Enabled
        curElement = [aDictionary valueForKey:Enabled];
        if (curElement && [self isKindOfClass:[UIControl class]]) {
            [(UIControl*)self setEnabled:[curElement boolValue]];
        }
        // Frame
        curElement = [aDictionary valueForKey:Frame];
        if (curElement) {
            [self setFrame:CGRectMake([curElement floatForKey:X orDefault:0.0], [curElement floatForKey:Y orDefault:0.0], [curElement floatForKey:Width orDefault:0.0], [curElement floatForKey:Height orDefault:0.0])];
        }
        // Title for button
        if ([self respondsToSelector:@selector(setTitle:forState:)]){
            curElement = [aDictionary valueForKey:NormalState];
            if (curElement){
                [self setUIFromDictionary:curElement forState:UIControlStateNormal];
            }
            curElement = [aDictionary valueForKey:HighlightedState];
            if (curElement){
                [self setUIFromDictionary:curElement forState:UIControlStateHighlighted];
            }
            curElement = [aDictionary valueForKey:DisabledState];
            if (curElement){
                [self setUIFromDictionary:curElement forState:UIControlStateDisabled];
            }
            curElement = [aDictionary valueForKey:SelectedState];
            if (curElement){
                [self setUIFromDictionary:curElement forState:UIControlStateSelected];
            }
        }
        curElement = [aDictionary valueForKey:BackgroundColor];
        if (curElement && [self respondsToSelector:@selector(setBackgroundColor:)]) {
            [self setBackgroundColor:[UIColor colorWithHexString:curElement]];
        }
        curElement = [aDictionary valueForKey:Font];
        if (curElement) {
            if ([self respondsToSelector:@selector(setFont:)]) {
                [(UITextField*)self setFont:[curElement fontFromDictionary]];
            }
            else if ([self respondsToSelector:@selector(titleLabel)] && [[self titleLabel] respondsToSelector:@selector(setFont:)]) {
                [((UIButton*)self).titleLabel setFont:[curElement fontFromDictionary]];
            }
        }
        
        curElement = [aDictionary valueForKey:Text];
        if (curElement && [self respondsToSelector:@selector(setText:)]) {
            [(UITextField*)self setText:[curElement localStringFromTextDictionary]];
        }
        curElement = [aDictionary valueForKey:Image];
        if (curElement && [self respondsToSelector:@selector(setImage:)]) {
            [(UIImageView*)self setImage:[UIImage imageNamed:curElement]];
        }
        curElement = [aDictionary valueForKey:AutoResizingMask];
        if (curElement && [curElement isKindOfClass:[NSArray class]] && [self respondsToSelector:@selector(setAutoresizingMask:)]) {
            [self setAutoresizingMask:[self AutoresizingMaskFromArray:curElement]];
        }

    }
}

@end
