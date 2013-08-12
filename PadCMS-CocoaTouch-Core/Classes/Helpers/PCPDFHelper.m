//
//  PCPDFHelper.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
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

#import "PCPDFHelper.h"
#import "PCPageActiveZone.h"

#define PCPDFAnnotsKey "Annots"
#define PCPDFAKey "A"
#define PCPDFURIKey "URI"
#define PCPDFRectKey "Rect"

@implementation PCPDFHelper

+ (CGRect) rectFromPDFArray: (CGPDFArrayRef)rectArray
{
    CGPoint firstPoint=CGPointZero;
    CGPoint secondPoint=CGPointZero;
    
	CGPDFArrayGetNumber(rectArray, 0, &firstPoint.x);
	CGPDFArrayGetNumber(rectArray, 1, &firstPoint.y);
	CGPDFArrayGetNumber(rectArray, 2, &secondPoint.x);
	CGPDFArrayGetNumber(rectArray, 3, &secondPoint.y);
    

    if (firstPoint.x<0)
        firstPoint.x=0;
        
    if (firstPoint.y<0)
        firstPoint.y=0;
    
    CGRect rect = CGRectZero;
    rect.origin = firstPoint;
	rect.size.width = secondPoint.x - firstPoint.x;
    rect.size.height = secondPoint.y - firstPoint.y;
    
    if (rect.size.width<0)
    {
        rect.origin.x += rect.size.width;
        rect.size.width = -rect.size.width; 
    }
    if (rect.size.height<0)
    {
        rect.origin.y += rect.size.height;
        rect.size.height = -rect.size.height; 
    }
	return rect;
}

+(NSArray*)activeZonesForPage:(CGPDFPageRef)pageRef
{
	CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(pageRef);
	
	CGPDFArrayRef annots = nil;
	if (!CGPDFDictionaryGetArray(pageDict, PCPDFAnnotsKey, &annots))
		return nil;

    NSUInteger count = CGPDFArrayGetCount(annots);
    if (count==0)
        return nil;
    
	NSMutableArray* links = [[NSMutableArray alloc] initWithCapacity:count];
	
    for (unsigned i = 0; i < count; i++)
	{
		
		CGPDFDictionaryRef annotation = nil;
		if (!CGPDFArrayGetDictionary(annots, i, &annotation))
            continue;
		
        CGPDFDictionaryRef a = nil;
		if (!CGPDFDictionaryGetDictionary(annotation, PCPDFAKey, &a))
            continue;
        
		CGPDFStringRef pdfUriRef = nil;
		if (!CGPDFDictionaryGetString(a, PCPDFURIKey, &pdfUriRef))
               continue;
		
		NSString* uri = [NSString stringWithCString:(char*)CGPDFStringGetBytePtr(pdfUriRef) encoding:NSASCIIStringEncoding];
		
		CGPDFArrayRef rect = nil;
		CGPDFDictionaryGetArray(annotation, PCPDFRectKey, &rect);
		
		if (CGPDFArrayGetCount(rect) != 4)
			continue;
		
		CGRect linkRect =[self rectFromPDFArray: rect];
        
        PCPageActiveZone* pdfActiveZone = [[PCPageActiveZone alloc] initWithRect:linkRect URL:uri];
        [links addObject:pdfActiveZone];
		[pdfActiveZone release];
	}

    return [links autorelease];
}

@end
