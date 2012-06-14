//
//  PCColumnViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCData.h"
#import "PCPageViewController.h"
#import "PCRevisionViewController.h"

@class PCRevisionViewController;
@class PCPageViewController;
@class PCLandscapeViewController;
@class PCScrollView;

/**
 @class PCColumnViewController
 @brief Column view controller 
 */


@interface PCColumnViewController : UIViewController <UIScrollViewDelegate>
{
    PCScrollView* mainScrollView;
    CGSize pageSize;
    PCColumn* column;
    NSMutableArray* pageViewControllers;
    PCRevisionViewController* magazineViewController;
}

@property (nonatomic, retain) PCColumn* column; ///< Column data model
@property (nonatomic, assign) PCRevisionViewController* magazineViewController; ///< The magazine view controller this column belongs to
@property (nonatomic, readonly) NSMutableArray* pageViewControllers;
@property (nonatomic, assign) BOOL horizontalOrientation;  ///< Revision orientation

/**
 @brief Initialize with column data model
 @param column - column data model
 */ 
-(id) initWithColumn:(PCColumn*)column;

/**
 @brief Show page
 @param page - page data model
 */ 
-(PCPageViewController*) showPage:(PCPage*)page;

/**
 @brief Return page size for view controller
 @param pageViewController - page view controller
 */ 
-(CGSize) pageSizeForViewController:(PCPageViewController*)pageViewController;

/**
 @brief Return current page view controller
 */
- (PCPageViewController*) currentPageViewController;

- (void) loadFullView;
- (void) unloadFullView;

/**
 @brief Set page size
 @param pageSize - page size
 */ 
- (void) setPageSize:(CGSize) spageSize;

- (NSInteger) currentPageIndex;

@end
