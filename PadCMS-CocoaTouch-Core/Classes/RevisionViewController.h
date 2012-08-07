//
//  RevisionViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractBasePageViewController.h"
#import "PCHudView.h"
#import "PCTopBarView.h"

@class PCRevision;
@class PCVideoManager;
@class RevisionViewController;

@protocol RevisionViewControllerDelegate <NSObject>

- (void)revisionViewControllerDidDismiss:(RevisionViewController *)revisionViewController;

@end

@interface RevisionViewController : UIViewController <UIScrollViewDelegate, PCActionDelegate,
UIGestureRecognizerDelegate, PCHudViewDataSource, PCHudViewDelegate, PCTopBarViewDelegate>
{
	IBOutlet UIView* topMenuView;
}

@property (assign) id<RevisionViewControllerDelegate> delegate;
@property (readonly, nonatomic) PCRevision *revision;
@property (retain) AbstractBasePageViewController* currentPageViewController;
@property (retain) AbstractBasePageViewController* nextPageViewController;
@property (nonatomic, retain) IBOutlet UIView* topSummaryView;
@property (nonatomic, retain) PCVideoManager *videoManager;

- (id)initWithRevision:(PCRevision *)revision;

@end
