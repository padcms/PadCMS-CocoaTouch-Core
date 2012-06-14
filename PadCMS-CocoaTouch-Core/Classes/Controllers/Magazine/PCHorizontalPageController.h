//
//  PCHorizontalPageController.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 27.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCIssue.h"
#import "PCResourceView.h"


@class PCRevision;
@class PCRevisionViewController;
@class PCHorizontalPage;
@class MBProgressHUD;

@interface PCHorizontalPageController : UIViewController <UIScrollViewDelegate>
{
    UIImageView        *imageView;
	MBProgressHUD      *HUD;
	BOOL                isLoaded;
    UIScrollView       *innerScroll;
    UIView             *innerView;
}

@property (nonatomic, assign) PCRevisionViewController *revisionViewController; // TODO: Maybe remove later? 

@property (nonatomic, retain) PCRevision* revision; 
@property (nonatomic, assign) NSInteger pageIdentifier; 
@property (nonatomic, retain) NSString* resource;
@property (nonatomic, assign) BOOL selected; 
@property (nonatomic, retain) NSNumber* identifier;
@property (nonatomic, retain) PCHorizontalPage* horizontalPage;

- (void) loadFullView;
- (void) unloadFullView;
- (void) showHUD;

@end
