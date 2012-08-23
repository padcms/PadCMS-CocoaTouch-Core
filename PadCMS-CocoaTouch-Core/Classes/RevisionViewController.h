//
//  RevisionViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractBasePageViewController.h"
#import "PCEmailController.h"
#import "PCHudView.h"
#import "PCSearchViewController.h"
#import "PCShareView.h"
#import "PCTopBarView.h"
#import "PCTwitterNewController.h"
#import "GalleryViewController.h"
#import "PCHudController.h"

@class PCRevision;
@class PCVideoManager;
@class RevisionViewController;

@protocol RevisionViewControllerDelegate <NSObject>

- (void)revisionViewControllerDidDismiss:(RevisionViewController *)revisionViewController;
- (void)revisionViewController:(RevisionViewController *)revisionViewController willPresentGalleryViewController:(GalleryViewController *)galleryViewController;
- (void)revisionViewController:(RevisionViewController *)revisionViewController willDismissGalleryViewController:(GalleryViewController *)galleryViewController;

@end

@interface RevisionViewController : UIViewController <UIScrollViewDelegate, PCActionDelegate,
UIGestureRecognizerDelegate, /*PCHudViewDataSource, PCHudViewDelegate, PCTopBarViewDelegate,*/RRHudControllerDelegate,  
PCSearchViewControllerDelegate, PCShareViewDelegate, PCTwitterNewControllerDelegate,
PCEmailControllerDelegate, UIAlertViewDelegate, GalleryViewControllerDelegate>
{
	IBOutlet UIView* topMenuView;
}

@property (assign) id<RevisionViewControllerDelegate> delegate;
@property (readonly, nonatomic) PCRevision *revision;
@property (retain) AbstractBasePageViewController* currentPageViewController;
@property (retain) AbstractBasePageViewController* nextPageViewController;
@property (nonatomic, retain) IBOutlet UIView* topSummaryView;

- (id)initWithRevision:(PCRevision *)revision
       withInitialPage:(PCPage*)initialPage
           previewMode:(BOOL)previewMode;

@end
