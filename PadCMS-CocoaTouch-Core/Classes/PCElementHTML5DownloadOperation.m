//
//  PCElementHTML5DownloadOperation.m
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCElementHTML5DownloadOperation.h"
#import "ZipArchive.h"
#import "PCPageElementHtml5.h"
#import "PCConfig.h"

@implementation PCElementHTML5DownloadOperation


- (id)initWithElement:(PCPageElement*)_element
{
    PCPageElementHtml5* html5Element = (PCPageElementHtml5*)_element;
    NSString* urlStr = [[PCConfig serverURLString] stringByAppendingPathComponent:[@"resources/none/" stringByAppendingPathComponent:html5Element.resource]];
    NSLog(@"urlStr = %@", urlStr);
    self = [self initWithURL:[NSURL URLWithString:urlStr]];
    if (self) {
        self.element = _element;
    }
    
    return self;
}

- (BOOL)processDownloadingContent
{
    [self saveData:self->_dataAccumulator toPath:self.filePath];
    self->_dataAccumulator = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        ZipArchive* archive = [[ZipArchive alloc] init];
        if ([archive UnzipOpenFile:self.filePath]) {
            NSString* html5Directory = [self.filePath stringByDeletingPathExtension];
            [[NSFileManager defaultManager] createDirectoryAtPath:html5Directory 
                                      withIntermediateDirectories:YES 
                                                       attributes:nil 
                                                            error:nil];
            [archive UnzipFileTo:html5Directory overWrite:YES];
        }
        [archive release];
    }
    
    return YES;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
// See comment in header.
{
    NSString* tempFile = [self.filePath stringByAppendingString:@".temp"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
        [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:self.filePath error:nil];
    } 
    if ([self processDownloadingContent]) {
        [super connectionDidFinishLoading:connection];
    }    
}

@end
