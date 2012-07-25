//
//  AbstractBasePageViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCPage.h"
#import "PageElementViewController.h"

@protocol PCActionDelegate;
@class PCBrowserViewController;
@class MBProgressHUD;
@interface AbstractBasePageViewController : UIViewController<UIGestureRecognizerDelegate>
{
	PCPage* _page;
	float _scale;
	UITapGestureRecognizer* tapGestureRecognizer;
	PCBrowserViewController *webBrowserViewController;
	MBProgressHUD* HUD;
}
@property (nonatomic, readonly) PCPage* page;
@property (nonatomic, assign) UIViewController<PCActionDelegate> *delegate;
@property (nonatomic, retain) NSMutableArray* actionButtons;

- (id)initWithPage:(PCPage *)page;
-(void)loadFullView;
- (CGRect)activeZoneRectForType:(NSString*)zoneType;
-(NSArray*)activeZonesAtPoint:(CGPoint)point;
-(void)releaseViews;
-(void)createActionButtons;
-(void)showHUD;
-(void)hideHUD;
@end

@protocol PCActionDelegate 
	
-(void)showGallery;
-(void)gotoPage:(PCPage*)page;

@end