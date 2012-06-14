//
//  PCElementDownloadoperationFactory.h
//  Pad CMS
//
//  Created by admin on 02.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCElementDownloadOperation, PCPageElement;

@interface PCElementDownloadOperationFactory : NSObject

+(PCElementDownloadOperationFactory*)factory;
-(PCElementDownloadOperation*)operationForElement:(PCPageElement*)element toHomeDirectory:(NSString*)homeDirectory;


@end
