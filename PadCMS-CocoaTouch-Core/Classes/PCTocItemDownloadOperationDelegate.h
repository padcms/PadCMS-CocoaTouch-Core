//
//  PCTocItemDownloadOperationDelegate.h
//  Pad CMS
//
//  Created by admin on 16.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCTocItemDownloadOperation;
@protocol PCTocItemDownloadOperationDelegate <NSObject>

@optional
- (void)endDownloadingPCTocItemDownloadOperation:(PCTocItemDownloadOperation*)operation;

@end
