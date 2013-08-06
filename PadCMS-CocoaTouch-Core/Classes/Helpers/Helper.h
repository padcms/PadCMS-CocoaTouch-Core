//
//  Helper.h
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
