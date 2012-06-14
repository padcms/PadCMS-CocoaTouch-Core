//
//  PCElementMiniArticleDownloadOperation.m
//  Pad CMS
//
//  Created by admin on 06.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCElementMiniArticleDownloadOperation.h"
#import "PCPageElementMiniArticle.h"
#import "PadCMSCoder.h"
#import "PCConfig.h"

@implementation PCElementMiniArticleDownloadOperation

@synthesize thumbnailFilePath, thumbnailSelectedFilePath, thumbnailURLString, thumbnailSelectedURLString;

- (id)initWithElement:(PCPageElement*)_element
{
   
    self = [super initWithElement:_element];
    if (self) {
        PCPageElementMiniArticle* miniArticleElement =(PCPageElementMiniArticle*)_element;
        if (miniArticleElement.thumbnail) {
            NSString* pathExtention = [[miniArticleElement.thumbnail pathExtension] lowercaseString];
            NSString* urlStr = nil;
            if ([pathExtention isEqualToString:@"png"]||[pathExtention isEqualToString:@"jpg"]
                ||[pathExtention isEqualToString:@"jpeg"]) {
                urlStr = [[PCConfig serverURLString] stringByAppendingFormat:@"/resources/none%@?768-1024",miniArticleElement.thumbnail];
            } else {
                urlStr = [[PCConfig serverURLString] stringByAppendingString:miniArticleElement.thumbnail];
            }
            self.thumbnailURLString = urlStr;
        }
        if (miniArticleElement.thumbnailSelected) {
            NSString* pathExtention = [[miniArticleElement.thumbnailSelected pathExtension] lowercaseString];
            NSString* urlStr = nil;
            if ([pathExtention isEqualToString:@"png"]||[pathExtention isEqualToString:@"jpg"]
                ||[pathExtention isEqualToString:@"jpeg"]) {
                urlStr = [[PCConfig serverURLString] stringByAppendingFormat:@"/resources/none%@?768-1024",miniArticleElement.thumbnailSelected];
            } else {
                urlStr = [[PCConfig serverURLString] stringByAppendingString:miniArticleElement.thumbnailSelected];
            }
            self.thumbnailSelectedURLString = urlStr;
        }
        _thumbnailConnection = nil;
        _thumbnailDataAccumulator = nil;
        _thumbnailLastResponse = nil;
        _thumbnailExpectedContentLength = 0.0f;
        
        _thumbnailSelectedConnection = nil;
        _thumbnailSelectedDataAccumulator = nil;
        _thumbnailSelectedLastResponse = nil;
        _thumbnailSelectedExpectedContentLength = 0.0f;
        
        isMainImageDownloaded = NO;
        
    }   
    return self;
}

#pragma mark * Start and finish overrides

- (void)operationDidStart
// Called by QRunLoopOperation when the operation starts.  This kicks of an 
// asynchronous NSURLConnection.
{
    [super operationDidStart];
    
    if (thumbnailURLString) {
        _thumbnailConnection = [[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailURLString]] delegate:self startImmediately:NO] autorelease];
        
        for (NSString * mode in self.actualRunLoopModes) {
            [_thumbnailConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
        }
        [_thumbnailConnection start];
    } 
    
    if (thumbnailSelectedURLString) {
        _thumbnailSelectedConnection = [[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailSelectedURLString]] delegate:self startImmediately:NO] autorelease];
        
        for (NSString * mode in self.actualRunLoopModes) {
            [_thumbnailSelectedConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
        }
        [_thumbnailSelectedConnection start];
    } 

}

