//
//  RRSummaryView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCGridView;

@interface PCSummaryView : UIView

@property (readonly, nonatomic) PCGridView *gridView;

- (void)reloadData;

@end
