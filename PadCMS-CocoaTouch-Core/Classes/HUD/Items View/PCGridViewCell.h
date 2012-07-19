//
//  RRItemsViewItem.h
//  ReusingScrollViewDemo
//
//  Created by Maxim Pervushin on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCGridViewIndex;

@interface PCGridViewCell : UIView

@property (retain, nonatomic) PCGridViewIndex *index;

- (void)clearContent;

@end
