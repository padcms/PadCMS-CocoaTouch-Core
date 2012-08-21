//
//  PCTopBarView.h
//  PCTopBarView
//
//  Created by Maxim Pervushin on 7/27/12.
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

#import "RRView.h"

@class PCTopBarView;

/**
 @protocol PCTopBarViewDelegate
 @brief Methods of PCTopBarViewDelegate protocol allow delegate to handle events emitted by top bar view.
 */
@protocol PCTopBarViewDelegate <NSObject>

//@optional
///**
// @brief Tells the delegate that the back button have been tapped.
// @param topBarView - the PCTopBarView object that making this notification.
// @param button - the button that have been tapped.
// */
//- (void)topBarView:(PCTopBarView *)topBarView backButtonTapped:(UIButton *)button;
//
//@optional
///**
// @brief Tells the delegate that the summary button have been tapped.
// @param topBarView - the PCTopBarView object that making this notification.
// @param button - the button that have been tapped.
// */
//- (void)topBarView:(PCTopBarView *)topBarView summaryButtonTapped:(UIButton *)button;
//
//@optional
///**
// @brief Tells the delegate that the subscriptions button have been tapped.
// @param topBarView - the PCTopBarView object that making this notification.
// @param button - the button that have been tapped.
// */
//- (void)topBarView:(PCTopBarView *)topBarView subscriptionsButtonTapped:(UIButton *)button;
//
//@optional
///**
// @brief Tells the delegate that the share button have been tapped.
// @param topBarView - the PCTopBarView object that making this notification.
// @param button - the button that have been tapped.
// */
//- (void)topBarView:(PCTopBarView *)topBarView shareButtonTapped:(UIButton *)button;
//
//@optional
///**
// @brief Tells the delegate that the help button have been tapped.
// @param topBarView - the PCTopBarView object that making this notification.
// @param button - the button that have been tapped.
// */
//- (void)topBarView:(PCTopBarView *)topBarView helpButtonTapped:(UIButton *)button;
//
@optional
/**
 @brief Tells the delegate that the search have been started.
 @param topBarView - the PCTopBarView object that making this notification.
 @param searchText - NSString object that contains search pattern.
 */
- (void)topBarView:(PCTopBarView *)topBarView searchText:(NSString *)searchText;

@optional

- (void)topBarView:(PCTopBarView *)topBarView buttonTapped:(UIButton *)button;

@end

/**
 @class PCTopBarView
 @brief An instance of PCTopBarView is a means for top bar view with buttons, search field, and logo.
 */
@interface PCTopBarView : RRView <UITextFieldDelegate>

/**
 @brief The object that conforms PCTopBarViewDelegate protocol and acts like delegate.
 */
@property (assign) id<PCTopBarViewDelegate> delegate;

@property (readonly, nonatomic) UIButton *backButton;
@property (readonly, nonatomic) UIButton *summaryButton;
@property (readonly, nonatomic) UIButton *subscriptionsButton;
@property (readonly, nonatomic) UIButton *shareButton;
@property (readonly, nonatomic) UIButton *helpButton;

/**
 @brief Hides or shows summary button.
 @param hidden - YES if summary button should be hidden, NO in other case.
 @param animated - YES if current change should be animated and NO in other case.
 */
- (void)setSummaryButtonHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)hideKeyboard;

@end
