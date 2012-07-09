//
//  SimplePageViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractBasePageViewController.h"

@interface SimplePageViewController : AbstractBasePageViewController
{
	UIImageView* _backgroundView;
	UIImageView* _bodyView;
}
@property (nonatomic, retain) UIImageView* backgroundView;
@property (nonatomic, retain) UIImageView* bodyView;
-(void)loadBackground;
@end
