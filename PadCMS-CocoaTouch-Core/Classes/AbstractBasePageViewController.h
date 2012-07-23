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
@interface AbstractBasePageViewController : UIViewController
{
	PCPage* _page;
	float _scale;
}
@property (nonatomic, readonly) PCPage* page;
@property (nonatomic, assign) id<PCActionDelegate>delegate;
@property (nonatomic, retain) NSMutableArray* actionButtons;

- (id)initWithPage:(PCPage *)page;
-(void)loadFullView;
- (CGRect)activeZoneRectForType:(NSString*)zoneType;
-(NSArray*)activeZonesAtPoint:(CGPoint)point;
-(void)releaseViews;
-(void)createActionButtons;
@end

@protocol PCActionDelegate 
	
-(void)showGallery;

@end