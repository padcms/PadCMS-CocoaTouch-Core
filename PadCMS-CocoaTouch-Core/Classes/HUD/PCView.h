//
//  PCView.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 8/20/12.
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

typedef enum _PCViewState {
    PCViewStateInvalid = -1,
    PCViewStateHidden = 0,
    PCViewStateVisible = 1,
    PCViewStateActive = 2
} PCViewState;


@class PCView;

/**
 @protocol PCViewDelegate
 @brief PCViewDelegate protocol defines the optional method that allows delegate to respond on view state change. 
 */
@protocol PCViewDelegate <NSObject>

@optional
/**
 @brief Tells the delegate that receiving view should transit to the state.
 @param The PCView object informing the delegate of this event.
 @param New state of the receiver.
 @param Animation flag.
 */
- (void)view:(PCView *)view transitToState:(PCViewState)state animated:(BOOL)animated;

@end

/**
 @class PCView
 @brief An instance of PCView is able to change states and inform delegate about this changes. 
 */
@interface PCView : UIView

/**
 @brief The object that acts as the delegate of the receiving view.
 */
@property (assign, nonatomic) id<PCViewDelegate> statesDelegate;

/**
 @brief Current state of the view.
 */
@property (readonly, nonatomic) PCViewState state;

/**
 @brief Tells receiving view to change state.
 @param State that should be implemented.
 @param Animation flag.
 */
- (void)transitToState:(PCViewState)state animated:(BOOL)animated;

@end
