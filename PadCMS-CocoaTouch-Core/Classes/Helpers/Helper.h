//
//  Helper.h
//  the_reader
//
//  Created by Mac OS on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _DeviceResolution {
  REGULAR = 0,
  RETINA  = 1
} DeviceResolution;

@interface Helper : NSObject {
	
}

+ (CGSize) getSizeForImage:(NSString *) imagePath;

+ (CGPDFDocumentRef) getDocumentRef: (const char*) filename;

+ (void) logRect:(CGRect) rect message:(NSString*) message;
+ (void) logSize:(CGSize) size message:(NSString*) message;

+ (CGPoint) rectCenter:(CGRect) rect;
+ (NSString*) getHomeDirectory;
+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor overlay:(UIImage*) overlayImage;
+ (void) logColor:(UIColor*) c;
+ (NSString*) getIssueDirectory;
+ (int) getInternalRevision;
+ (void) setInternalRevision:(int)revision;
+ (void) setInternalPageIndex:(int)pageIndex;
+ (int) getInternalPageIndex;
+ (NSString*)getIssueText;
+ (void)setIssueText:(NSString*)newCaption;
+ (void) clearPrefsForId:(int) issueId;
+ (DeviceResolution)currentDeviceResolution;

@end