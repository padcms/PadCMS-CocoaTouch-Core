//
//  PCTwitterImageDownloadOperationProtocol.h
//  Pad CMS
//
//  Created by admin on 21.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCTwitterImageDownloadOperation;
@protocol PCTwitterImageDownloadOperationDelegate <NSObject>
@optional
- (void)endDownloadingPCTwitterImageDownloadOperation:(PCTwitterImageDownloadOperation*)operation;

@end
