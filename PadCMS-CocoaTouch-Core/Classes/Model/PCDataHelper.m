//
//  PCDataHelper.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCDataHelper.h"
#import "NSDate+InternetDateTime.h"

@implementation PCDataHelper

+ (UIColor*)colorFromString:(NSString*)aString
{
    if (aString == nil || [aString length] == 0)
        return nil;
    
    NSScanner *scanner = [NSScanner scannerWithString:aString];
    [scanner setScanLocation:0];
    unsigned color = 0;
    if ([scanner scanHexInt:&color])
    {
        return [UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:1.0];
    }
    return nil;
}

+ (NSDate*)dateFromString:(NSString*)aString
{
  return aString ? [NSDate dateFromRFC3339String:aString] : nil;
}

@end
