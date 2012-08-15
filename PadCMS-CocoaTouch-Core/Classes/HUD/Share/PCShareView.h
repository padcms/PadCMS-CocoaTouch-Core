//
//  RRShareView.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 8/14/12.
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

@class PCShareView;

/**
 @protocol PCShareViewDelegate.
 @brief PCShareView actions delegation protocol.
 */
@protocol PCShareViewDelegate <NSObject>
@optional
/**
 @brief Tells the delegate to perform Facebook share.
 */
- (void)shareViewFacebookShare:(PCShareView *)shareView;
@optional
/**
 @brief Tells the delegate to perform Twitter share.
 */
- (void)shareViewTwitterShare:(PCShareView *)shareView;
@optional
/**
 @brief Tells the delegate to perform Email share.
 */
- (void)shareViewEmailShare:(PCShareView *)shareView;

@end

/**
 @class PCShareView.
 @brief The object of the PCShareView provides a way to visually present an options to share information with social networks and web services.
 */
@interface PCShareView : UIView

/**
 @brief The object that acts as the delegate of the receiving share view.
 */
@property (assign, nonatomic) id<PCShareViewDelegate> delegate;

/**
 @brief The flag that indicates that the PCShareView is presented or not.
 */
@property (readonly, nonatomic) BOOL presented;

/**
 @brief Facebook sharing button.
 */
@property (readonly, nonatomic) UIButton *facebookButton;

/**
 @brief Twitter sharing button.
 */
@property (readonly, nonatomic) UIButton *twitterButton;

/**
 @brief Email sharing button.
 */
@property (readonly, nonatomic) UIButton *emailButton;

/**
 @brief Create configured share view object and return it to invoker.
 @return Configured share view object.
 */
+ (PCShareView *)configuredShareView;

/**
 @brief Presents receiver in the given view at the given point.
 @param View to show PCShareView object in.
 @param Point that should be used to align receiver.
 */
- (void)presentInView:(UIView *)view atPoint:(CGPoint)point;

/**
 @brief Dismisses receiver if it is currently presenting.
 */
- (void)dismiss;

@end
