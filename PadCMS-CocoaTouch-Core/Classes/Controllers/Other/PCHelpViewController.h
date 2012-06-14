//
//  PCHelpViewController.h
//  Pad CMS
//
//  Edit by Igor Getmanenko on 29.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCRevision;
@class PCHelpViewController;
@class MBProgressHUD;
@class PCScrollView;

@protocol PCHelpViewControllerDelegate <NSObject>

@required

- (void)dismissPCHelpViewController:(PCHelpViewController *)currentPCHelpViewController;

@end

@interface PCHelpViewController : UIViewController
{
	PCScrollView *_contentScroll;
    UIColor *_tintColor;
    MBProgressHUD* HUD;
	
}

@property (nonatomic, retain) PCScrollView *contentScroll;
@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, retain) PCRevision *revision;
@property (nonatomic, assign, readwrite) id <PCHelpViewControllerDelegate> delegate;

- (id)initWithRevision:(PCRevision *)revision;

@end
