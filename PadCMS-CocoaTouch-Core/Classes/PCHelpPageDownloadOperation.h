//
//  PCHelpPageDownloadOperation.h
//  Pad CMS
//
//  Created by admin on 29.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "QHTTPOperation.h"

@protocol PCHelpPageOperationProgressDelegate

-(void)progressOfDownloading:(CGFloat)_progress forHelpPageKey:(NSString*)key;

@end

@interface PCHelpPageDownloadOperation : QHTTPOperation
{
    BOOL _isProgressShown;
    NSUInteger _lengthOfDownloadedData;
	NSThread* _progressWatchingThread;    
    CGFloat _expectedContentLength;
}

@property(nonatomic, retain) NSString* filePath;
@property(nonatomic, readonly) NSString* helpPageKey;
@property(nonatomic ,retain) NSObject *operationTarget;
@property(nonatomic, retain) NSObject <PCHelpPageOperationProgressDelegate> *progressTarget;

- (id)initWithResource:(NSString*)resource forKey:(NSString*)key;

- (void)setPogresShow:(BOOL)show toThread:(NSThread*)thread andTarget:(id<PCHelpPageOperationProgressDelegate>)target;

@end
