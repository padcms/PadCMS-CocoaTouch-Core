//
//  RRComplexScrollView.h
//  ComplexScrollResearch
//
//  Created by Maxim Pervushin on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageViewController;

typedef enum _RRPageConnection
{
	RRPageConnectionInvalid = -1,
	RRPageConnectionLeft = 0,
	RRPageConnectionRight = 1,
	RRPageConnectionTop = 2,
	RRPageConnectionBottom = 3,
	RRPageConnectionRotation = 4
	
} RRPageConnection;

@class RRComplexScrollView;

@protocol RRComplexScrollViewDatasource <NSObject>

- (PCPageViewController *)pageControllerForPageController:(PCPageViewController *)pageController 
                                               connection:(RRPageConnection)connection 
                                               scrollView:(RRComplexScrollView *)scrollView;

@end


@interface RRComplexScrollView : UIView

@property (assign, nonatomic) IBOutlet id<RRComplexScrollViewDatasource> dataSource;

- (void)reloadData;

- (void)scrollToTopElementAnimated:(BOOL)animated;
- (void)scrollToBottomElementAnimated:(BOOL)animated;
- (void)scrollToLeftElementAnimated:(BOOL)animated;
- (void)scrollToRightElementAnimated:(BOOL)animated;

@end
