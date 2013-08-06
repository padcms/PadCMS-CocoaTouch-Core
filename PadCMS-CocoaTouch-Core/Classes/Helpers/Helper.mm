//
//  Helper.m
//  the_reader
//
//  Created by Mac OS on 8/5/10.
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

#import "Helper.h"
#include <sys/xattr.h>
#import <ImageIO/ImageIO.h>

#ifndef MIN
#define MIN(a,b) ((a) < (b) ? (a) :(b))
#endif

#ifndef MAX
#define MAX(a,b) ((a) > (b) ? (a) :(b))
#endif

static int int_revision = 121;
static NSString *issueTitle;
static int int_pageindex = 0;

#define private_catalog @"PrivateDocuments"

@implementation Helper

#pragma mark Helper class methods

+ (CGSize) getSizeForImage:(NSString *) imagePath
{
    if (imagePath == nil) return CGSizeZero;
    
    NSURL *imageFileURL = [NSURL fileURLWithPath:imagePath];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    if (imageSource == NULL)
    {
        return CGSizeZero;
    }
    
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if (imageProperties != NULL)
    {
        CFNumberRef widthNum  = (CFNumberRef)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL)
        {
            CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
        }
        
        CFNumberRef heightNum = (CFNumberRef)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL)
        {
            CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
        }
        
        CFRelease(imageProperties);
    }
    
    CFRelease(imageSource);
    
    return CGSizeMake(width, height);
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path
{
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

+ (NSString*) getHomeDirectory
{
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1)
        return nil;
	NSString* docDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:private_catalog];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:docDirectory])
    {
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:docDirectory withIntermediateDirectories:NO attributes:nil error:nil];
        if(result)
        {
            result = [Helper addSkipBackupAttributeToItemAtPath:docDirectory];
            if(!result)
                NSLog(@"setting directory attribute is false !");
            else
                NSLog(@"setting directory attribute is true !");
        }
    }
    
	return docDirectory;
}

+ (NSString*) getIssueDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1)
        return nil;
    NSString* docDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:private_catalog];
    
	NSString *documentsDirectoryPath = [docDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",[Helper getInternalRevision]]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:docDirectory])
    {
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:docDirectory withIntermediateDirectories:NO attributes:nil error:nil];
        if(result)
        {
            result = [Helper addSkipBackupAttributeToItemAtPath:docDirectory];
            
            if(!result)
                NSLog(@"setting directory attribute is false !");
            else
                NSLog(@"setting directory attribute is true !");
        }
    }
	
	return documentsDirectoryPath;
}

+ (CGPDFDocumentRef) getDocumentRef: (const char*) filename
{
	CFStringRef path = nil;
    CFURLRef url = nil;
    CGPDFDocumentRef document = nil;
	
    path = CFStringCreateWithCString (NULL, filename,
									  kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path, 
										 kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
    return (CGPDFDocumentRef)[NSMakeCollectable(document) autorelease];;
}

+ (void) logRect:(CGRect) rect message:(NSString*) message
{
	NSLog(@"%@: [%.02f,%.02f %.02fx%.02f]", message, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);		
}

+ (void) logSize:(CGSize) size message:(NSString*) message
{
	NSLog(@"%@: [%.02fx%.02f]", message, size.width, size.height);		
}

+ (CGPoint) rectCenter:(CGRect) rect {
	return CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height/2);
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
    
    [theColor set];
    CGContextFillRect(ctx, area);
	
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, baseImage.CGImage);
	
	CGContextSetBlendMode(ctx, kCGBlendModeNormal);
	
	if (overlayImage != nil) {
		CGContextDrawImage(ctx, area, overlayImage.CGImage);
	}
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (UIImage *)colorizeImage1:(UIImage *)baseImage color:(UIColor *)theColor overlay:(UIImage*) overlayImage
{
    UIGraphicsEndImageContext();
	UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
	
	CGContextSetBlendMode(ctx, kCGBlendModeNormal);
	
	if (overlayImage != nil)
	{
		CGContextDrawImage(ctx, area, overlayImage.CGImage);
	}
    
	
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    
    [theColor set];
    CGContextFillRect(ctx, area);
	
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, baseImage.CGImage);
	
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (void) logColor:(UIColor*) c
{
	const CGFloat* comps = CGColorGetComponents(c.CGColor);
	NSLog(@"%02x%02x%02x", (int)(comps[0] * 255),(int)(comps[1] * 255),(int)(comps[2] * 255));
}

+ (void) setInternalRevision:(int)revision
{
	int_revision = revision;
}

+ (void) setInternalPageIndex:(int)pageIndex
{
    int_pageindex = pageIndex;
}

+ (int) getInternalPageIndex
{
    return int_pageindex;
}

+ (int) getInternalRevision
{	
	return int_revision;
}

+ (void) clearPrefsForId:(int) issueId
{
	if(issueId)
	{
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
		[ud removeObjectForKey:[NSString stringWithFormat:@"%d_currentPosition",issueId]];
		[ud synchronize];
	}
}

+ (NSString*)getIssueText
{
	return issueTitle;
}

+ (void)setIssueText:(NSString*)newCaption
{
    if(newCaption)
    {
        NSLog(@"From setIssueTest: %@", newCaption);
        issueTitle = [NSString stringWithString:newCaption];
    }
}

+ (DeviceResolution)currentDeviceResolution
{
  DeviceResolution dr;
  
  CGFloat currentScreenScale = [UIScreen mainScreen].scale;
  
  if(currentScreenScale == 1.0)
    dr = REGULAR;
  
  if(currentScreenScale == 2.0)
    dr = RETINA;
  
  return dr;
}



@end
