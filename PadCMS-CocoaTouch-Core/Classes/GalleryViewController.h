//
//  GalleryViewControllerViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPage;
@class GalleryViewController;

@protocol GalleryViewControllerDelegate <NSObject>

- (void)galleryViewControllerWillDismiss:(GalleryViewController *)galleryViewController;

@end

@interface GalleryViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, assign) id<GalleryViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray* galleryElements;
@property (nonatomic, retain) PCPage* page;
@property (nonatomic, retain) UIScrollView* galleryScrollView;

- (id)initWithPage:(PCPage *)page;

@end
