//
//  PCFlashButton.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 23.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCFlashButton : UIButton
{
    NSTimer* flashTimer;
    CGFloat flashDuration;
}
@property (nonatomic,assign) CGFloat flashDuration;

-(void)startFlash;
-(void)stopFlash;

@end
