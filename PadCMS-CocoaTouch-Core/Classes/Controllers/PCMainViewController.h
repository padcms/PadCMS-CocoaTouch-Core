//
//  PCMainViewController.h
//  the_reader
//
//  Created by Mac OS on 7/23/10.
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
