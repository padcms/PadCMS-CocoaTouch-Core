//
//  PCInteractiveBulletWithFlash.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 22.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCSliderBasedMiniArticleViewController.h"

@interface PCInteractiveBulletWithFlash : PCSliderBasedMiniArticleViewController
{
    UIView* buttonsView;
    BOOL isShow;
    UIButton* extraButton;
}

@property (nonatomic,retain) UIView* buttonsView;

@end
