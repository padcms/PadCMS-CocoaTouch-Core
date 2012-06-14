//
//  PCTocItemDownloadOperation.h
//  Pad CMS
//
//  Created by admin on 16.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "QHTTPOperation.h"
#import "PCTocItemDownloadOperationDelegate.h"

@class PCTocItem;

@interface PCTocItemDownloadOperation : QHTTPOperation
{
    NSURLConnection* _summaryConnection;
    NSMutableData *     _summaryDataAccumulator;
    NSHTTPURLResponse * _summaryLastResponse;
    NSOutputStream* _summaryOutputStream;
    
    BOOL isMainImageDownloaded;
}

@property(nonatomic, assign, readwrite) PCTocItem* tocItem;
@property(nonatomic, copy) NSString* thumbStripeFilePath;
@property(nonatomic, copy) NSString* thumbSummaryFilePath;

@property(nonatomic, assign) NSObject<PCTocItemDownloadOperationDelegate>* operationTarget;
@property(nonatomic, retain) NSString* thumbSummaryUrlString;

- (id)initWithTocItem:(PCTocItem*)_tocItem;

- (BOOL)saveData:(NSData*)data toPath:(NSString*)path;
- (NSOutputStream*)streamForFilePath:(NSString*)path;

@end
