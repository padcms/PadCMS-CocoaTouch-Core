//
//  PCScrollView.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 6/1/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @class PCScrollView
 @brief Customized UIScrollView subclass. Able to show scroll buttons and ignore touches in specified 
    set of views
 */
@interface PCScrollView : UIScrollView

/**
 @brief show or hide horizontal scroll buttons. Default value is NO.
 */
@property (assign, nonatomic, getter = isHorizontalScrollButtonsEnabled) BOOL horizontalScrollButtonsEnabled;

/**
 @brief show or hide vertical scroll buttons. Default value is NO.
 */
@property (assign, nonatomic, getter = isVerticalScrollButtonsEnabled) BOOL verticalScrollButtonsEnabled;

/**
 @brief tint color for scroll buttons.
 */
@property (retain, nonatomic) UIColor *scrollButtonsTintColor;

/**
 @brief scrolls to the left subview if available.
 */
- (void)scrollLeft;

/**
 @brief scrolls to the right subview if available.
 */
- (void)scrollRight;

/**
 @brief scrolls to the upper subview if available.
 */
- (void)scrollUp;

/**
 @brief scrolls to the lower subview if available.
 */
- (void)scrollDown;

/**
 @brief Class method. Adds view to the global set of views that should ignore touches.
 */
+ (void)addViewToIgnoreTouches:(UIView *)view;

/**
 @brief Class method. Remove view from the global set of views that should ignore touches.
 */
+ (void)removeViewFromIgnoreTouches:(UIView *)view;

/**
 @brief Class method. Clears global set of views that should ignore touches.
 */
+ (void)removeAllViewsToIgnoreTouches;

@end
