//
//  PCHorizontalPageDownloadOperationDelegate.h
//  Pad CMS
//
//  Created by admin on 29.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCHorizontalPageDownloadOperation;

@protocol PCHorizontalPageDownloadOperationDelegate <NSObject>

- (void)endDownloadingPCHorizontalPageOperation:(PCHorizontalPageDownloadOperation*)operation;

@end
