//
//  PCElementMiniArticleDownloadOperation.h
//  Pad CMS
//
//  Created by admin on 06.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCElementDownloadOperation.h"

@interface PCElementMiniArticleDownloadOperation : PCElementDownloadOperation
{
    NSURLConnection *   _thumbnailConnection;
    NSMutableData *     _thumbnailDataAccumulator;
    NSHTTPURLResponse * _thumbnailLastResponse;
    CGFloat _thumbnailExpectedContentLength;
    NSOutputStream* _thumbnailOutPutStream;
    
    NSURLConnection *   _thumbnailSelectedConnection;
    NSMutableData *     _thumbnailSelectedDataAccumulator;
    NSHTTPURLResponse * _thumbnailSelectedLastResponse;
    CGFloat _thumbnailSelectedExpectedContentLength;
    NSOutputStream* _thumbnailSelectedOutPutStream;
    
    BOOL isMainImageDownloaded;
}

@property (nonatomic,copy) NSString* thumbnailFilePath;
@property (nonatomic,copy) NSString* thumbnailSelectedFilePath;
@property (nonatomic,copy) NSString* thumbnailURLString;
@property (nonatomic,copy) NSString* thumbnailSelectedURLString;


@end
