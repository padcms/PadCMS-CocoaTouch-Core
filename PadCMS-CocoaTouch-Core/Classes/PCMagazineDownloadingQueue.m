//
//  PCMagazineDownloadingQueue.m
//  Pad CMS
//
//  Created by admin on 02.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMagazineDownloadingQueue.h"
#import "PCIssue.h"
#import "PCColumn.h"
#import "PCPage.h"
#import "PCPageElement.h"
#import "PCElementDownloadOperation.h"
#import "PCElementDownloadoperationFactory.h"
#import "PCTocItem.h"
#import "PCTocItemDownloadOperation.h"
#import "PCTwitterImageDownloadOperation.h"
#import "PCHorizontalPageDownloadOperation.h"
#import "PCHelpPageDownloadOperation.h"
#import "PCRevision.h"

@implementation PCMagazineDownloadingQueue

@synthesize revision = _revision;

- (id)initWithRevision:(PCRevision*)revision target:(id)target startImmediately:(BOOL)start
{
    self = [super initWithTarget:target];
    
    if (self)
    {
        self.revision = revision;
        [self setMaxConcurrentOperationCount:1];
        [self startDownloading];
    }
    
    return self;
}

- (id)initWithRevision:(PCRevision*)revision target:(id)target
{
    return [self initWithRevision:revision target:target startImmediately:YES];
}

- (void)setPriority:(NSOperationQueuePriority)priority forElement:(PCPageElement*)element
{
    for (PCElementDownloadOperation* operation in self.operations) {
        if (operation.element==element) {
            [operation setQueuePriority:priority];
        }
    }
}

- (PCElementDownloadOperation*)operationForElement:(PCPageElement*)element
{
    for (QHTTPOperation* operation in self.operations) {
        if (![operation  isKindOfClass:[PCElementDownloadOperation class]]) {
            continue;
        }
        PCElementDownloadOperation* elementDownloadOperation = (PCElementDownloadOperation*)operation;
        if (elementDownloadOperation.element==element) {
            return elementDownloadOperation;
        }
    }    
    return nil;
}

- (PCTocItemDownloadOperation*)operationForTocItem:(PCTocItem*)tocItem
{
    for (QHTTPOperation* operation in self.operations) {
        if (![operation  isKindOfClass:[PCTocItemDownloadOperation class]]) {
            continue;
        }
        PCTocItemDownloadOperation* tocItemOperation = (PCTocItemDownloadOperation*)operation;
        if (tocItemOperation.tocItem==tocItem) {
            return tocItemOperation;
        }
    }    
    return nil;
}

- (PCTwitterImageDownloadOperation*)operationForTwitterDict:(NSDictionary*)dict andKey:(NSString*)key
{
    for (QHTTPOperation* operation in self.operations) {
        if (![operation  isKindOfClass:[PCTwitterImageDownloadOperation class]]) {
            continue;
        }
        PCTwitterImageDownloadOperation* twitterOperation = (PCTwitterImageDownloadOperation*)operation;
        NSString* idStr = [dict objectForKey:@"id_str"];
        NSString* idStrFromOperation = [twitterOperation.twitterUserDict objectForKey:@"id_str"];
        if ([[twitterOperation imageKey] isEqualToString:key]&&[idStr isEqualToString:idStrFromOperation]) {
            return twitterOperation;
        }
    } 
    return nil;
}

- (PCHorizontalPageDownloadOperation*)operationForHorizontalPageKey:(NSNumber*)key
{
    for (QHTTPOperation* operation in self.operations) {
        if (![operation  isKindOfClass:[PCHorizontalPageDownloadOperation class]]) {
            continue;
        }
        PCHorizontalPageDownloadOperation* horizontalPageOperation = (PCHorizontalPageDownloadOperation*)operation;
        if ([horizontalPageOperation.key isEqualToNumber:key]) {
            return horizontalPageOperation;
        }
    } 
    return nil;
}

