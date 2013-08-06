//
//  PCColumnViewController.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
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
