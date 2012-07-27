//
//  PCHUDView.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 7/16/12.
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

#import "PCGridView.h"

@class PCHUDView;
@class RRTopBarView;

/**
 @brief PCHUDView actions delegation protocol.
 */ 
@protocol PCHUDViewDelegate <NSObject>

@optional
/**
 @brief Tells the delegate to perform action with data that corresponds index.
 @param hudView - PCHUDView instance requesting this information.
 @param index - index of selected cell.
 */ 
 - (void)hudView:(PCHUDView *)hudView didSelectIndex:(NSUInteger)index;

@optional
/**
 @brief Tells the delegate to perform action before tocView will be shown.
 @param hudView - PCHUDView instance requesting this information.
 @param tocView - PCGridView instance that will be shown.
 */ 
- (void)hudView:(PCHUDView *)hudView willShowTOC:(PCGridView *)tocView;

@optional
/**
 @brief Tells the delegate to perform action before tocView will be hidden.
 @param hudView - PCHUDView instance requesting this information.
 @param tocView - PCGridView instance that will be hidden.
 */ 
- (void)hudView:(PCHUDView *)hudView willHideTOC:(PCGridView *)tocView;

@end


/**
 @brief PCHUDView data provider protocol. 
 */ 
@protocol PCHUDViewDataSource <NSObject>

/**
 @brief Asks the data source to return cell size for tocView in hudView.
 @param hudView - PCHUDView instance requesting this information.
 @param tocView - PCGridView instance to set cell size.
 @result the size for cells in grid view.
 */ 
- (CGSize)hudView:(PCHUDView *)hudView itemSizeInTOC:(PCGridView *)tocView;

/**
 @brief Asks the data source for image for given index.
 @param hudView - the PCHUDView object requesting this information.
 @result table of contents image.
 */ 
- (UIImage *)hudView:(PCHUDView *)hudView tocImageForIndex:(NSUInteger)index;

/**
 @brief Asks the data source for image for given index.
 @param hudView - the PCHUDView object requesting this information.
 @result the number of table of content items.
 */ 
- (NSUInteger)hudViewTOCItemsCount:(PCHUDView *)hudView;

@end 


/**
 @brief PCGridView cell for displaying table of contents element.
 */ 
@interface PCHUDView : UIView <PCGridViewDelegate, PCGridViewDataSource>

/**
 @brief The object that acts as the delegate of the receiving HUD view.
 */ 
@property (assign, nonatomic) id<PCHUDViewDelegate> delegate;

/**
 @brief The object that acts as the data source of the receiving HUD view.
 */ 
@property (assign, nonatomic) id<PCHUDViewDataSource> dataSource;

@property (readonly) RRTopBarView *topBarView;

/**
 @brief Button that manages top table of contents view.
 */ 
@property (readonly) UIButton *topTOCButton;

/**
 @brief Grid view object used to display table of contents items at the top of the HUD view.
 */ 
@property (readonly) PCGridView *topTOCView;

/**
 @brief Button that manages bottom table of contents view.
 */ 
@property (readonly) UIButton *bottomTOCButton;

/**
 @brief Grid view object used to display table of contents items at the bottom of the HUD view.
 */ 
@property (readonly) PCGridView *bottomTOCView;

/**
 @brief reloads data of the receiver.
 */ 
- (void)reloadData;

/**
 @brief hides all visible table of contents views of the receiver.
 */ 
- (void)hideTOCs;

/**
 @brief implements style for controls with PCStyler.
 @param options - options to be used by PCStyler object.
 */ 
- (void)stylizeElementsWithOptions:(NSDictionary *)options;

- (void)setTopBarVisible:(BOOL)visible;

- (BOOL)isTopBarVisible;

@end
