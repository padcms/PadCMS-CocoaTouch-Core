//
//  RRItemsViewItem.h
//  ReusingScrollViewDemo
//
//  Created by Maxim Pervushin on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRItemsViewIndex;

@interface RRItemsViewItem : UIView

@property (retain, nonatomic) RRItemsViewIndex *index;

- (void)clearContent;

@end
