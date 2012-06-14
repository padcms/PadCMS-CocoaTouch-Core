//
//  PCPageElementProgressDownloadingViewController.h
//  Pad CMS
//
//  Created by admin on 08.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCElementDownloadOperation.h"
#import "PCHelpPageDownloadOperation.h"

@class PCElementDownloadOperation;

@interface PCPageElementProgressDownloadingViewController : UIViewController <PCElementDownloadOperationProgressDelegate, PCHelpPageOperationProgressDelegate>
{
    UIProgressView* progressView;
    UILabel* progressLabel;
    CGFloat progress;
    PCElementDownloadOperation* downloadOperation;
    BOOL loaded;
    
}

- (id)initWithOperation:(PCElementDownloadOperation*)operation;

- (void)showProgress:(BOOL)isShow;

- (void) loadFullViewInRect:(CGRect)rect;
- (void) unloadView;


@end
