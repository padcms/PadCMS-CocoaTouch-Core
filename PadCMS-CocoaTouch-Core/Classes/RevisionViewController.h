//
//  RevisionViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRComplexScrollView.h"

@class PCRevision;
@class PCPage;
@class PCPageViewController;
@interface RevisionViewController : UIViewController <RRComplexScrollViewDatasource, RRComplexScrollViewDelegate>

@property (nonatomic, readonly) PCRevision* revision;
@property (nonatomic, retain) PCPageViewController* currentPageController;
@property (nonatomic, retain) PCPageViewController* previousPageController;
@property (nonatomic, retain) PCPage* onScreenPage;



@property (nonatomic, retain) IBOutlet RRComplexScrollView* mainScroll;


-(id)initWithRevision:(PCRevision*)revision;

@end
