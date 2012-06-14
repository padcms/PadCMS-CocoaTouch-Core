//
//  PCTwitterImageDownloadOperation.m
//  Pad CMS
//
//  Created by admin on 21.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCTwitterImageDownloadOperation.h"

@implementation PCTwitterImageDownloadOperation

@synthesize twitterUserDict, operationTarget, imageFilePath;

-(id)initWithTwitterUserDict:(NSDictionary*)dict forKey:(NSString*)imageKey{
    self = [self initWithURL:[NSURL URLWithString:[dict objectForKey:imageKey]]];
    if (self) {
        self.twitterUserDict = dict;
        _imageKey = [NSString stringWithString:imageKey];
    }
    return self;
}

-(NSString*)imageKey
{
    return _imageKey;
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
        self.responseOutputStream = [self streamForFilePath:[self.imageFilePath stringByAppendingString:@".temp"]];
    }
    [super connection:connection didReceiveData:data];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
// See comment in header.
{
    NSString* tempFile = [self.imageFilePath stringByAppendingString:@".temp"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
        [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:self.imageFilePath error:nil];
    } else {
        [self saveData:self->_dataAccumulator toPath:imageFilePath];   
    }     
    [super connectionDidFinishLoading:connection]; 
    if (operationTarget&&[operationTarget respondsToSelector:@selector(endDownloadingPCTwitterImageDownloadOperation:)]) {
        [operationTarget performSelectorOnMainThread:@selector(endDownloadingPCTwitterImageDownloadOperation:) withObject:self waitUntilDone:YES];
    }
}


@end
