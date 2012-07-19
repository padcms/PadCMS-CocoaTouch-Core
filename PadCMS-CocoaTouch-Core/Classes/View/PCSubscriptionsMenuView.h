//
//  PCSubscriptionsMenuView.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Igor Getmanenko on 17.07.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCSubscriptionsMenuViewDelegate <NSObject>

@required

- (void) newSubscription;
- (void) renewSubscription:(BOOL) needRenewIssues;

@end

@interface PCSubscriptionsMenuView : UIView

@property (nonatomic, assign, readwrite) id <PCSubscriptionsMenuViewDelegate> delegate;
@property (nonatomic, assign) BOOL needRestoreIssues;

- (id)initWithFrame:(CGRect)frame andSubscriptionFlag:(BOOL) isIssuesToRestore;
- (void) updateFrame:(CGRect)frame;

@end
