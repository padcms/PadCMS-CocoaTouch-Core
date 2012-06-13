//
//  PCKioskBaseGalleryView.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 27.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//
#import "PCKioskSubview.h"
#import "PCKioskAbstractControlElement.h"
#import "PCKioskSubviewDelegateProtocol.h"

/**
 @class PCKioskBaseGalleryView
 @brief Base class for kiosk gallery subview
 */
@interface PCKioskBaseGalleryView : PCKioskSubview <PCKioskSubviewDelegateProtocol>

/**
 @brief Is gallery disabled (upon downloading) or not
 */
@property (assign) BOOL disabled;

/**
 @brief Current selected revision index
 */
@property (assign) NSInteger currentRevisionIndex;

/**
 @brief Revision control element with index that changed by user selection
 */
@property (retain, nonatomic) PCKioskAbstractControlElement *controlElement;

/**
 @brief Gallery view that contains revision covers
 */
@property (retain, nonatomic) UIView *galleryView;



/**
 @brief Create and return new instance of the control element
 
 @param visible frame for element
 */
- (PCKioskAbstractControlElement*) newControlElementWithFrame:(CGRect) frame;

@end
