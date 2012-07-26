//
//  RevisionViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractBasePageViewController.h"

@class PCRevision;
@class PCVideoManager;

@interface RevisionViewController : UIViewController <UIScrollViewDelegate, PCActionDelegate>
{
	IBOutlet UIView* topMenuView;
}
@property (readonly, nonatomic) PCRevision *revision;
@property (retain) AbstractBasePageViewController* currentPageViewController;
@property (retain) AbstractBasePageViewController* nextPageViewController;
@property (nonatomic, retain) IBOutlet UIView* topSummaryView;
@property (nonatomic, retain) PCVideoManager *videoManager;

- (id)initWithRevision:(PCRevision *)revision;

@end
