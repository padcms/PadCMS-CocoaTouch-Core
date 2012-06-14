//
//  PCMainViewController.h
//  the_reader
//
//  Created by Mac OS on 7/23/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#define DEBUG_VERSION 1
#define kHideBarDelay 5

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "PCRevisionViewController.h"
#import "PCApplication.h"
#import "PCKioskViewController.h"
#import "PCSearchViewController.h"

@class MagManager, PCRevisionViewController, PadCMSCoder;

@interface PCMainViewController : UIViewController
<UIScrollViewDelegate, UIAlertViewDelegate,
PCKioskViewControllerDelegateProtocol, PCKioskDataSourceProtocol,
PCSearchViewControllerDelegate>
//, PadCMSCodeDelegate>
{
    PCApplication* currentApplication;
    
	UIView                      *mainView;
	
	IBOutlet UIView             *airTopMenu;
	IBOutlet UIView             *airTopSummary;
		
	BOOL                        firstOrientLandscape;
	
	NSTimer                     *barTimer;

	UILabel                     *issueLabel_h;
	IBOutlet UILabel            *issueLabel_v;
	
	BOOL                        alreadyInit;
	
	BOOL                        currentTemplateLandscapeEnable;
	
	PCTwitterViewController     *twitterController;
    
	BOOL                         IsNotificationsBinded;
}

@property (nonatomic, retain) PCRevisionViewController *revisionViewController;
@property (nonatomic, assign) BOOL currentTemplateLandscapeEnable;
@property (nonatomic, assign) BOOL magManagerExist;
@property (nonatomic, retain) NSTimer* barTimer;
@property (nonatomic, retain) IBOutlet UIView* airTopMenu;
@property (nonatomic, retain) IBOutlet UIView* airTopSummary;
@property (nonatomic, retain) UIView* mainView;
@property (nonatomic, assign) BOOL firstOrientLandscape;
@property (nonatomic, assign) BOOL alreadyInit;

@property (nonatomic, retain) UILabel* issueLabel_h;
@property (nonatomic, retain) IBOutlet UILabel* issueLabel_v;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* kiosk_req_v;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* kiosk_req_h;

@property (nonatomic, retain) PCKioskViewController *kioskViewController;
@property (nonatomic, retain) PadCMSCoder* padcmsCoder;

- (void) removeMainScroll;

- (IBAction) btnUnloadTap:(id) sender;

- (void) startBarTimer;
- (void) stopBarTimer;
- (void) hideBars;

- (void) restart;
- (void) viewDidLoadStuff;
- (PCApplication*) getApplication;
- (void) switchToKiosk;

@end
