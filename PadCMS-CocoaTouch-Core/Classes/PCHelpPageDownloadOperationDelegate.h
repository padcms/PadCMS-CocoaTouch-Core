//
//  PCHelpPageDownloadOperationDelegate.h
//  Pad CMS
//
//  Created by admin on 29.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCHelpPageDownloadOperation;

@protocol PCHelpPageDownloadOperationDelegate <NSObject>

- (void)endDownloadingPCHelpPageDownloadOperationOperation:(PCHelpPageDownloadOperation*)operation;

@end
