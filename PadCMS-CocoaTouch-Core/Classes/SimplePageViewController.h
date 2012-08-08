//
//  SimplePageViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractBasePageViewController.h"
#import "PCVideoManager.h"

@interface SimplePageViewController : AbstractBasePageViewController <UIGestureRecognizerDelegate, PCVideoManagerDelegate>
{
	PageElementViewController* _backgroundViewController;
	PageElementViewController* _bodyViewController;
    UITapGestureRecognizer* tapGestureRecognizer;
}
@property (nonatomic, retain) PageElementViewController* backgroundViewController;
@property (nonatomic, retain) PageElementViewController* bodyViewController;

- (void)createVideoFrame;
- (void)loadBackground;
- (BOOL)pdfActiveZoneAction:(PCPageActiveZone*)activeZone;
- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer;
- (void)showVideo:(PCPageElementVideo *)videoElement inRect:(CGRect)videoFrame;
- (void)showVideo:(PCPageElementVideo *)videoElement;

@end
