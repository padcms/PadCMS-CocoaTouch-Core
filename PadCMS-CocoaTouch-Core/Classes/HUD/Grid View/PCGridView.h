//
//  PCGridView.h
//  PCGridView
//
//  Created by Maxim Perushin on 8/1/12
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

#import <UIKit/UIKit.h>

@class PCGridView;
@class PCGridViewCell;
@class PCGridViewIndex;


/**
 @protocol PCGridViewDelegate
 @brief Methods of PCGridViewDelegate protocol allow the delegate to manage selections.
 */
@protocol PCGridViewDelegate <UIScrollViewDelegate>

@optional
/**
 @brief Tells the delegate that the cell with specified index is now selected.
 */
- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index;

@end


/**
 @protocol PCGridViewDataSource
 @brief PCGridViewDataSource protocol is adopted by an object that provides data for displaying.
 */
@protocol PCGridViewDataSource <NSObject>

/**
 @brief Asks the data source to return the number of rows in the grid view.
 @return The number of rows in grid view. Default value is 0.
 */
- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView;
/**
 @brief Asks the data source to return the number of columns in the grid view.
 @return The number of columns in grid view. Default value is 0.
 */
- (NSUInteger)gridViewNumberOfColumns:(PCGridView *)gridView;
/**
 @brief Asks the data source for the size of the cells in the grid view.
 @return The CGSize structure that specifies the size of the cells in grid view. Default value is CGSizeZero.
 */
- (CGSize)gridViewCellSize:(PCGridView *)gridView;
/**
 @brief Asks the data source for the grid view cell for specified index.
 @param PCGridViewIndex object that specifies the place in the grid view.
 @return PCGridViewCell object that should be placed in the grid view at corresponding index.
 */
- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index;

@end

/**
 @class PCGridView 
 @brief An instance of PCGridView is a means for displaying a list of information that could be represented as table or grid.
 */
@interface PCGridView : UIScrollView

/**
 @brief The object that acts as the delegate of the receiving grid view.
 */
@property (assign, nonatomic) id<PCGridViewDelegate> delegate;

/**
 @brief The object that acts as the data source of the receiving grid view.
 */
@property (assign, nonatomic) id<PCGridViewDataSource> dataSource;

/**
 @brief Reloads visible rect of the receiver.
 */
- (void)reloadData;

/**
 @brief Returns reusable PCGridViewCell object.
 @return reusable PCGridViewCell object or nil if reusable cells queue is empty.
 */
- (PCGridViewCell *)dequeueReusableCell;

@end
