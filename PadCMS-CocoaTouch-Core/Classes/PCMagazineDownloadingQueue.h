//
//  PCMagazineDownloadingQueue.h
//  Pad CMS
//
//  Created by admin on 02.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "QWatchedOperationQueue.h"

@class PCIssue, PCColumn, PCPage, PCPageElement, PCElementDownloadOperation, PCTocItem, PCTocItemDownloadOperation, PCTwitterImageDownloadOperation, PCHorizontalPageDownloadOperation, PCHelpPageDownloadOperation;
@class PCRevision;

@interface PCMagazineDownloadingQueue : QWatchedOperationQueue

@property(nonatomic, assign, readwrite) PCRevision* revision;

- (void)setPriority:(NSOperationQueuePriority)priority forElement:(PCPageElement*)_element;

- (id)initWithRevision:(PCRevision*)revision target:(id)target startImmediately:(BOOL)start;

- (id)initWithRevision:(PCRevision*)revision target:(id)target;

- (void)startDownloading;

- (PCElementDownloadOperation*)operationForElement:(PCPageElement*)element;
- (PCTocItemDownloadOperation*)operationForTocItem:(PCTocItem*)tocItem;
- (PCTwitterImageDownloadOperation*)operationForTwitterDict:(NSDictionary*)dict andKey:(NSString*)key;
- (PCHorizontalPageDownloadOperation*)operationForHorizontalPageKey:(NSNumber*)key;
- (PCHelpPageDownloadOperation*)operationForHelpPageKey:(NSString*)key;

@end

@protocol PCMagazineDownloadingProtocol

@optional
- (void)endDownloadingPCPageElementOperation:(PCElementDownloadOperation*)operation;

@end
