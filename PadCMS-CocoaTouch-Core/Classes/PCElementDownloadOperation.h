//
//  PCElementDownloadOperation.h
//  Pad CMS
//
//  Created by admin on 02.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "QHTTPOperation.h"
#import "PCElementDownloadOperationDelegate.h"


@class PCPageElement;

@protocol PCElementDownloadOperationProgressDelegate

-(void)progressOfDownloading:(CGFloat)_progress forElement:(PCPageElement*)element;

@end

@interface PCElementDownloadOperation : QHTTPOperation
{
    BOOL _isProgressShown;
	NSUInteger _lengthOfDownloadedData;
	NSThread* _progressWatchingThread;    
    CGFloat _expectedContentLength;
}

@property(nonatomic, assign, readwrite) PCPageElement* element;
@property(nonatomic, copy) NSString* filePath;

@property(nonatomic,retain) NSObject<PCElementDownloadOperationProgressDelegate>* progressTarget;
@property(nonatomic, retain) NSObject<PCElementDownloadOperationDelegate>* operationTarget;
@property (readonly) float currentProgress;

- (void)setPogresShow:(BOOL)show toThread:(NSThread*)thread andTarget:(id)target;
- (NSOutputStream*)streamForFilePath:(NSString*)path;

- (id)initWithElement:(PCPageElement*)element;

- (BOOL)saveData:(NSData*)data toPath:(NSString*)path;

@end



