//
//  PCCustomPageControll.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 08.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCustomPageControll : UIControl
{
    NSInteger numberOfPages;
    NSInteger currentPage;
    NSMutableDictionary* images;
    NSMutableArray* buttons;
    CGSize dotSize;
    CGFloat distance;
}

@property(nonatomic) NSInteger numberOfPages;    
@property(nonatomic) NSInteger currentPage;
@property(nonatomic) CGSize dotSize;
@property(nonatomic) CGFloat distance;

- (void)setImage:(UIImage *)image forState:(UIControlState)state; 

@end
