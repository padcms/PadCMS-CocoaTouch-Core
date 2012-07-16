//
//  InteractivesBulletsViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimplePageViewController.h"

@class PCPageElementMiniArticle;
@interface InteractivesBulletsViewController : SimplePageViewController
@property (nonatomic, retain) NSArray* miniArticles;
@property (nonatomic, retain) PCPageElementMiniArticle *selectedMiniArticle;
@end
