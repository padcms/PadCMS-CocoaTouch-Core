//
//  PCHorizontalPageDownloadOperation.h
//  Pad CMS
//
//  Created by admin on 29.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "QHTTPOperation.h"
#import "PCHorizontalPageDownloadOperationDelegate.h"

@protocol PCHorizontalPageOperationProgressDelegate

-(void)progressOfDownloading:(CGFloat)_progress forHorizontalPageKey:(NSNumber*)key;

@end

@interface PCHorizontalPageDownloadOperation : QHTTPOperation
{
    BOOL _isProgressShown;
	NSUInteger _lengthOfDownloadedData;
	NSThread* _progressWatchingThread;    
    CGFloat _expectedContentLength;
}

@property(nonatomic, retain)NSString* filePath;
@property(nonatomic, readonly) NSNumber* key;
@property(nonatomic, retain) NSObject <PCHorizontalPageDownloadOperationDelegate> *operationTarget;
@property(nonatomic, retain) NSObject <PCHorizontalPageOperationProgressDelegate> *progressTarget;

- (id)initWithResource:(NSString*)resource forKey:(NSNumber*)key;

- (void)setPogresShow:(BOOL)show toThread:(NSThread*)thread andTarget:(id<PCHorizontalPageOperationProgressDelegate>)target;

@end
