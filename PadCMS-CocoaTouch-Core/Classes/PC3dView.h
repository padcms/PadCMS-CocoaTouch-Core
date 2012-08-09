//
//  RR3dView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PC3dView : UIView

- (void)clearGraphicsCache;
- (void)loadModel:(NSString *)fileName;

@end