- (PCHelpPageDownloadOperation*)operationForHelpPageKey:(NSString*)key
{
    for (QHTTPOperation* operation in self.operations) {
        if (![operation  isKindOfClass:[PCHelpPageDownloadOperation class]]) {
            continue;
        }
        PCHelpPageDownloadOperation* helpPageOperation = (PCHelpPageDownloadOperation*)operation;
        if ([helpPageOperation.helpPageKey isEqualToString:key]) {
            return helpPageOperation;
        }
    } 
    return nil;
}

- (void)startDownloading
{
    BOOL isFirstoperation = YES;   
    for (PCColumn* column in _revision.columns) {
        for (PCPage* page in column.pages) {
            for (PCPageElement* element in page.elements) {
                PCElementDownloadOperation* operation = [[PCElementDownloadOperationFactory factory] operationForElement:element toHomeDirectory:_revision.contentDirectory];                
                if (operation) { 
                    if (isFirstoperation) {
                        isFirstoperation = NO;
                        [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
                    } else {
                        [operation setQueuePriority:NSOperationQueuePriorityLow];
                    }
                    [self addOperation:operation finishedAction:@selector(endDownloadingPCPageElementOperation:)];
                }
            }
        }
    }
    for (PCTocItem* item in _revision.toc) {
        NSString* filePath = [_revision.contentDirectory stringByAppendingPathComponent:item.thumbStripe];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            filePath = [_revision.contentDirectory stringByAppendingPathComponent:item.thumbSummary];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                continue;
            }
        }
        PCTocItemDownloadOperation* operation = [[PCTocItemDownloadOperation alloc] initWithTocItem:item];
        if (operation) {
            operation.thumbStripeFilePath = [_revision.contentDirectory stringByAppendingPathComponent:item.thumbStripe];
            if (item.thumbSummary) {
                operation.thumbSummaryFilePath = [_revision.contentDirectory stringByAppendingPathComponent:item.thumbSummary];
            }
            [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
            operation.operationTarget = self.target;
            [self addOperation:operation finishedAction:@selector(endDownloadingPCTocItemDownloadOperation:)];            
        }
    }
    
    if (_revision.helpPages && [_revision.helpPages count]>0) {
        NSArray     *keys = [_revision.helpPages allKeys];        
        for (int i = 0; i<[keys count]; i++)
        {
            NSString* key = [keys objectAtIndex:i];
            NSString* resource  = [_revision.helpPages objectForKey:key];
            
            NSString* filePath = [_revision.contentDirectory stringByAppendingPathComponent:resource];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                continue;
            }
            
            PCHelpPageDownloadOperation* operation = [[PCHelpPageDownloadOperation alloc]
                                                            initWithResource:resource forKey:key];            
            if (operation) {
                operation.filePath = [_revision.contentDirectory stringByAppendingPathComponent:resource];
                [operation setQueuePriority:NSOperationQueuePriorityLow];
                [self addOperation:operation finishedAction:@selector(endDownloadingPCPageElementOperation:)];
            }
            
        }
    }
    
    if (_revision.horizontalPages && [_revision.horizontalPages count] > 0)
    {
        NSArray     *keys = [_revision.horizontalPages allKeys];        
        for (int i = 0; i<[keys count]; i++)
        {
            NSNumber* key = [keys objectAtIndex:i];
            NSString* resource  = [_revision.horizontalPages objectForKey:key];
            NSString* filePath = [_revision.contentDirectory stringByAppendingPathComponent:resource];

            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                continue;
            }
            
            PCHorizontalPageDownloadOperation* operation = [[PCHorizontalPageDownloadOperation alloc]
                                                            initWithResource:resource forKey:key];            
            if (operation) {
                operation.filePath = filePath;
                [operation setQueuePriority:NSOperationQueuePriorityLow];
                [self addOperation:operation finishedAction:@selector(endDownloadingPCPageElementOperation:)];
            }
            
        }
    }
}

@end
