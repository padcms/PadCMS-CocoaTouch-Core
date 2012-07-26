//
//  PCVideoManager.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Igor Getmanenko on 26.07.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCVideoController;
@class PCBrowserViewController;

@protocol PCVideoManagerDelegate

@required
- (void)videoControllerWillShow;
- (void)videoControllerWillDismiss;

@end

@interface PCVideoManager : NSObject

- (id) init;
- (void) showVideo:(NSString*) videoPath inRect:(CGRect) videoFrame;
- (void) dismissVideo;

@end
