//
//  PCGalleryViewController.h
//  Pad CMS
//
//  Copyright 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PCPage;
@class PCCustomPageControll;
@class PCScrollView;

@protocol PCGalleryViewControllerDelegate <NSObject>

@required

- (void)galleryViewControllerWillDismiss;

@end

@interface PCGalleryViewController : UIViewController <UIScrollViewDelegate/*, UIGestureRecognizerDelegate*/>
{
	PCScrollView *_mainScrollView;
    PCCustomPageControll *_pageControll;
    PCPage *_page;
    NSMutableArray *_images;
    NSMutableArray *_progressBarsArray;
    CGRect _currentViewRect;
	NSUInteger _currentIndex;
    NSInteger _galleryID;
	
}

@property (nonatomic, retain) PCScrollView *mainScrollView;
@property (nonatomic, retain) PCCustomPageControll *pageControll;
@property (nonatomic, retain) PCPage *page;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *progressBarsArray;
@property (nonatomic) CGRect currentViewRect;
@property (nonatomic, assign, readwrite) id <PCGalleryViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* imageViews;
@property (nonatomic, assign) BOOL horizontalOrientation;
@property (nonatomic, assign) NSInteger galleryID;

- (id) initWithPage: (PCPage *)initialPage;
- (void) setCurrentPhoto: (int) index;

@end
