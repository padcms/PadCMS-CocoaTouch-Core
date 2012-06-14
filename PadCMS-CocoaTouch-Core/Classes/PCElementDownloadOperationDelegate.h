//
//  PCElementDownloadOperationDelegate.h
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCElementDownloadOperation;

@protocol PCElementDownloadOperationDelegate <NSObject>

@optional
- (void)endDownloadingPCPageElementOperation:(PCElementDownloadOperation*)operation;

@end
