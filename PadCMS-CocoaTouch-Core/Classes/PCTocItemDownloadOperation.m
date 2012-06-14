//
//  PCTocItemDownloadOperation.m
//  Pad CMS
//
//  Created by admin on 16.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCTocItemDownloadOperation.h"
#import "PCTocItem.h"
#import "PCConfig.h"

@implementation PCTocItemDownloadOperation

@synthesize tocItem, thumbStripeFilePath, thumbSummaryFilePath, operationTarget, thumbSummaryUrlString;

- (id)initWithTocItem:(PCTocItem*)_tocItem
{
    if (!_tocItem||!_tocItem.thumbStripe) {
        return nil;
    }
    NSString* pathExtention = [[_tocItem.thumbStripe pathExtension] lowercaseString];
    NSString* urlStr = nil;
    if ([pathExtention isEqualToString:@"png"]||[pathExtention isEqualToString:@"jpg"]
        ||[pathExtention isEqualToString:@"jpeg"]) {
        urlStr = [[PCConfig serverURLString] stringByAppendingPathComponent:@"resources/192-256/"];
        urlStr = [urlStr stringByAppendingPathComponent:_tocItem.thumbStripe];
    } else {
        urlStr = [[PCConfig serverURLString] stringByAppendingString:_tocItem.thumbStripe];
    }
    self = [self initWithURL:[NSURL URLWithString:urlStr]];
    if (self) {
        self.tocItem = _tocItem;
        if (tocItem.thumbSummary) {
            NSString* pathExtention = [[tocItem.thumbSummary pathExtension] lowercaseString];
            NSString* urlStr = nil;
            if ([pathExtention isEqualToString:@"png"]||[pathExtention isEqualToString:@"jpg"]
                ||[pathExtention isEqualToString:@"jpeg"]) {
                urlStr = [[PCConfig serverURLString] stringByAppendingPathComponent:@"resources/192-256/"];
                urlStr = [urlStr stringByAppendingPathComponent:_tocItem.thumbSummary];
            } else {
                urlStr = [[PCConfig serverURLString] stringByAppendingString:tocItem.thumbSummary];
            }
            self.thumbSummaryUrlString = urlStr;
        }
        _summaryConnection = nil;
        _summaryDataAccumulator = nil;
        _summaryLastResponse = nil;
        isMainImageDownloaded = NO;
    }
    
    return self;
}

- (NSOutputStream*)streamForFilePath:(NSString*)path
{
    NSString* directoryPath = [path stringByDeletingLastPathComponent];
    BOOL isDir = NO;        
    NSError* directoryCreateError = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (!isDir) {            
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES attributes:nil error:&directoryCreateError];             
        }
    }
    
    if (!directoryCreateError) {        
        return [[[NSOutputStream alloc] initToFileAtPath:path append:NO] autorelease];
    }
    
    return nil;
}


- (BOOL)saveData:(NSData*)data toPath:(NSString*)path
{
    if (path&&[path length]&&data) {        
        NSString* directoryPath = [path stringByDeletingLastPathComponent];
        BOOL isDir = NO;        
        NSError* directoryCreateError = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
            if (!isDir) {            
                [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                          withIntermediateDirectories:YES attributes:nil error:&directoryCreateError];             
            }
        }         
        if (!directoryCreateError&&data) {
            
            NSError* writingFileError = nil;
            [data writeToFile:path 
                      options:NSDataWritingFileProtectionNone 
                        error:&writingFileError];
            if (writingFileError) {
                self->_error = writingFileError;
            }
        };
    }
    return NO;
}

#pragma mark * Start and finish overrides

- (void)operationDidStart
// Called by QRunLoopOperation when the operation starts.  This kicks of an 
// asynchronous NSURLConnection.
{
    [super operationDidStart];
    
    if (thumbSummaryUrlString) {
        _summaryConnection = [[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbSummaryUrlString]] delegate:self startImmediately:NO] autorelease];
        
        for (NSString * mode in self.actualRunLoopModes) {
            [_summaryConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
        }
        [_summaryConnection start];
    } 
}

- (void)operationWillFinish
// Called by QRunLoopOperation when the operation has finished.  We 
// do various bits of tidying up.
{
    if (_summaryOutputStream!=nil) {
        [_summaryOutputStream close];
    }
    
    if (_summaryConnection) {
        [_summaryConnection cancel];
        _summaryConnection = nil;
    }        
    [super operationWillFinish];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
// See comment in header.
{
    if (connection==_summaryConnection) {
        _summaryLastResponse = [(NSHTTPURLResponse*)response copy];
    } else {
        [super connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _summaryConnection) {
        if (!_summaryOutputStream) {
            _summaryOutputStream = [self streamForFilePath:[self.thumbSummaryFilePath stringByAppendingString:@".temp"]];
            if (_summaryOutputStream) {
                [_summaryOutputStream open];
            }
        }
        if (_summaryOutputStream) {
            NSUInteger      dataOffset;
            NSUInteger      dataLength;
            const uint8_t * dataPtr;
            NSError *       error;
            NSInteger       bytesWritten;
            
            
            dataOffset = 0;
            dataLength = [data length];
            dataPtr    = [data bytes];
            error      = nil;
            do {
                if (dataOffset == dataLength) {
                    break;
                }
                bytesWritten = [_summaryOutputStream write:&dataPtr[dataOffset] maxLength:dataLength - dataOffset];
                if (bytesWritten <= 0) {
                    error = [_summaryOutputStream streamError];
                    if (error == nil) {
                        error = [NSError errorWithDomain:kQHTTPOperationErrorDomain code:kQHTTPOperationErrorOnOutputStream userInfo:nil];
                    }
                    break;
                } else {
                    dataOffset += bytesWritten;
                }
            } while (YES);
            
            if (error != nil) {
                [self finishWithError:error];
            }
        } else { 
            if (!_summaryDataAccumulator) {
                _summaryDataAccumulator = [[NSMutableData alloc] initWithData:data];
            } else
            {
                [_summaryDataAccumulator appendData:data]; 
            }  
        }              
    } else {
        if (!self.responseOutputStream) {
            self.responseOutputStream = [self streamForFilePath:[self.thumbStripeFilePath stringByAppendingString:@".temp"]];
        }
        [super connection:connection didReceiveData:data];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
// See comment in header.
{    
    if (connection==_summaryConnection) {
        [_summaryConnection cancel];
        _summaryConnection = nil;
        NSString* tempFile = [self.thumbSummaryFilePath stringByAppendingString:@".temp"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
            [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:self.thumbSummaryFilePath error:nil];
        } else {
            [self saveData:_summaryDataAccumulator toPath:thumbSummaryFilePath]; 
        }
        
    } else {
        isMainImageDownloaded = YES;
        NSString* tempFile = [self.thumbStripeFilePath stringByAppendingString:@".temp"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
            [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:self.thumbStripeFilePath error:nil];
        } else {
            [self saveData:self->_dataAccumulator toPath:thumbStripeFilePath];
        }        
    }
    
    if (_summaryConnection==nil&&isMainImageDownloaded) {
        [super connectionDidFinishLoading:self->_connection];
    }    
}

@end