- (void)operationWillFinish
// Called by QRunLoopOperation when the operation has finished.  We 
// do various bits of tidying up.
{
    if (_thumbnailOutPutStream) {
        [_thumbnailOutPutStream close];
    }
    
    if (_thumbnailConnection) {
        [_thumbnailConnection cancel];
        _thumbnailConnection = nil;
    }  
    
    if (_thumbnailSelectedOutPutStream) {
        [_thumbnailSelectedOutPutStream close];
    }
    
    if (_thumbnailSelectedConnection) {
        [_thumbnailSelectedConnection cancel];
        _thumbnailSelectedConnection = nil;
    }
    
    [super operationWillFinish];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
// See comment in header.
{
    if (connection==_thumbnailConnection) {
        _thumbnailLastResponse = [(NSHTTPURLResponse*)response copy];
    } else if (connection==_thumbnailSelectedConnection) {
        _thumbnailSelectedLastResponse = [(NSHTTPURLResponse*)response copy];
    } else {
        [super connection:connection didReceiveResponse:response];
    }
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.responseOutputStream) {
        self.responseOutputStream = [self streamForFilePath:[self.filePath stringByAppendingString:@".temp"]];
    }
    
    if (!_thumbnailOutPutStream) {
        _thumbnailOutPutStream = [self streamForFilePath:[self.thumbnailFilePath stringByAppendingString:@".temp"]];
        if (_thumbnailOutPutStream) {
            [_thumbnailOutPutStream open];
        }
    }
    
    if (!_thumbnailSelectedOutPutStream) {
        _thumbnailSelectedOutPutStream = [self streamForFilePath:[self.thumbnailSelectedFilePath stringByAppendingString:@".temp"]];
        if (_thumbnailSelectedOutPutStream) {
            [_thumbnailSelectedOutPutStream open];
        }
    }
    
    if (connection == _thumbnailConnection) {
        
        if (_thumbnailOutPutStream) {
            NSUInteger      dataOffset;
            NSUInteger      dataLength;
            const uint8_t * dataPtr;
            NSError *       error;
            NSInteger       bytesWritten;
            
            assert(self.responseOutputStream != nil);
            
            dataOffset = 0;
            dataLength = [data length];
            dataPtr    = [data bytes];
            error      = nil;
            do {
                if (dataOffset == dataLength) {
                    break;
                }
                bytesWritten = [_thumbnailOutPutStream write:&dataPtr[dataOffset] maxLength:dataLength - dataOffset];
                if (bytesWritten <= 0) {
                    error = [_thumbnailOutPutStream streamError];
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
            if (!_thumbnailDataAccumulator) {
                _thumbnailDataAccumulator = [[NSMutableData alloc] initWithData:data];
            } else
            {
                [_thumbnailDataAccumulator appendData:data]; 
            } 
        } 
        if (_thumbnailExpectedContentLength == 0.0f) {
            if ([_thumbnailLastResponse expectedContentLength]!=-1) {
                _thumbnailExpectedContentLength = (CGFloat) [_thumbnailLastResponse expectedContentLength];
            }
            
        }
        _lengthOfDownloadedData += [data length];
    } else if (connection == _thumbnailSelectedConnection) {
        
        if (_thumbnailSelectedOutPutStream) {
            NSUInteger      dataOffset;
            NSUInteger      dataLength;
            const uint8_t * dataPtr;
            NSError *       error;
            NSInteger       bytesWritten;
            
            assert(self.responseOutputStream != nil);
            
            dataOffset = 0;
            dataLength = [data length];
            dataPtr    = [data bytes];
            error      = nil;
            do {
                if (dataOffset == dataLength) {
                    break;
                }
                bytesWritten = [_thumbnailSelectedOutPutStream write:&dataPtr[dataOffset] maxLength:dataLength - dataOffset];
                if (bytesWritten <= 0) {
                    error = [_thumbnailSelectedOutPutStream streamError];
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
            if (!_thumbnailSelectedDataAccumulator) {
                _thumbnailSelectedDataAccumulator = [[NSMutableData alloc] initWithData:data];
            } else
            {
                [_thumbnailSelectedDataAccumulator appendData:data]; 
            }
        }        
        
        if (_thumbnailSelectedExpectedContentLength == 0.0f) {
            if ([_thumbnailSelectedLastResponse expectedContentLength]!=-1) {
                _thumbnailSelectedExpectedContentLength = (CGFloat) [_thumbnailSelectedLastResponse expectedContentLength];
            }
            
        }
        _lengthOfDownloadedData += [data length];
    } else {
        [super connection:connection didReceiveData:data];
    }
  
  if (self.operationTarget&&[self.operationTarget respondsToSelector:@selector(updateProgressForMiniArticleOperation:)]) {
    [self.operationTarget performSelectorOnMainThread:@selector(updateProgressForMiniArticleOperation:) withObject:self waitUntilDone:NO];
  }

}
-(float)currentProgress
{
  return ((CGFloat) _lengthOfDownloadedData / (CGFloat)(_expectedContentLength + _thumbnailExpectedContentLength + _thumbnailSelectedExpectedContentLength));
}

- (void)progressOfDownloadOperation
{
	//NSLog(@"progress = %@", progress);
    CGFloat progress = ((CGFloat) _lengthOfDownloadedData / (CGFloat)(_expectedContentLength + _thumbnailExpectedContentLength + _thumbnailSelectedExpectedContentLength));
	[self.progressTarget progressOfDownloading:progress forElement:self.element];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
// See comment in header.
{    
    if (connection==_thumbnailConnection) {
        [_thumbnailConnection cancel];
        _thumbnailConnection = nil;
        NSString* tempFile = [self.thumbnailFilePath stringByAppendingString:@".temp"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
            [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:self.thumbnailFilePath error:nil];
        } else {
            [self saveData:_thumbnailDataAccumulator toPath:thumbnailFilePath];
        }
        
    } else if (connection==_thumbnailSelectedConnection) {
        [_thumbnailSelectedConnection cancel];
        _thumbnailSelectedConnection = nil;
        NSString* tempFile = [self.thumbnailSelectedFilePath stringByAppendingString:@".temp"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
            [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:self.thumbnailSelectedFilePath error:nil];
        } else {
            [self saveData:_thumbnailSelectedDataAccumulator toPath:thumbnailSelectedFilePath];
        }        
    } else {
        isMainImageDownloaded = YES;
    }
    
    if (_thumbnailSelectedConnection==nil&&_thumbnailConnection==nil&&isMainImageDownloaded) {
        [super connectionDidFinishLoading:self->_connection];
    }    
}

@end
