//
//  PCPDFHelper.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCPDFHelper : NSObject

+(NSArray*)activeZonesForPage:(CGPDFPageRef)pageRef;


@end
