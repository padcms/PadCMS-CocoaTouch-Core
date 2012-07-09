//
//  AbstractBasePageViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCPage.h"

@interface AbstractBasePageViewController : UIViewController
{
	PCPage* _page;
}
@property (nonatomic, readonly) PCPage* page;
- (id)initWithPage:(PCPage *)page;
-(void)loadFullView;
- (CGRect)activeZoneRectForType:(NSString*)zoneType;
-(NSArray*)activeZonesAtPoint:(CGPoint)point;
@end
