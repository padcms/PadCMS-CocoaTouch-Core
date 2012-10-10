//
//  PCSubscriptionsMenuViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Igor Getmanenko on 17.07.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
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

#import "PCSubscriptionsMenuViewController.h"
#import "InAppPurchases.h"

@interface PCSubscriptionsMenuViewController ()

- (void) subscribe;
- (void) renewSubscription;

@end

@implementation PCSubscriptionsMenuViewController

@synthesize needRestoreIssues;
@synthesize menuFrame;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andSubscriptionFlag:(BOOL) isIssuesToRestore
{
    self = [super init];
    if (self) 
    {
        needRestoreIssues = isIssuesToRestore;
        menuFrame = frame;
        delegate = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subscriptionsPopup.png"]];
    self.view.frame = CGRectMake(menuFrame.origin.x, menuFrame.origin.y, bg.frame.size.width, bg.frame.size.height);
    [self.view addSubview:bg];
    [bg release];
    
    UIButton *subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    subscribeButton.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);
    subscribeButton.center = CGPointMake(subscribeButton.frame.size.width/2, subscribeButton.frame.size.height/2);
    [subscribeButton addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subscribeButton];
    
    UIButton *renewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    renewButton.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
    renewButton.center = CGPointMake(renewButton.frame.size.width/2, renewButton.frame.size.height/2 + renewButton.frame.origin.y);
    [renewButton addTarget:self action:@selector(renewSubscription) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:renewButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(BOOL)shouldAutorotate{
    return YES;
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)updateFrame:(CGRect)frame
{
    self.view.frame = CGRectMake(frame.origin.x, frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)subscribe
{
    self.view.hidden = YES;
    [self.delegate subscribeButtonWillTapped];
    //[[InAppPurchases sharedInstance] subscribe];
}

- (void)renewSubscription
{
    self.view.hidden = YES;
    [[InAppPurchases sharedInstance] renewSubscription:needRestoreIssues];
}

@end
