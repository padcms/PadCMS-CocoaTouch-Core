//
//  SliderBasedMiniArticleViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimplePageViewController.h"
#import "EasyTableView.h"

@class PCPageElementMiniArticle;
@interface SliderBasedMiniArticleViewController : SimplePageViewController <EasyTableViewDelegate>
@property (nonatomic, retain) EasyTableView *thumbsScrollView;
@property (nonatomic, retain) NSArray* miniArticles;
@property (nonatomic, retain) PCPageElementMiniArticle *selectedMiniArticle;
@end
